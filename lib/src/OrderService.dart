import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ApiService.dart';

class OrderService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all orders (admin view)
  static Future<Map<String, dynamic>> getAllOrders(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/orders?page=$page&limit=$limit',
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
        throw Exception('Failed to load orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching orders: $e');
      throw e;
    }
  }

  // Get orders by user (customer orders)
  static Future<Map<String, dynamic>> getOrdersByUser(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/orders/user?page=$page&limit=$limit',
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
            'Failed to load user orders: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load user orders: ${e.toString()}');
    }
  }

  // Get orders by store (store orders)
  static Future<Map<String, dynamic>> getOrdersByStore(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/orders/store?page=$page&limit=$limit',
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
            'Failed to load store orders: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load store orders: ${e.toString()}');
    }
  }

  // Get order by ID
  static Future<Map<String, dynamic>> getOrderById(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/orders/$id',
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
        throw Exception('Failed to get order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      }
      throw Exception('Failed to get order: ${e.message}');
    }
  }

  // Place new order
  static Future<Map<String, dynamic>> placeOrder(
      Map<String, dynamic> orderData) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        '$baseUrl/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: orderData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to place order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? 'Failed to place order';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to place order: ${e.message}');
    }
  }

  // Process order by store (approve/reject)
  static Future<Map<String, dynamic>> processOrderByStore(
      String orderId, String action) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/orders/$orderId/process',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'action': action}, // 'approve' or 'reject'
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to process order: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to process order: ${e.toString()}');
    }
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/orders/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'orderId': orderId,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/orders/$orderId/cancel',
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
        throw Exception('Failed to cancel order: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Create review for order
  static Future<Map<String, dynamic>> createReview(
      Map<String, dynamic> reviewData) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        '$baseUrl/orders/review',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: reviewData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to create review: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to create review: ${e.toString()}');
    }
  }

  // Get tracking data for order
  static Future<Map<String, dynamic>> getTrackingData(String orderId) async {
    final token = await ApiService.getToken();

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
    } catch (e) {
      throw Exception('Failed to get tracking data: ${e.toString()}');
    }
  }

  // Start delivery (by driver)
  static Future<Map<String, dynamic>> startDelivery(String orderId) async {
    final token = await ApiService.getToken();

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
    } catch (e) {
      throw Exception('Failed to start delivery: ${e.toString()}');
    }
  }

  // Complete delivery (by driver)
  static Future<Map<String, dynamic>> completeDelivery(String orderId) async {
    final token = await ApiService.getToken();

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
    } catch (e) {
      throw Exception('Failed to complete delivery: ${e.toString()}');
    }
  }

  // Get dashboard order statistics
  static Future<Map<String, dynamic>> getOrderStats() async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/orders/stats',
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
        throw Exception('Failed to get order stats: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get order stats: ${e.toString()}');
    }
  }
}
