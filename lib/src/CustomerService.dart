import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class CustomerService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Configure Dio with CORS handling
  static Dio _createDioClient() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(seconds: 15);
    dio.options.receiveTimeout = Duration(seconds: 30);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        print('📤 Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 Response: ${response.statusCode} ${response.statusMessage}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.type} - ${error.message}');
        handler.next(error);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) => print('🔧 DIO: $object'),
    ));

    return dio;
  }

  /// Test backend connection with better error handling
  static Future<Map<String, String>> diagnoseConnection() async {
    final results = <String, String>{};

    try {
      final dio = _createDioClient();
      final response = await dio.get(ApiConstants.healthCheck);
      results['connectivity'] = 'Success - Backend reachable';
      results['status'] = '${response.statusCode}';
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionError:
            if (e.message?.contains('CORS') == true) {
              results['connectivity'] =
                  'CORS Error - Backend needs CORS configuration';
              results['solution'] =
                  'Update backend app.js to allow localhost:55111';
            } else {
              results['connectivity'] =
                  'Connection Error - Backend may be down';
              results['solution'] =
                  'Check if backend is running at ${ApiConstants.baseUrl}';
            }
            break;
          case DioExceptionType.connectionTimeout:
            results['connectivity'] =
                'Timeout - Backend too slow or unreachable';
            break;
          case DioExceptionType.badResponse:
            results['connectivity'] =
                'Backend Error - ${e.response?.statusCode}';
            break;
          default:
            results['connectivity'] = 'Unknown Error - ${e.message}';
        }
      } else {
        results['connectivity'] = 'Unexpected Error - $e';
      }
    }

    return results;
  }

  /// Get all customers with enhanced error handling
  static Future<Map<String, dynamic>?> getAllCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'ASC',
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = ApiConstants.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('📞 Calling: ${ApiConstants.customers}');

      final response = await dio.get(
        ApiConstants.customers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] != null) {
          // Check backend response format: { statusCode: 200, message: "...", data: {...} }
          if (responseData['statusCode'] == 200) {
            final data = responseData['data'] as Map<String, dynamic>;
            print('✅ Successfully fetched customers');
            return responseData;
          } else {
            throw Exception('API Error: ${responseData['message']}');
          }
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Get customer by ID
  static Future<Map<String, dynamic>?> getCustomerById(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(ApiConstants.customerById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
    return null;
  }

  /// Create customer
  static Future<Map<String, dynamic>?> createCustomer(
    String username,
    String email,
    String phone,
    String newPassword,
    String? imageBase64,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final requestData = {
        'name': username,
        'email': email,
        'phone': phone,
        'password': newPassword,
      };

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        requestData['image'] = imageBase64;
      }

      final response = await dio.post(
        ApiConstants.customers,
        data: requestData,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to create customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
    return null;
  }

  /// Update customer
  static Future<Map<String, dynamic>?> updateCustomer(
    String id,
    String name,
    String email,
    String phone,
    String currentPassword,
    String newPassword,
    String? imageBase64,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      if (newPassword.isNotEmpty) {
        requestData['password'] = newPassword;
      }

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        requestData['image'] = imageBase64;
      }

      final response = await dio.put(
        ApiConstants.buildUrlWithParams(ApiConstants.customerById, {'id': id}),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to update customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
    return null;
  }

  /// Delete customer
  static Future<bool> deleteCustomer(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.delete(
        ApiConstants.buildUrlWithParams(ApiConstants.customerById, {'id': id}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return true;
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Failed to delete customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
    return false;
  }

  // ===== UTILITY METHODS =====

  /// Token management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  /// Quick connection test
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

  /// Handle Dio exceptions with specific error messages
  static void _handleDioException(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = 'Connection failed. This is likely a CORS issue. '
            'Please ensure the backend at ${ApiConstants.baseUrl} allows requests from localhost:55111';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Backend server may be slow or unreachable.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server response timeout. Request took too long.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied. Admin role required.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'API endpoint not found. Check backend URL.';
        } else if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = 'Invalid request data.';
          }
        } else {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else {
            errorMessage =
                'Server error: ${e.response?.statusCode} - ${e.response?.data}';
          }
        }
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    throw Exception(errorMessage);
  }

  /// Format error message for user display
  static String formatErrorMessage(String error) {
    if (error.contains('CORS')) {
      return 'Connection issue: Please contact administrator to enable CORS for this domain.';
    } else if (error.contains('Authentication')) {
      return 'Please login again to continue.';
    } else if (error.contains('Access denied')) {
      return 'You do not have permission to perform this action.';
    } else if (error.contains('Connection failed')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else {
      return error;
    }
  }

  /// Debug helper for API connection
  static Future<void> debugApiConnection() async {
    print('🔍 ========== API DEBUG ==========');

    final token = await getToken();
    print('🔑 Token exists: ${token != null}');

    if (token != null) {
      print('🔑 Token preview: ${token.substring(0, 20)}...');

      try {
        final dio = _createDioClient();
        final response = await dio.get('${ApiConstants.customers}?limit=1');

        print('✅ API connection successful');
        print('📊 Status: ${response.statusCode}');
        print('📄 Response type: ${response.data.runtimeType}');
        if (response.data is Map) {
          print('📄 Response keys: ${response.data?.keys}');
        }
      } catch (e) {
        print('❌ API connection failed: $e');
      }
    }

    print('🔍 ========== DEBUG END ==========');
  }
}
