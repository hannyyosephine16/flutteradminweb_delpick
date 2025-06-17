import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class ApiService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Initialize Dio with interceptors
  static void initialize() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout =
        Duration(milliseconds: ApiConstants.connectTimeout);
    _dio.options.receiveTimeout =
        Duration(milliseconds: ApiConstants.receiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: ApiConstants.sendTimeout);

    // Add request interceptor for auth
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && !options.path.contains(ApiConstants.login)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers.addAll(ApiConstants.defaultHeaders);
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == ApiConstants.statusUnauthorized) {
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
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;

        // Backend response format: { statusCode: 200, message: "...", data: { token, user } }
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk &&
            responseData[ApiConstants.dataKey] != null) {
          final data = responseData[ApiConstants.dataKey];
          final token = data['token'];
          final user = data['user'];

          // Check if user is admin
          if (user['role'] != ApiConstants.adminRole) {
            throw Exception('Access denied. Admin role required.');
          }

          // Save token and user data
          await saveToken(token);
          await saveUserData(user);

          return {
            'success': true,
            'token': token,
            'user': user,
            'message': responseData[ApiConstants.messageKey],
          };
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == ApiConstants.statusUnauthorized) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == ApiConstants.statusBadRequest) {
        final errorData = e.response?.data;
        throw Exception(errorData?[ApiConstants.messageKey] ?? 'Invalid input');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Logout admin
  static Future<void> logoutAdmin() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(ApiConstants.logout);
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
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          return responseData[ApiConstants.dataKey];
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

      final response = await _dio.put(ApiConstants.profile, data: data);

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          await saveUserData(responseData[ApiConstants.dataKey]);
          return responseData[ApiConstants.dataKey];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Forgot password
  static Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          return responseData[ApiConstants.dataKey];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  /// Reset password
  static Future<Map<String, dynamic>?> resetPassword(
      String token, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          return responseData[ApiConstants.dataKey];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Verify email
  static Future<Map<String, dynamic>?> verifyEmail(String token) async {
    try {
      final response = await _dio.post('${ApiConstants.verifyEmail}/$token');

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          return responseData[ApiConstants.dataKey];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to verify email: $e');
    }
  }

  /// Resend verification email
  static Future<Map<String, dynamic>?> resendVerification(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendVerification,
        data: {'email': email},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data;
        if (responseData[ApiConstants.statusCodeKey] == ApiConstants.statusOk) {
          return responseData[ApiConstants.dataKey];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to resend verification: $e');
    }
  }

  // ===== TOKEN MANAGEMENT =====

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  /// Clear authentication token
  static Future<void> clearToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }

  // ===== USER DATA MANAGEMENT =====

  /// Save user data
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: ApiConstants.userKey, value: json.encode(user));
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: ApiConstants.userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    await _storage.delete(key: ApiConstants.userKey);
  }

  /// Clear all stored data
  static Future<void> clearAllData() async {
    await _storage.deleteAll();
  }

  // ===== AUTHENTICATION HELPERS =====

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  /// Check if user is admin
  static Future<bool> isAdmin() async {
    final userData = await getUserData();
    return userData?['role'] == ApiConstants.adminRole;
  }

  /// Get current user role
  static Future<String?> getUserRole() async {
    final userData = await getUserData();
    return userData?['role'];
  }

  /// Get current user ID
  static Future<int?> getUserId() async {
    final userData = await getUserData();
    return userData?['id'];
  }

  /// Get current user name
  static Future<String?> getUserName() async {
    final userData = await getUserData();
    return userData?['name'];
  }

  /// Get current user email
  static Future<String?> getUserEmail() async {
    final userData = await getUserData();
    return userData?['email'];
  }

  // ===== HEALTH CHECK =====

  /// Check API health
  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await _dio.get(ApiConstants.healthCheck);
      if (response.statusCode == ApiConstants.statusOk) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Health check failed: $e');
      return null;
    }
  }

  /// Check database health
  static Future<Map<String, dynamic>?> checkDatabaseHealth() async {
    try {
      final response = await _dio.get(ApiConstants.healthDatabase);
      if (response.statusCode == ApiConstants.statusOk) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Database health check failed: $e');
      return null;
    }
  }

  /// Check cache health
  static Future<Map<String, dynamic>?> checkCacheHealth() async {
    try {
      final response = await _dio.get(ApiConstants.healthCache);
      if (response.statusCode == ApiConstants.statusOk) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Cache health check failed: $e');
      return null;
    }
  }

  // ===== UTILITY METHODS =====

  /// Get formatted error message from DioException
  static String getErrorMessage(DioException e) {
    switch (e.response?.statusCode) {
      case ApiConstants.statusBadRequest:
        return ApiConstants.validationError;
      case ApiConstants.statusUnauthorized:
        return ApiConstants.unauthorizedError;
      case ApiConstants.statusForbidden:
        return ApiConstants.forbiddenError;
      case ApiConstants.statusNotFound:
        return ApiConstants.notFoundError;
      case ApiConstants.statusConflict:
        return ApiConstants.conflictError;
      case ApiConstants.statusInternalServerError:
        return ApiConstants.serverError;
      default:
        return e.message ?? ApiConstants.networkError;
    }
  }

  /// Validate response format
  static bool isValidResponse(Map<String, dynamic> response) {
    return response.containsKey(ApiConstants.statusCodeKey) &&
        response.containsKey(ApiConstants.messageKey);
  }

  /// Extract data from API response
  static dynamic extractData(Map<String, dynamic> response) {
    if (isValidResponse(response)) {
      return response[ApiConstants.dataKey];
    }
    return null;
  }

  /// Extract error message from API response
  static String extractErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey(ApiConstants.messageKey)) {
      return response[ApiConstants.messageKey];
    }
    return 'Unknown error occurred';
  }

  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      final health = await checkHealth();
      return health != null;
    } catch (e) {
      return false;
    }
  }
}
