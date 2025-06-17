import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class TrackingService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Dio _createDioClient() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
    ));

    return dio;
  }

  // ✅ FIXED: Get tracking data for an order
  static Future<Map<String, dynamic>> getTrackingData(String orderId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.orderTracking, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to get tracking data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get tracking data');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Start delivery (by driver) - Changed to POST
  static Future<Map<String, dynamic>> startDelivery(String orderId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        // Changed from PUT to POST
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingStart, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to start delivery: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'start delivery');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Complete delivery (by driver) - Changed to POST
  static Future<Map<String, dynamic>> completeDelivery(String orderId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        // Changed from PUT to POST
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingComplete, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to complete delivery: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'complete delivery');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ NEW: Update driver location during delivery
  static Future<Map<String, dynamic>> updateDriverLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    final dio = _createDioClient();

    try {
      final response = await dio.put(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingLocation, {'id': orderId}),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update driver location: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update driver location');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ NEW: Get tracking history for order
  static Future<Map<String, dynamic>> getTrackingHistory(String orderId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingHistory, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to get tracking history: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get tracking history');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Helper method: Get real-time tracking (same as getTrackingData)
  static Future<Map<String, dynamic>> getRealTimeTracking(
      String orderId) async {
    return await getTrackingData(orderId);
  }

  // ✅ Helper method: Check if order is being delivered
  static Future<bool> isOrderBeingDelivered(String orderId) async {
    try {
      final trackingData = await getTrackingData(orderId);
      final orderStatus = trackingData['order_status'];
      return orderStatus == 'on_delivery';
    } catch (e) {
      return false;
    }
  }

  // ✅ Helper method: Get delivery progress
  static Future<Map<String, dynamic>?> getDeliveryProgress(
      String orderId) async {
    try {
      final trackingData = await getTrackingData(orderId);

      if (trackingData['order_status'] == 'on_delivery') {
        return {
          'order_id': orderId,
          'order_status': trackingData['order_status'],
          'delivery_status': trackingData['delivery_status'],
          'driver_location': trackingData['driver_location'],
          'estimated_delivery_time': trackingData['estimated_delivery_time'],
          'driver': trackingData['driver'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Helper method: Get estimated delivery time
  static Future<DateTime?> getEstimatedDeliveryTime(String orderId) async {
    try {
      final trackingData = await getTrackingData(orderId);
      final estimatedTime = trackingData['estimated_delivery_time'];

      if (estimatedTime != null) {
        return DateTime.parse(estimatedTime);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== UTILITY METHODS =====

  static Future<String?> _getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  static void _handleDioException(DioException e, String operation) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage =
            'Connection failed. Please check your internet connection.';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Server may be slow or unreachable.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server response timeout. Request took too long.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied. Required permissions missing.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Order not found or no tracking data available.';
        } else if (e.response?.statusCode == 400) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Invalid request data.';
          }
        } else {
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        }
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    throw Exception('Failed to $operation: $errorMessage');
  }

  // ===== CONNECTION TEST =====

  static Future<bool> testConnection() async {
    try {
      final dio = _createDioClient();
      final response = await dio.get(ApiConstants.healthCheck);
      return response.statusCode == 200;
    } catch (e) {
      print('Tracking service connection test failed: $e');
      return false;
    }
  }
}
