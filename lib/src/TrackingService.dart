import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TrackingService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get tracking data for an order
  static Future<Map<String, dynamic>> getTrackingData(String orderId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/$orderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get tracking data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      }
      throw Exception('Failed to get tracking data: ${e.message}');
    } catch (e) {
      print('Error fetching tracking data: $e');
      throw e;
    }
  }

  // Start delivery (by driver)
  static Future<Map<String, dynamic>> startDelivery(String orderId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/tracking/$orderId/start',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to start delivery: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? 'Cannot start delivery';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      }
      throw Exception('Failed to start delivery: ${e.message}');
    }
  }

  // Complete delivery (by driver)
  static Future<Map<String, dynamic>> completeDelivery(String orderId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/tracking/$orderId/complete',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to complete delivery: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? 'Cannot complete delivery';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      }
      throw Exception('Failed to complete delivery: ${e.message}');
    }
  }

  // Get real-time tracking info (for periodic updates)
  static Future<Map<String, dynamic>> getRealTimeTracking(
      String orderId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/$orderId/realtime',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get real-time tracking: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get real-time tracking: ${e.toString()}');
    }
  }

  // Get all active deliveries (admin view)
  static Future<Map<String, dynamic>> getAllActiveDeliveries(
      {int page = 1, int limit = 10}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/active?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get active deliveries: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get active deliveries: ${e.toString()}');
    }
  }

  // Get delivery history
  static Future<Map<String, dynamic>> getDeliveryHistory(
      {int page = 1, int limit = 10}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/history?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get delivery history: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get delivery history: ${e.toString()}');
    }
  }

  // Get delivery statistics
  static Future<Map<String, dynamic>> getDeliveryStats() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get delivery stats: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get delivery stats: ${e.toString()}');
    }
  }

  // Update delivery status (admin action)
  static Future<Map<String, dynamic>> updateDeliveryStatus(
      String orderId, String status) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/tracking/$orderId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to update delivery status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update delivery status: ${e.toString()}');
    }
  }

  // Get driver's current deliveries
  static Future<Map<String, dynamic>> getDriverCurrentDeliveries() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/driver/current',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get driver deliveries: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get driver deliveries: ${e.toString()}');
    }
  }

  // Cancel delivery (admin action)
  static Future<Map<String, dynamic>> cancelDelivery(
      String orderId, String reason) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/tracking/$orderId/cancel',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to cancel delivery: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to cancel delivery: ${e.toString()}');
    }
  }

  // Get estimated delivery time
  static Future<Map<String, dynamic>> getEstimatedDeliveryTime(
      String orderId) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/tracking/$orderId/estimate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to get estimated delivery time: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get estimated delivery time: ${e.toString()}');
    }
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
