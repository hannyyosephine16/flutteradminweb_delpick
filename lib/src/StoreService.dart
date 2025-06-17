import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';
import 'ApiService.dart';

class StoreService {
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
        print('❌ StoreService Error: ${error.message}');
        handler.next(error);
      },
    ));

    return dio;
  }

  // ✅ Get all Stores with proper response handling
  static Future<Map<String, dynamic>> getAllStores(
      {int page = 1, int limit = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.stores,
        queryParameters:
            ApiConstants.buildQueryParams(page: page, limit: limit),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        print(
            '🔍 StoreService - Raw response type: ${responseData.runtimeType}');
        print('🔍 StoreService - Raw response: $responseData');

        if (responseData is Map<String, dynamic>) {
          // Backend response format: { statusCode: 200, message: "...", data: stores[] }
          if (responseData.containsKey('statusCode') &&
              responseData['statusCode'] == 200) {
            return responseData;
          } else {
            // Return the full response to preserve all information
            return responseData;
          }
        } else if (responseData is List) {
          // If backend returns direct array, wrap it properly
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
        throw Exception('Failed to load Stores: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'load stores');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get Store by ID
  static Future<Map<String, dynamic>> getStoreById(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(ApiConstants.storeById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to get Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get store');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Create new store
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
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

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
      };

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        data['image'] = imageBase64;
      }

      final response = await dio.post(
        ApiConstants.stores,
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to create store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'create store');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Update existing Store
  static Future<Map<String, dynamic>> updateStore(
    String id,
    Map<String, dynamic> storeData,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.put(
        ApiConstants.buildUrlWithParams(ApiConstants.storeById, {'id': id}),
        data: storeData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to update Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update store');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Delete Store
  static Future<Map<String, dynamic>> deleteStore(String id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.delete(
        ApiConstants.buildUrlWithParams(ApiConstants.storeById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to delete Store: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'delete store');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Update Store profile (by owner)
  static Future<Map<String, dynamic>> updateStoreProfile(
      Map<String, dynamic> storeData) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.put(
        '${ApiConstants.stores}/update',
        data: storeData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update store profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update store profile');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Update Store status (by admin/owner)
  static Future<Map<String, dynamic>> updateStoreStatus(
      String id, String status) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.patch(
        '${ApiConstants.stores}/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to update store status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'update store status');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get store menu items
  static Future<Map<String, dynamic>> getStoreMenuItems(
    String storeId, {
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

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
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        // Handle direct array response from backend
        if (responseData is List) {
          return {
            'menu_items': responseData,
            'totalItems': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };
        }
        return responseData;
      } else {
        throw Exception(
            'Failed to get store menu items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get store menu items');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get store orders
  static Future<Map<String, dynamic>> getStoreOrders(
      {int page = 1, int limit = 10}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.storeOrders,
        queryParameters:
            ApiConstants.buildQueryParams(page: page, limit: limit),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        return responseData;
      } else {
        throw Exception(
            'Failed to get store orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get store orders');
    }
    throw Exception('Unexpected error occurred');
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
          errorMessage = 'Unauthorized: Please login again';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Forbidden: Admin access required';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Resource not found';
        } else if (e.response?.statusCode == 400) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Invalid request data';
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

  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      final dio = _createDioClient();
      final response = await dio.get(ApiConstants.healthCheck);
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Validate store data before sending
  static bool validateStoreData(Map<String, dynamic> data) {
    final requiredFields = ['name', 'email', 'address', 'phone'];

    for (String field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          data[field].toString().trim().isEmpty) {
        return false;
      }
    }

    // Email validation
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(data['email'])) {
      return false;
    }

    return true;
  }
}
