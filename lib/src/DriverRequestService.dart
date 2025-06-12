import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ApiService.dart';

class DriverRequestService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all driver requests (for the logged-in driver)
  static Future<Map<String, dynamic>> getDriverRequests(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/driver-requests?page=$page&limit=$limit',
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
            'Failed to load driver requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Driver access required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching driver requests: $e');
      throw e;
    }
  }

  // Get detailed driver request
  static Future<Map<String, dynamic>> getDriverRequestDetail(
      String requestId) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/driver-requests/$requestId',
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
            'Failed to get driver request detail: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Driver request not found');
      }
      throw Exception('Failed to get driver request detail: ${e.message}');
    }
  }

  // Respond to driver request (accept/reject)
  static Future<Map<String, dynamic>> respondToDriverRequest(
      String requestId, String action) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/driver-requests/$requestId/respond',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'action': action}, // 'accept' or 'reject'
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to respond to driver request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? 'Invalid request';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 404) {
        throw Exception('Driver request not found');
      }
      throw Exception('Failed to respond to driver request: ${e.message}');
    }
  }

  // Accept driver request
  static Future<Map<String, dynamic>> acceptDriverRequest(
      String requestId) async {
    return await respondToDriverRequest(requestId, 'accept');
  }

  // Reject driver request
  static Future<Map<String, dynamic>> rejectDriverRequest(
      String requestId) async {
    return await respondToDriverRequest(requestId, 'reject');
  }

  // Get driver request statistics (if needed for admin dashboard)
  static Future<Map<String, dynamic>> getDriverRequestStats() async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/driver-requests/stats',
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
            'Failed to get driver request stats: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get driver request stats: ${e.toString()}');
    }
  }

  // Get all driver requests (admin view)
  static Future<Map<String, dynamic>> getAllDriverRequests(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/admin/driver-requests?page=$page&limit=$limit', // Admin endpoint if exists
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
            'Failed to load all driver requests: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load all driver requests: ${e.toString()}');
    }
  }

  // Get driver requests by order ID
  static Future<Map<String, dynamic>> getDriverRequestsByOrderId(
      String orderId) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/driver-requests?orderId=$orderId',
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
            'Failed to get driver requests for order: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception(
          'Failed to get driver requests for order: ${e.toString()}');
    }
  }

  // Get driver requests by driver ID
  static Future<Map<String, dynamic>> getDriverRequestsByDriverId(
      String driverId,
      {int page = 1,
      int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers/$driverId/requests?page=$page&limit=$limit',
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
            'Failed to get driver requests: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get driver requests: ${e.toString()}');
    }
  }

  // Cancel driver request (if in pending status)
  static Future<Map<String, dynamic>> cancelDriverRequest(
      String requestId) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/driver-requests/$requestId/cancel',
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
            'Failed to cancel driver request: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to cancel driver request: ${e.toString()}');
    }
  }
}
