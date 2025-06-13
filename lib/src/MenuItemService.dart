import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ApiService.dart';

class MenuItemService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // ✅ FIXED: Get all menu items (for admin/global view)
  static Future<Map<String, dynamic>> getAllMenuItems(
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/menu?page=$page&limit=$limit',
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
            '🔍 MenuItemService - Raw response type: ${responseData.runtimeType}');
        print('🔍 MenuItemService - Raw response: $responseData');

        if (responseData is Map<String, dynamic>) {
          // ✅ Return the full response to preserve all information
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
        throw Exception('Failed to load menu items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ MenuItemService DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Access denied');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ MenuItemService error: $e');
      throw e;
    }
  }

  // ✅ FIXED: Get menu items by store ID
  static Future<Map<String, dynamic>> getMenuItemsByStoreId(String storeId,
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

        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is List) {
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
        throw Exception('Failed to load menu items: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load menu items: ${e.toString()}');
    }
  }

  // Get menu item by ID
  static Future<Map<String, dynamic>> getMenuItemById(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/menu/$id',
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
        throw Exception('Failed to get menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Menu item not found');
      }
      throw Exception('Failed to get menu item: ${e.message}');
    }
  }

  // Create new menu item (by store owner)
  static Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> menuItemData) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.post(
        '$baseUrl/menu',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: menuItemData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to create menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        final errorMessage =
            errorData['message'] ?? 'Failed to create menu item';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create menu item: ${e.message}');
    }
  }

  // Update menu item
  static Future<Map<String, dynamic>> updateMenuItem(
      String id, Map<String, dynamic> menuItemData) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/menu/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: menuItemData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'Failed to update menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Menu item not found');
      }
      throw Exception('Failed to update menu item: ${e.message}');
    }
  }

  // Delete menu item
  static Future<Map<String, dynamic>> deleteMenuItem(String id) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.delete(
        '$baseUrl/menu/$id',
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
            'Failed to delete menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Menu item not found');
      }
      throw Exception('Failed to delete menu item: ${e.message}');
    }
  }

  // Create menu item with image (store owner)
  static Future<Map<String, dynamic>> createMenuItemWithImage({
    required String name,
    required double price,
    required String description,
    required int quantity,
    String? imageBase64,
  }) async {
    final Map<String, dynamic> menuItemData = {
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
    };

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      menuItemData['image'] = imageBase64;
    }

    return await createMenuItem(menuItemData);
  }

  // Update menu item with image
  static Future<Map<String, dynamic>> updateMenuItemWithImage({
    required String id,
    String? name,
    double? price,
    String? description,
    int? quantity,
    String? imageBase64,
  }) async {
    final Map<String, dynamic> menuItemData = {};

    if (name != null) menuItemData['name'] = name;
    if (price != null) menuItemData['price'] = price;
    if (description != null) menuItemData['description'] = description;
    if (quantity != null) menuItemData['quantity'] = quantity;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      menuItemData['image'] = imageBase64;
    }

    return await updateMenuItem(id, menuItemData);
  }

  // ✅ FIXED: Search menu items
  static Future<Map<String, dynamic>> searchMenuItems(String query,
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/menu?search=$query&page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is List) {
          return {
            'statusCode': 200,
            'message': 'Search completed',
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
        throw Exception(
            'Failed to search menu items: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to search menu items: ${e.toString()}');
    }
  }

  // ✅ FIXED: Get menu items by category (if implemented in backend)
  static Future<Map<String, dynamic>> getMenuItemsByCategory(String category,
      {int page = 1, int limit = 10}) async {
    final token = await ApiService.getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/menu?category=$category&page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is List) {
          return {
            'statusCode': 200,
            'message': 'Category loaded',
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
        throw Exception(
            'Failed to load menu items by category: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to load menu items by category: ${e.toString()}');
    }
  }
}
