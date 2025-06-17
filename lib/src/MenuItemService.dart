import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class MenuItemService {
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

  // ✅ Get all menu items
  static Future<Map<String, dynamic>> getAllMenuItems({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    final dio = _createDioClient();

    try {
      final queryParams = ApiConstants.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        additionalParams: category != null ? {'category': category} : null,
      );

      final response = await dio.get(
        ApiConstants.menu,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('statusCode') &&
              responseData['statusCode'] == 200) {
            return responseData;
          }
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
    } on DioException catch (e) {
      _handleDioException(e, 'load menu items');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get menu items by store ID
  static Future<Map<String, dynamic>> getMenuItemsByStoreId(
    String storeId, {
    int page = 1,
    int limit = 10,
  }) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.menuByStore, {'store_id': storeId}),
        queryParameters:
            ApiConstants.buildQueryParams(page: page, limit: limit),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('statusCode') &&
              responseData['statusCode'] == 200) {
            return responseData;
          }
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
    } on DioException catch (e) {
      _handleDioException(e, 'load menu items by store');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get menu item by ID
  static Future<Map<String, dynamic>> getMenuItemById(String id) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(ApiConstants.menuItemById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception('Failed to get menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get menu item');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Create new menu item (by store owner)
  static Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> menuItemData) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        ApiConstants.menu,
        data: menuItemData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to create menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'create menu item');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Update menu item
  static Future<Map<String, dynamic>> updateMenuItem(
      String id, Map<String, dynamic> menuItemData) async {
    final dio = _createDioClient();

    try {
      final response = await dio.put(
        ApiConstants.buildUrlWithParams(ApiConstants.menuItemById, {'id': id}),
        data: menuItemData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update menu item');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Delete menu item
  static Future<Map<String, dynamic>> deleteMenuItem(String id) async {
    final dio = _createDioClient();

    try {
      final response = await dio.delete(
        ApiConstants.buildUrlWithParams(ApiConstants.menuItemById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to delete menu item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'delete menu item');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Update menu item status
  static Future<Map<String, dynamic>> updateMenuItemStatus(
      String id, bool isAvailable) async {
    final dio = _createDioClient();

    try {
      final response = await dio.patch(
        ApiConstants.buildUrlWithParams(
            ApiConstants.menuItemStatus, {'id': id}),
        data: {'is_available': isAvailable},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update menu item status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update menu item status');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Helper: Create menu item with image
  static Future<Map<String, dynamic>> createMenuItemWithImage({
    required String name,
    required double price,
    required String category,
    String? description,
    int? quantity,
    String? imageBase64,
  }) async {
    final Map<String, dynamic> menuItemData = {
      'name': name,
      'price': price,
      'category': category,
    };

    if (description != null) menuItemData['description'] = description;
    if (quantity != null) menuItemData['quantity'] = quantity;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      menuItemData['image'] = imageBase64;
    }

    return await createMenuItem(menuItemData);
  }

  // ✅ Helper: Update menu item with image
  static Future<Map<String, dynamic>> updateMenuItemWithImage({
    required String id,
    String? name,
    double? price,
    String? category,
    String? description,
    int? quantity,
    bool? isAvailable,
    String? imageBase64,
  }) async {
    final Map<String, dynamic> menuItemData = {};

    if (name != null) menuItemData['name'] = name;
    if (price != null) menuItemData['price'] = price;
    if (category != null) menuItemData['category'] = category;
    if (description != null) menuItemData['description'] = description;
    if (quantity != null) menuItemData['quantity'] = quantity;
    if (isAvailable != null) menuItemData['is_available'] = isAvailable;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      menuItemData['image'] = imageBase64;
    }

    return await updateMenuItem(id, menuItemData);
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
}
