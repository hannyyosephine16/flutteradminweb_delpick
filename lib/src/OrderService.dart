import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';
import 'ApiService.dart';

class OrderService {
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
      onError: (error, handler) {
        print('❌ OrderService Error: ${error.message}');
        handler.next(error);
      },
    ));

    return dio;
  }

  // ❌ TIDAK ADA - Backend tidak punya endpoint untuk admin melihat semua orders
  static Future<Map<String, dynamic>> getAllOrders(
      {int page = 1, int limit = 10}) async {
    throw Exception(
        'Admin orders endpoint not available in backend.\n\nAvailable endpoints:\n• GET /orders/customer/orders (Customer only)\n• GET /orders/store/orders (Store owner only)\n• GET /orders/:id (Individual order)');
  }

  // ✅ Get orders by user (customer orders)
  static Future<Map<String, dynamic>> getOrdersByUser(
      {int page = 1, int limit = 10}) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.customerOrders,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to load user orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'load user orders');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get orders by store (store orders)
  static Future<Map<String, dynamic>> getOrdersByStore(
      {int page = 1, int limit = 10}) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.storeOrders,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to load store orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'load store orders');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get order by ID
  static Future<Map<String, dynamic>> getOrderById(String id) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(ApiConstants.orderById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to get order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get order');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Place new order (customer only)
  static Future<Map<String, dynamic>> placeOrder(
      Map<String, dynamic> orderData) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        ApiConstants.orders,
        data: orderData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to place order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'place order');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Process order by store (approve/reject) - store owner only
  static Future<Map<String, dynamic>> processOrderByStore(
      String orderId, String action) async {
    final dio = _createDioClient();

    try {
      final response = await dio.put(
        '${ApiConstants.orders}/$orderId/process',
        data: {'action': action}, // 'approve' or 'reject'
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to process order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'process order');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Update order status (store owner only)
  static Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    final dio = _createDioClient();

    try {
      final response = await dio.patch(
        // Changed from PUT to PATCH
        ApiConstants.buildUrlWithParams(
            ApiConstants.orderStatus, {'id': orderId}),
        data: {'order_status': status}, // Fixed data structure
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update order status');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Cancel order (customer only)
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.put(
        '${ApiConstants.orders}/$orderId/cancel',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to cancel order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'cancel order');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Create review for order (customer only)
  static Future<Map<String, dynamic>> createReview(
      String orderId, Map<String, dynamic> reviewData) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        ApiConstants.buildUrlWithParams(
            ApiConstants.orderReview, {'id': orderId}),
        data: reviewData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to create review: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'create review');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Get tracking data for order
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

  // ✅ FIXED: Start delivery (by driver)
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

  // ✅ FIXED: Complete delivery (by driver)
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

  // ✅ FIXED: Update driver location during delivery
  static Future<Map<String, dynamic>> updateDriverLocation(
      String orderId, double latitude, double longitude) async {
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

  // ✅ FIXED: Get tracking history for order
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

  // ❌ Order statistics endpoint not available
  static Future<Map<String, dynamic>> getOrderStats() async {
    throw Exception(
        'Order statistics endpoint not available in backend.\n\nBackend needs to implement:\n• GET /orders/stats\n• GET /admin/stats/orders');
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
          errorMessage = 'Resource not found.';
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

  // Helper method to show available endpoints
  static String getAvailableEndpointsInfo() {
    return '''
    ''';
  }
}
