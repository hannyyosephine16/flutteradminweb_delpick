import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Common/AppConfig.dart';

class ApiService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Initialize Dio with interceptors
  static void initialize() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);

    // Add request interceptor for auth
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && !options.path.contains('/auth/login')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - redirect to login
          clearToken();
        }
        handler.next(error);
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Login admin - sesuai dengan backend response
  static Future<Map<String, dynamic>> loginAdmin(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Backend response format: { statusCode: 200, message: "...", data: { token, user } }
        if (responseData['statusCode'] == 200 && responseData['data'] != null) {
          final data = responseData['data'];
          final token = data['token'];
          final user = data['user'];

          // Check if user is admin
          if (user['role'] != 'admin') {
            throw Exception('Access denied. Admin role required.');
          }

          // Save token and user data
          await saveToken(token);
          await saveUserData(user);

          return {
            'success': true,
            'token': token,
            'user': user,
            'message': responseData['message'],
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        throw Exception(errorData?['message'] ?? 'Invalid input');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Logout admin
  static Future<void> logoutAdmin() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post('/auth/logout');
      }
    } catch (e) {
      // Continue with local logout even if server logout fails
      print('Server logout failed: $e');
    } finally {
      // Always clear local data
      await clearToken();
      await clearUserData();
    }
  }

  /// Get current user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update profile
  static Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _dio.put('/auth/profile', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          await saveUserData(responseData['data']);
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: AppConfig.tokenKey);
  }

  // User data management
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: AppConfig.userKey, value: json.encode(user));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: AppConfig.userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: AppConfig.userKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    final userData = await getUserData();
    return userData?['role'] == AppConfig.adminRole;
  }
}
