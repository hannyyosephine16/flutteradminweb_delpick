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

  // Response handling
  static Map<String, dynamic> handleResponse(Response response) {
    print('📡 === RESPONSE HANDLER ===');
    print('📡 Status: ${response.statusCode}');
    print('📡 Data Type: ${response.data.runtimeType}');

    if (response.statusCode == null || response.data == null) {
      print('❌ Invalid response - null status or data');
      throw Exception('Invalid response from server');
    }

    final responseData = response.data as Map<String, dynamic>;
    print('📡 Response Keys: ${responseData.keys.toList()}');

    // ✅ FIXED: Handle response format without statusCode
    // Check if HTTP status is success
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // If response has message, consider it valid
      if (responseData.containsKey(ApiConstants.messageKey)) {
        print('✅ Response validation passed (message-based)');
        return responseData;
      }
    }

    // Fallback to original validation
    if (!ApiConstants.isValidResponse(responseData)) {
      print('❌ Invalid response format');
      print('❌ Expected keys: statusCode + message OR just message');
      print('❌ Actual keys: ${responseData.keys.toList()}');
      throw Exception('Invalid response format from server');
    }

    if (!ApiConstants.isSuccessResponse(responseData)) {
      final errorMsg = ApiConstants.getErrorMessage(responseData);
      print('❌ API Error Response: $errorMsg');
      throw Exception(errorMsg);
    }

    print('✅ Response validation passed');
    return responseData;
  }

  static T extractData<T>(Map<String, dynamic> response) {
    final data = ApiConstants.extractData(response);
    if (data is T) {
      return data;
    }
    throw Exception('Invalid data type in response');
  }

  // Error handling
  static void handleError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = ApiConstants.networkError;
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // Try to extract error message from response
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
              errorMessage = ApiConstants.getErrorMessage(
                  {ApiConstants.statusCodeKey: statusCode});
            }
          } else {
            errorMessage = ApiConstants.getErrorMessage(
                {ApiConstants.statusCodeKey: statusCode});
          }
        } else {
          switch (statusCode) {
            case 400:
              errorMessage = ApiConstants.validationError;
              break;
            case 401:
              errorMessage = ApiConstants.unauthorizedError;
              clearStorage(); // Auto logout
              break;
            case 403:
              errorMessage = ApiConstants.forbiddenError;
              break;
            case 404:
              errorMessage = ApiConstants.notFoundError;
              break;
            case 409:
              errorMessage = ApiConstants.conflictError;
              break;
            case 422:
              errorMessage = ApiConstants.validationError;
              break;
            case 500:
              errorMessage = ApiConstants.serverError;
              break;
            default:
              errorMessage = 'Server error: HTTP $statusCode';
          }
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

  // Pagination helper
  static Map<String, dynamic> extractPaginationData(
      Map<String, dynamic> response) {
    return {
      'totalItems': response[ApiConstants.totalItemsKey] ?? 0,
      'totalPages': response[ApiConstants.totalPagesKey] ?? 0,
      'currentPage': response[ApiConstants.currentPageKey] ?? 1,
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
}
