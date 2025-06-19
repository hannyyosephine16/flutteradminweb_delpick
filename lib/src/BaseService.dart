// Fixed BaseService.dart untuk format respons backend yang sebenarnya

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';
import 'dart:convert';

abstract class BaseService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: ApiConstants.defaultHeaders,
    );

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && !options.path.contains('/auth/login')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Auto logout on unauthorized
          clearStorage();
        }
        handler.next(error);
      },
    ));

    _initialized = true;
  }

  static Dio get dio {
    if (!_initialized) initialize();
    return _dio;
  }

  // Storage methods
  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  static Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: ApiConstants.userKey, value: json.encode(user));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: ApiConstants.userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // ✅ UPDATED: Response handling untuk format backend yang sebenarnya
  static Map<String, dynamic> handleResponse(Response response) {
    print('📡 === RESPONSE HANDLER ===');
    print('📡 Status: ${response.statusCode}');
    print('📡 Data Type: ${response.data.runtimeType}');

    if (response.statusCode == null || response.data == null) {
      print('❌ Invalid response - null status or data');
      throw Exception('Invalid response from server');
    }

    // ✅ Check HTTP status first
    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      print('❌ HTTP Error Status: ${response.statusCode}');
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final responseData = response.data as Map<String, dynamic>;
    print('📡 Response Keys: ${responseData.keys.toList()}');

    // ✅ FIXED: Handle actual backend response format
    // Backend format: { "message": "...", "data": {...} }

    if (responseData.containsKey(ApiConstants.messageKey)) {
      print('✅ Response validation passed (has message)');
      return responseData;
    }

    // ✅ Fallback: Check if it has required data structure
    if (responseData.containsKey('token') && responseData.containsKey('user')) {
      print('✅ Response validation passed (direct auth format)');
      return responseData;
    }

    print('❌ Invalid response format');
    print('❌ Expected: message field OR token+user fields');
    print('❌ Actual keys: ${responseData.keys.toList()}');
    throw Exception('Invalid response format from server');
  }

  // ✅ FIXED: Extract data method with proper type handling
  static T extractData<T>(Map<String, dynamic> response) {
    // ✅ UPDATED: Extract data dari format backend yang sebenarnya
    dynamic data;

    if (response.containsKey(ApiConstants.dataKey)) {
      // Format: { "message": "...", "data": {...} }
      data = response[ApiConstants.dataKey];
    } else {
      // Format direct: { "token": "...", "user": {...} }
      data = response;
    }

    if (data is T) {
      return data;
    }

    // ✅ FIXED: Handle case where T is expected to be Map<String, dynamic>
    // Use runtimeType comparison instead of direct type comparison
    if (T.toString() == 'Map<String, dynamic>' && data is Map) {
      return Map<String, dynamic>.from(data) as T;
    }

    // ✅ Handle List<Map<String, dynamic>> case
    if (T.toString().startsWith('List<') && data is List) {
      return data.cast<Map<String, dynamic>>() as T;
    }

    // ✅ Handle primitive types
    if (data != null) {
      try {
        return data as T;
      } catch (e) {
        // If cast fails, try to convert
        if (T == String) {
          return data.toString() as T;
        }
        if (T == int && data is String) {
          return int.tryParse(data)! as T;
        }
        if (T == double && data is String) {
          return double.tryParse(data)! as T;
        }
      }
    }

    throw Exception('Invalid data type in response. Expected: $T, Got: ${data.runtimeType}');
  }

  // Error handling
  static void handleError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = '''
🌐 Connection Error!

Solutions:
1. Check internet connection
2. Verify backend URL: ${ApiConstants.baseUrl}
3. For development: flutter run -d chrome --web-browser-flag="--disable-web-security"
4. Check if backend server is running
''';
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // ✅ UPDATED: Try to extract error message from actual backend format
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey(ApiConstants.messageKey)) {
            errorMessage = responseData[ApiConstants.messageKey];
          } else if (responseData.containsKey(ApiConstants.errorsKey)) {
            final errors = responseData[ApiConstants.errorsKey];
            if (errors is String) {
              errorMessage = errors;
            } else if (errors is List && errors.isNotEmpty) {
              errorMessage = errors.first.toString();
            } else {
              errorMessage = _getDefaultErrorMessage(statusCode);
            }
          } else {
            errorMessage = _getDefaultErrorMessage(statusCode);
          }
        } else {
          errorMessage = _getDefaultErrorMessage(statusCode);
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    throw Exception(errorMessage);
  }

  static String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return ApiConstants.validationError;
      case 401:
        clearStorage(); // Auto logout
        return ApiConstants.unauthorizedError;
      case 403:
        return ApiConstants.forbiddenError;
      case 404:
        return ApiConstants.notFoundError;
      case 409:
        return ApiConstants.conflictError;
      case 422:
        return ApiConstants.validationError;
      case 500:
        return ApiConstants.serverError;
      default:
        return 'Server error: HTTP ${statusCode ?? 'unknown'}';
    }
  }

  // CRUD operations with proper error handling
  static Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> patch(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  // Utility methods
  static String buildUrlWithParams(
      String endpoint, Map<String, String> params) {
    return ApiConstants.buildUrlWithParams(endpoint, params);
  }

  static Map<String, dynamic> buildQueryParams({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? additionalParams,
  }) {
    return ApiConstants.buildQueryParams(
      page: page,
      limit: limit,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
      additionalParams: additionalParams,
    );
  }

  // File upload helper
  static Future<Map<String, dynamic>> uploadFile(
      String endpoint,
      String filePath, {
        String fieldName = 'file',
        Map<String, dynamic>? additionalData,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      final response = await dio.post(endpoint, data: formData);
      return handleResponse(response);
    } on DioException catch (e) {
      handleError(e);
      rethrow;
    }
  }

  // ✅ UPDATED: Pagination helper untuk format backend yang sebenarnya
  static Map<String, dynamic> extractPaginationData(
      Map<String, dynamic> response) {

    // ✅ Check both old and new format
    return {
      'totalItems': response[ApiConstants.totalItemsKey] ??
          response['total_items'] ??
          response['totalItems'] ?? 0,
      'totalPages': response[ApiConstants.totalPagesKey] ??
          response['total_pages'] ??
          response['totalPages'] ?? 0,
      'currentPage': response[ApiConstants.currentPageKey] ??
          response['current_page'] ??
          response['currentPage'] ?? 1,
    };
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await dio.get(
        ApiConstants.health,
        options: Options(
          sendTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode == ApiConstants.statusOk;
    } catch (e) {
      return false;
    }
  }

  // ✅ NEW: Specific login method using the base service
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      // ✅ Handle actual backend response format
      if (response.containsKey('data') && response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (token != null && user != null) {
          // Save token and user data
          await saveToken(token);
          await saveUserData(user);

          return {
            'success': true,
            'token': token,
            'user': user,
            'message': response['message'] ?? 'Login successful',
          };
        }
      }

      throw Exception('Invalid login response format');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}