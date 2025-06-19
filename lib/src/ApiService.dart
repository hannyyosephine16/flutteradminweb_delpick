// FIXED ApiService.dart untuk format respons backend yang sebenarnya

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class ApiService {
  static final Dio _dio = Dio();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    print('🚀 Initializing ApiService...');
    print('📍 Base URL: ${ApiConstants.baseUrl}');

    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'DelPick-Admin-Flutter',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );

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
        print(
            '📥 Response: ${response.statusCode} from ${response.requestOptions.uri}');
        print('📥 Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.type} - ${error.message}');
        if (error.response != null) {
          print('❌ Status: ${error.response?.statusCode}');
          print('❌ Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));

    _initialized = true;
    print('✅ ApiService initialized');
  }

  // ✅ FIXED: Login method untuk format respons backend yang sebenarnya
  static Future<Map<String, dynamic>> loginAdmin(
      String email, String password) async {
    try {
      if (!_initialized) initialize();

      print('🔐 Starting login process...');
      print('📧 Email: $email');
      print('🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.login}');

      final requestData = {
        'email': email,
        'password': password,
      };

      print('📤 Request Data: $requestData');

      final response = await _dio.post(
        ApiConstants.login,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📥 Raw Response Status: ${response.statusCode}');
      print('📥 Raw Response Data: ${response.data}');

      if (response.statusCode == 200) {
        return _handleActualBackendResponse(response.data);
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException caught: ${e.type}');
      _handleDioException(e);
    } catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Login failed: $e');
    }

    throw Exception('Login failed');
  }

  // ✅ NEW: Handler khusus untuk format respons backend yang sebenarnya
  static Map<String, dynamic> _handleActualBackendResponse(
      dynamic responseData) {
    print('🔍 Processing actual backend response...');

    if (responseData == null) {
      throw Exception('Empty response from server');
    }

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Response is not a JSON object');
    }

    final response = responseData as Map<String, dynamic>;
    print('📋 Response keys: ${response.keys.toList()}');

    // ✅ FIXED: Handle format backend yang sebenarnya
    // Format: { "message": "Login berhasil", "data": { "token": "...", "user": {...} } }

    if (!response.containsKey('message')) {
      throw Exception('Response missing required "message" field');
    }

    if (!response.containsKey('data')) {
      throw Exception('Response missing required "data" field');
    }

    final message = response['message'] as String;
    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Data field is not a valid object');
    }

    final dataMap = data as Map<String, dynamic>;

    // ✅ Extract token dan user dari data field
    final token = dataMap['token'] as String?;
    final user = dataMap['user'] as Map<String, dynamic>?;

    if (token == null || token.isEmpty) {
      throw Exception('No token found in response data');
    }

    if (user == null) {
      throw Exception('No user data found in response');
    }

    // ✅ Check user role
    final userRole = user['role'] as String?;
    if (userRole != 'admin') {
      throw Exception(
          'Access denied. Admin role required. Current role: $userRole');
    }

    print('✅ Login successful for user: ${user['name']} (${user['role']})');

    // ✅ Save data
    saveToken(token);
    saveUserData(user);

    // ✅ Return dalam format yang diharapkan Flutter
    return {
      'success': true,
      'token': token,
      'user': user,
      'message': message,
    };
  }

  // ✅ Enhanced error handling
  static void _handleDioException(DioException e) {
    String errorMessage;

    print('📊 DioException Details:');
    print('   Type: ${e.type}');
    print('   Message: ${e.message}');
    print('   Status Code: ${e.response?.statusCode}');
    print('   Response Data: ${e.response?.data}');

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = '''
🌐 Connection Error!

Possible solutions:
1. Check internet connection
2. Verify backend URL: ${ApiConstants.baseUrl}
3. For development, try running with CORS disabled:
   flutter run -d chrome --web-browser-flag="--disable-web-security"
4. Check if backend server is running
''';
        break;

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request timeout. Backend may be slow or unreachable.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // ✅ Handle backend error response format
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            if (errors is String) {
              errorMessage = errors;
            } else if (errors is List && errors.isNotEmpty) {
              errorMessage = errors.first.toString();
            } else {
              errorMessage = 'Server returned an error';
            }
          } else {
            errorMessage = _getDefaultErrorMessage(statusCode);
          }
        } else {
          errorMessage = _getDefaultErrorMessage(statusCode);
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;

      default:
        // ✅ Check for CORS-specific errors
        if (e.message?.toLowerCase().contains('xmlhttprequest') == true ||
            e.message?.toLowerCase().contains('cors') == true) {
          errorMessage = '''
🚨 CORS Error Detected!

This is a browser security restriction. Solutions:

🔧 For Development:
1. Run with: flutter run -d chrome --web-browser-flag="--disable-web-security"
2. Add to VS Code launch.json args: ["--web-browser-flag=--disable-web-security"]

🏭 For Production:
1. Configure backend CORS headers
2. Deploy to same domain as frontend
''';
        } else {
          errorMessage = 'Network error: ${e.message}';
        }
    }

    throw Exception(errorMessage);
  }

  static String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'Access denied. Admin role required.';
      case 404:
        return 'Login endpoint not found. Please check backend configuration.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'Server error: HTTP ${statusCode ?? 'unknown'}';
    }
  }

  // ✅ Test backend connectivity
  static Future<bool> testBackendConnectivity() async {
    try {
      print('🧪 Testing backend connectivity...');

      final response = await _dio.get(
        ApiConstants.health,
        options: Options(
          sendTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final isHealthy = response.statusCode == 200;
      print(
          '🏥 Backend health: ${isHealthy ? '✅ Healthy' : '❌ Unhealthy'} (${response.statusCode})');
      return isHealthy;
    } catch (e) {
      print('❌ Backend connectivity test failed: $e');

      // ✅ Try basic connectivity test
      try {
        print('🔄 Trying basic connectivity test...');
        final response = await _dio.get(
          '/',
          options: Options(
            sendTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 5),
            validateStatus: (status) => status != null,
          ),
        );
        print('🔄 Basic test result: ${response.statusCode}');
        return response.statusCode != null && response.statusCode! < 500;
      } catch (e2) {
        print('❌ All connectivity tests failed');
        return false;
      }
    }
  }

  // ✅ Storage methods
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

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }

  // ✅ Debug helper
  static Future<void> debugApiConfiguration() async {
    print('🔧 ========== API DEBUG INFO ==========');
    print('📍 Base URL: ${ApiConstants.baseUrl}');
    print('🔗 Login URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
    print('🏥 Health URL: ${ApiConstants.baseUrl}${ApiConstants.health}');
    print('🔑 Has Token: ${await getToken() != null}');
    print('🌐 Backend Reachable: ${await testBackendConnectivity()}');
    print('🔧 ========== END DEBUG INFO ==========');
  }

  // ✅ Test login endpoint specifically
  static Future<bool> testLoginEndpoint() async {
    try {
      print('🧪 Testing login endpoint...');

      // Make an OPTIONS request to test CORS
      final response = await _dio.options(
        ApiConstants.login,
        options: Options(
          sendTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          validateStatus: (status) => status != null,
        ),
      );

      print('🧪 OPTIONS response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Login endpoint test failed: $e');
      return false;
    }
  }
}
