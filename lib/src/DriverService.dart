import 'dart:async';
import 'dart:convert';
import 'package:delpick_admin/src/ApiService.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ✅ FIXED: Get all drivers with proper response handling
  static Future<Map<String, dynamic>> getAllDrivers(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        print(
            '🔍 DriverService - Raw response type: ${responseData.runtimeType}');
        print('🔍 DriverService - Raw response: $responseData');

        if (responseData is Map<String, dynamic>) {
          // ✅ Return the full response to preserve all information
          // This ensures pagination info and data structure are maintained
          return responseData;
        } else if (responseData is List) {
          // ✅ If backend returns direct array, wrap it properly
          return {
            'statusCode': 200,
            'message': 'Success',
            'data': responseData,
            'totalItems': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };
        } else {
          throw Exception(
              'Unexpected response format: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load drivers: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ DriverService DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ DriverService error: $e');
      throw e;
    }
  }

  // Get driver by ID
  static Future<Map<String, dynamic>> getDriverById(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers/$id',
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
        throw Exception('Failed to get driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Driver not found');
      }
      throw Exception('Failed to get driver: ${e.message}');
    }
  }

  // Create driver
  static Future<Map<String, dynamic>> createDriver(
      String name,
      String email,
      String password,
      String phone,
      String vehicleNumber,
      String? imageBase64) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();
    request.open('POST', '$baseUrl/drivers');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token');

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      try {
        if (request.status == 201) {
          final Map<String, dynamic> response =
              json.decode(request.responseText!);
          completer.complete(response['data'] ?? response);
        } else {
          final errorResponse = json.decode(request.responseText ?? '{}');
          final errorMessage =
              errorResponse['message'] ?? 'Failed to create driver';
          completer.completeError(Exception(errorMessage));
        }
      } catch (e) {
        completer.completeError(
            Exception('Failed to create driver: ${request.statusText}'));
      }
    });

    final data = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'vehicle_number': vehicleNumber,
      'image': imageBase64,
    });

    request.send(data);
    return completer.future;
  }

  // Update existing driver
  static Future<Map<String, dynamic>> updateDriver(
    String id,
    Map<String, dynamic> driverData,
  ) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: driverData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to update driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Driver not found');
      }
      throw Exception('Failed to update driver: ${e.message}');
    }
  }

  // Delete driver
  static Future<Map<String, dynamic>> deleteDriver(String id) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.delete(
        '$baseUrl/drivers/$id',
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
        throw Exception('Failed to delete driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Driver not found');
      }
      throw Exception('Failed to delete driver: ${e.message}');
    }
  }

  // Update driver location (for real-time tracking)
  static Future<Map<String, dynamic>> updateDriverLocation(
    double latitude,
    double longitude,
  ) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/drivers/location',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to update driver location: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update driver location: ${e.toString()}');
    }
  }

  // Get driver location
  static Future<Map<String, dynamic>> getDriverLocation(String driverId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers/$driverId/location',
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
            'Failed to get driver location: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get driver location: ${e.toString()}');
    }
  }

  // Update driver status
  static Future<Map<String, dynamic>> updateDriverStatus(String status) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/drivers/status',
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
            'Failed to update driver status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update driver status: ${e.toString()}');
    }
  }

  // Get driver orders
  static Future<Map<String, dynamic>> getDriverOrders(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers/orders?page=$page&limit=$limit',
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
            'Failed to get driver orders: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get driver orders: ${e.toString()}');
    }
  }
}
