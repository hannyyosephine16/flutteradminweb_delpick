import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class DriverRequestService {
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

  // ✅ Get all driver requests (for the logged-in driver)
  static Future<Map<String, dynamic>> getDriverRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.driverRequests,
        queryParameters: ApiConstants.buildQueryParams(
          page: page,
          limit: limit,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to load driver requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'load driver requests');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Get detailed driver request
  static Future<Map<String, dynamic>> getDriverRequestDetail(
      String requestId) async {
    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.driverRequestById, {'id': requestId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to get driver request detail: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'get driver request detail');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ FIXED: Respond to driver request (accept/reject) - Changed PUT to POST
  static Future<Map<String, dynamic>> respondToDriverRequest(
      String requestId, String action) async {
    final dio = _createDioClient();

    try {
      final response = await dio.post(
        // Changed from PUT to POST
        ApiConstants.buildUrlWithParams(
            ApiConstants.respondDriverRequest, {'id': requestId}),
        data: {'action': action}, // 'accept' or 'reject'
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response: ${responseData['message']}');
      } else {
        throw Exception(
            'Failed to respond to driver request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'respond to driver request');
    }
    throw Exception('Unexpected error occurred');
  }

  // ✅ Accept driver request
  static Future<Map<String, dynamic>> acceptDriverRequest(
      String requestId) async {
    return await respondToDriverRequest(requestId, 'accept');
  }

  // ✅ Reject driver request
  static Future<Map<String, dynamic>> rejectDriverRequest(
      String requestId) async {
    return await respondToDriverRequest(requestId, 'reject');
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
