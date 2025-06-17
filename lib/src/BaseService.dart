// lib/src/BaseService.dart - Service dasar untuk semua service
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Common/AppConfig.dart';

abstract class BaseService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle logout
          clearStorage();
        }
        handler.next(error);
      },
    ));

    _initialized = true;
  }

  static Dio get dio => _dio;

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.tokenKey);
  }

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }

  static void handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        final errorData = e.response?.data;
        throw Exception(errorData?['message'] ?? 'Bad request');
      case 401:
        throw Exception('Authentication required');
      case 403:
        throw Exception('Access denied');
      case 404:
        throw Exception('Resource not found');
      case 409:
        throw Exception('Resource already exists');
      case 500:
        throw Exception('Internal server error');
      default:
        throw Exception('Network error: ${e.message}');
    }
  }
}
