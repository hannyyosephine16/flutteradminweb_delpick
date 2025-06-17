// UPDATED ApiService.dart with CORS support and better error handling

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class ApiService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _initialized = false;

  // Initialize Dio with CORS support and better configuration
  // static void initialize() {
  //   print('🔧 Initializing ApiService with base URL: ${ApiConstants.baseUrl}');
  //
  //   _dio.options.baseUrl = ApiConstants.baseUrl;
  //   _dio.options.connectTimeout = Duration(milliseconds: 30000); // 30 seconds
  //   _dio.options.receiveTimeout = Duration(milliseconds: 30000); // 30 seconds
  //   _dio.options.sendTimeout = Duration(milliseconds: 30000); // 30 seconds
  //
  //   // CORS and Headers Configuration
  //   _dio.interceptors.add(InterceptorsWrapper(
  //     onRequest: (options, handler) async {
  //       final token = await getToken();
  //
  //       // Set headers for CORS and API compatibility
  //       options.headers.addAll({
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Access-Control-Allow-Origin': '*',
  //         'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE,PATCH,OPTIONS',
  //         'Access-Control-Allow-Headers':
  //             'Origin,X-Requested-With,Content-Type,Accept,Authorization',
  //       });
  //
  //       if (token != null && !options.path.contains('/auth/login')) {
  //         options.headers['Authorization'] = 'Bearer $token';
  //       }
  //
  //       print('📤 Request: ${options.method} ${options.uri}');
  //       print('📤 Headers: ${options.headers}');
  //
  //       handler.next(options);
  //     },
  //     onResponse: (response, handler) {
  //       print(
  //           '📥 Response: ${response.statusCode} from ${response.requestOptions.uri}');
  //       handler.next(response);
  //     },
  //     onError: (error, handler) {
  //       print('❌ Error: ${error.response?.statusCode} - ${error.message}');
  //       print('❌ URL: ${error.requestOptions.uri}');
  //
  //       if (error.response?.statusCode == 404) {
  //         print('💡 404 Error - Check if backend endpoint exists');
  //         print('💡 Try different base URL in ApiConstants');
  //       } else if (error.response?.statusCode == 401) {
  //         print('💡 401 Error - Authentication required');
  //         clearToken();
  //       } else if (error.response?.statusCode == 403) {
  //         print('💡 403 Error - Forbidden, might be CORS issue');
  //       } else if (error.type == DioExceptionType.connectionError) {
  //         print('💡 Connection Error - Check internet or backend URL');
  //       }
  //
  //       handler.next(error);
  //     },
  //   ));
  //
  //   // Logging interceptor for debugging
  //   _dio.interceptors.add(LogInterceptor(
  //     requestBody: true,
  //     responseBody: true,
  //     error: true,
  //     logPrint: (object) => print('🔧 DIO: $object'),
  //   ));
  //
  //   print('✅ ApiService initialized successfully');
  // }

  /// Enhanced login with better error handling
  // static Future<Map<String, dynamic>> loginAdmin(
  //     String email, String password) async {
  //   try {
  //     print('🔐 Attempting login for: $email');
  //     print('🔗 Login URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
  //
  //     final response = await _dio.post(
  //       ApiConstants.login,
  //       data: {
  //         'email': email,
  //         'password': password,
  //       },
  //     );
  //
  //     print('📥 Login response status: ${response.statusCode}');
  //     print('📥 Login response data type: ${response.data.runtimeType}');
  //
  //     if (response.statusCode == ApiConstants.statusOk) {
  //       final responseData = response.data;
  //
  //       // Handle different response formats
  //       if (responseData is Map<String, dynamic>) {
  //         print('📄 Response keys: ${responseData.keys}');
  //
  //         // Backend format: { statusCode: 200, message: "...", data: { token, user } }
  //         if (responseData.containsKey('statusCode') &&
  //             responseData['statusCode'] == ApiConstants.statusOk &&
  //             responseData.containsKey('data')) {
  //           final data = responseData['data'] as Map<String, dynamic>;
  //           final token = data['token'];
  //           final user = data['user'];
  //
  //           print('✅ Login successful for user: ${user['name']}');
  //
  //           // Check if user is admin
  //           if (user['role'] != ApiConstants.adminRole) {
  //             throw Exception('Access denied. Admin role required.');
  //           }
  //
  //           // Save token and user data
  //           await saveToken(token);
  //           await saveUserData(user);
  //
  //           return {
  //             'success': true,
  //             'token': token,
  //             'user': user,
  //             'message': responseData['message'],
  //           };
  //         } else {
  //           throw Exception('Invalid response format from server');
  //         }
  //       } else {
  //         throw Exception('Unexpected response format');
  //       }
  //     } else {
  //       throw Exception('Login failed: HTTP ${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     print('❌ DioException: ${e.type}');
  //     print('❌ Response: ${e.response?.statusCode}');
  //     print('❌ Data: ${e.response?.data}');
  //
  //     if (e.response?.statusCode == ApiConstants.statusUnauthorized) {
  //       throw Exception('Invalid email or password');
  //     } else if (e.response?.statusCode == ApiConstants.statusBadRequest) {
  //       final errorData = e.response?.data;
  //       if (errorData is Map && errorData.containsKey('message')) {
  //         throw Exception(errorData['message']);
  //       }
  //       throw Exception('Invalid login data');
  //     } else if (e.response?.statusCode == 404) {
  //       throw Exception(
  //           'Login endpoint not found. Check backend URL configuration.');
  //     } else if (e.type == DioExceptionType.connectionError) {
  //       throw Exception(
  //           'Cannot connect to server. Check internet connection and backend URL.');
  //     }
  //     throw Exception('Login failed: ${e.message}');
  //   } catch (e) {
  //     print('❌ Unexpected error: $e');
  //     throw Exception('Login failed: $e');
  //   }
  // }
  //
  // // ===== DEBUGGING METHODS =====
  //
  // /// Test connectivity to backend
  // static Future<bool> testBackendConnectivity() async {
  //   try {
  //     print('🧪 Testing backend connectivity...');
  //
  //     final testUrls = [
  //       '${ApiConstants.baseUrl}${ApiConstants.healthCheck}',
  //       '${ApiConstants.baseUrl}/health',
  //       '${ApiConstants.baseUrl}/',
  //       ApiConstants.baseUrl,
  //     ];
  //
  //     for (String url in testUrls) {
  //       try {
  //         print('🧪 Testing: $url');
  //         final response = await _dio.get(url);
  //         print('✅ Success: $url -> ${response.statusCode}');
  //         return true;
  //       } catch (e) {
  //         print('❌ Failed: $url -> $e');
  //       }
  //     }
  //
  //     return false;
  //   } catch (e) {
  //     print('❌ Backend connectivity test failed: $e');
  //     return false;
  //   }
  // }
  //
  // /// Debug current configuration
  // static Future<void> debugConfiguration() async {
  //   print('🔍 ========== API DEBUG INFO ==========');
  //   print('📍 Base URL: ${ApiConstants.baseUrl}');
  //   print('🔗 Login URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
  //   print('🔑 Token exists: ${await getToken() != null}');
  //
  //   // Test connectivity
  //   final isConnected = await testBackendConnectivity();
  //   print('🌐 Backend reachable: $isConnected');
  //
  //   print('🔍 ========== DEBUG END ==========');
  // }
  //
  // // Rest of existing methods...
  // static Future<void> saveToken(String token) async {
  //   await _storage.write(key: ApiConstants.tokenKey, value: token);
  // }
  //
  // static Future<String?> getToken() async {
  //   return await _storage.read(key: ApiConstants.tokenKey);
  // }
  //
  // static Future<void> clearToken() async {
  //   await _storage.delete(key: ApiConstants.tokenKey);
  // }
  //
  // static Future<void> saveUserData(Map<String, dynamic> user) async {
  //   await _storage.write(key: ApiConstants.userKey, value: json.encode(user));
  // }
  //
  // static Future<Map<String, dynamic>?> getUserData() async {
  //   final userData = await _storage.read(key: ApiConstants.userKey);
  //   if (userData != null) {
  //     return json.decode(userData);
  //   }
  //   return null;
  // }
  //
  // static Future<void> clearUserData() async {
  //   await _storage.delete(key: ApiConstants.userKey);
  // }
  //
  // static Future<bool> isAuthenticated() async {
  //   final token = await getToken();
  //   return token != null;
  // }
  //
  // static Future<bool> isAdmin() async {
  //   final userData = await getUserData();
  //   return userData?['role'] == ApiConstants.adminRole;
  // }
  static void initialize() {
    if (_initialized) return;

    print('🚀 Initializing ApiService...');
    ApiConstants.printConfig();

    // ✅ NEW SYNTAX untuk Dio v5+
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: 30), // ✅ Correct syntax
      receiveTimeout: Duration(seconds: 30), // ✅ Correct syntax
      sendTimeout: Duration(seconds: 30), // ✅ Correct syntax
      headers: ApiConstants.defaultHeaders,
    );

    // ✅ REQUEST INTERCEPTOR
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();

        if (token != null && !options.path.contains('/auth/login')) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('📤 ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 ${response.statusCode} from ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.type} - ${error.message}');
        handler.next(error);
      },
    ));

    _initialized = true;
    print('✅ ApiService initialized');
  }

  // ✅ SIMPLIFIED TEST CONNECTION
  static Future<bool> testBackendConnectivity() async {
    try {
      print('🧪 Testing connection...');

      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: Duration(seconds: 10), // ✅ Correct syntax
          receiveTimeout: Duration(seconds: 10), // ✅ Correct syntax
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('✅ Backend connected: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // ✅ SIMPLIFIED LOGIN
  static Future<Map<String, dynamic>> loginAdmin(
      String email, String password) async {
    try {
      if (!_initialized) initialize();

      print('🔐 Login attempt: $email');
      print('🔗 URL: ${ApiConstants.baseUrl}${ApiConstants.login}');

      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final responseData = response.data as Map<String, dynamic>;

        // Handle different response formats
        Map<String, dynamic> data;
        if (responseData.containsKey('data') &&
            responseData['statusCode'] == 200) {
          data = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('token')) {
          data = responseData;
        } else {
          throw Exception('Invalid response format');
        }

        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (token == null || user == null) {
          throw Exception('Missing token or user data');
        }

        if (user['role'] != ApiConstants.adminRole) {
          throw Exception('Access denied. Admin role required.');
        }

        await saveToken(token);
        await saveUserData(user);

        print('✅ Login successful: ${user['name']}');

        return {
          'success': true,
          'token': token,
          'user': user,
        };
      } else {
        throw Exception('Login failed: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      _handleDioException(e);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Login failed: $e');
    }

    throw Exception('Login failed');
  }

  // ✅ SIMPLIFIED ERROR HANDLING
  static void _handleDioException(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = 'Connection failed. Check internet or try CORS proxy.';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Backend may be slow.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 401:
            errorMessage = 'Invalid email or password';
            break;
          case 403:
            errorMessage = 'Access denied. Admin role required.';
            break;
          case 404:
            errorMessage = 'Login endpoint not found. Check backend URL.';
            break;
          default:
            errorMessage = 'Server error: HTTP $statusCode';
        }
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    throw Exception(errorMessage);
  }

  // ✅ STORAGE METHODS
  static Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
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

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}
