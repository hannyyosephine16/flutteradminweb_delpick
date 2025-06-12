import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ApiService.dart';

class StoreService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all Stores with pagination
  static Future<Map<String, dynamic>> getAllStores(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/stores?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Backend response format: {message, data: {totalItems, totalPages, currentPage, stores}}
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to load Stores: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching Stores: $e');
      throw e;
    }
  }

  // Get Store by ID
  static Future<Map<String, dynamic>> getStoreById(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/stores/$id',
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
        throw Exception('Failed to get Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Store not found');
      }
      throw Exception('Failed to get Store: ${e.message}');
    }
  }

  // Create new store
  static Future<Map<String, dynamic>> createStore(
    String name,
    String email,
    String password,
    String phone,
    String storeName,
    String address,
    String description,
    String openTime,
    String closeTime,
    double latitude,
    double longitude,
    String? imageBase64,
  ) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = Dio();

    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'storeName': storeName,
        'address': address,
        'description': description,
        'openTime': openTime,
        'closeTime': closeTime,
        'latitude': latitude,
        'longitude': longitude,
        'image': imageBase64,
      };

      final response = await dio.post(
        '$baseUrl/stores',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to create store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData['message'] ?? 'Failed to create store';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create store: ${e.message}');
    }
  }

  // Update existing Store
  static Future<Map<String, dynamic>> updateStore(
    String id,
    Map<String, dynamic> storeData,
  ) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/stores/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: storeData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to update Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Store not found');
      }
      throw Exception('Failed to update Store: ${e.message}');
    }
  }

  // Delete Store
  static Future<Map<String, dynamic>> deleteStore(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.delete(
        '$baseUrl/stores/$id',
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
        throw Exception('Failed to delete Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Store not found');
      }
      throw Exception('Failed to delete Store: ${e.message}');
    }
  }

  // Update Store profile (by owner)
  static Future<Map<String, dynamic>> updateStoreProfile(
      Map<String, dynamic> storeData) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/stores/update',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: storeData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to update store profile: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update store profile: ${e.toString()}');
    }
  }

  // Update Store status (by admin)
  static Future<Map<String, dynamic>> updateStoreStatus(
      String id, String status) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.patch(
        '$baseUrl/stores/$id/status',
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
            'Failed to update store status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update store status: ${e.toString()}');
    }
  }

  // Get store menu items
  static Future<Map<String, dynamic>> getStoreMenuItems(String storeId,
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/menu/store/$storeId?page=$page&limit=$limit',
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
            'Failed to get store menu items: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get store menu items: ${e.toString()}');
    }
  }

  // Get store orders
  static Future<Map<String, dynamic>> getStoreOrders(
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
            'Failed to get store orders: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get store orders: ${e.toString()}');
    }
  }
}
