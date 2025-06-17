import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverService {
  // Production backend URL
  static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Configure Dio with CORS handling
  static Dio _createDioClient() {
    final dio = Dio();

    // Configure timeouts
    dio.options.connectTimeout = Duration(seconds: 15);
    dio.options.receiveTimeout = Duration(seconds: 30);

    // Add interceptor to handle CORS
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add necessary headers
        options.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });

        print('📤 Request: ${options.method} ${options.uri}');
        print('📤 Headers: ${options.headers}');

        handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 Response: ${response.statusCode} ${response.statusMessage}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Error: ${error.type} - ${error.message}');

        // Handle CORS errors specifically
        if (error.type == DioExceptionType.connectionError ||
            error.message?.contains('CORS') == true ||
            error.message?.contains('Cross-Origin') == true) {
          print('🔧 CORS Error detected. Trying alternative approach...');

          // You could implement fallback logic here
          // For now, just provide a clearer error message
          final corsError = DioException(
            requestOptions: error.requestOptions,
            type: DioExceptionType.connectionError,
            message:
                'CORS Error: Backend needs to allow origin from localhost:55111',
          );
          handler.next(corsError);
        } else {
          handler.next(error);
        }
      },
    ));

    // Add logging interceptor
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
      // Test 1: Basic connectivity
      final dio = _createDioClient();

      final response = await dio.get('$baseUrl/drivers');
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
              results['solution'] = 'Check if backend is running at $baseUrl';
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

  // ===== ADMIN OPERATIONS (Following Customer Pattern) =====

  /// Get all drivers with enhanced error handling - Admin only
  static Future<Map<String, dynamic>?> getAllDrivers({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'ASC',
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      print('📞 Calling: $baseUrl/drivers');

      final response = await dio.get(
        '$baseUrl/drivers',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          if (data.containsKey('drivers') && data['drivers'] is List) {
            print('✅ Successfully fetched ${data['drivers'].length} drivers');
            return responseData;
          } else {
            throw Exception('Invalid response format: missing drivers array');
          }
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Provide specific error messages based on error type
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue. '
              'Please ensure the backend at $baseUrl allows requests from localhost:55111';
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
          } else {
            errorMessage =
                'Server error: ${e.response?.statusCode} - ${e.response?.data}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get driver by ID with enhanced error handling - Admin only
  static Future<Map<String, dynamic>?> getDriverById(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/$id');

      final response = await dio.get(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully fetched driver with ID: $id');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Admin role required.';
          } else if (e.response?.statusCode == 404) {
            errorMessage = 'Driver not found.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create driver with enhanced error handling - Admin only
  static Future<Map<String, dynamic>?> createDriver(
      String name,
      String email,
      String password,
      String phone,
      String vehicleNumber,
      String? imageBase64) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers (POST)');

      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'vehicle_number': vehicleNumber,
        'image': imageBase64,
      };

      final response = await dio.post(
        '$baseUrl/drivers',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        print('✅ Successfully created driver');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            final responseData = e.response?.data;
            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            } else {
              errorMessage = 'Invalid data provided.';
            }
          } else if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Admin role required.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update driver with enhanced error handling - Admin only
  static Future<Map<String, dynamic>?> updateDriver(
    String id,
    Map<String, dynamic> driverData,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/$id (PUT)');

      final response = await dio.put(
        '$baseUrl/drivers/$id',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully updated driver with ID: $id');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            final responseData = e.response?.data;
            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            } else {
              errorMessage = 'Invalid data provided.';
            }
          } else if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Admin role required.';
          } else if (e.response?.statusCode == 404) {
            errorMessage = 'Driver not found.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete driver with enhanced error handling - Admin only
  static Future<Map<String, dynamic>?> deleteDriver(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/$id (DELETE)');

      final response = await dio.delete(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully deleted driver with ID: $id');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Admin role required.';
          } else if (e.response?.statusCode == 404) {
            errorMessage = 'Driver not found.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ===== DRIVER SELF-MANAGEMENT OPERATIONS =====

  /// Update driver location with enhanced error handling - Driver only
  static Future<Map<String, dynamic>?> updateDriverLocation(
    double latitude,
    double longitude,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/location/update (PUT)');

      final response = await dio.put(
        '$baseUrl/drivers/location/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully updated driver location');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Driver role required.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update driver status with enhanced error handling - Driver only
  static Future<Map<String, dynamic>?> updateDriverStatus(String status) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/status/update (PUT)');

      final response = await dio.put(
        '$baseUrl/drivers/status/update',
        data: {'status': status},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully updated driver status to: $status');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            errorMessage =
                'Invalid status value. Must be active, inactive, or busy.';
          } else if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Driver role required.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update driver profile with enhanced error handling - Driver only
  static Future<Map<String, dynamic>?> updateDriverProfile(
    Map<String, dynamic> profileData,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/profile/update (PUT)');

      final response = await dio.put(
        '$baseUrl/drivers/profile/update',
        data: profileData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully updated driver profile');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 400) {
            final responseData = e.response?.data;
            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            } else {
              errorMessage = 'Invalid data provided.';
            }
          } else if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Driver role required.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get driver orders with enhanced error handling - Driver only
  static Future<Map<String, dynamic>?> getDriverOrders({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/orders/my');

      final response = await dio.get(
        '$baseUrl/drivers/orders/my',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully fetched driver orders');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'Access denied. Driver role required.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ===== TRACKING OPERATIONS =====

  /// Get driver location for tracking with enhanced error handling
  static Future<Map<String, dynamic>?> getDriverLocation(
      String driverId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login.');
    }

    final dio = _createDioClient();

    try {
      print('📞 Calling: $baseUrl/drivers/$driverId/location');

      final response = await dio.get(
        '$baseUrl/drivers/$driverId/location',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Successfully fetched driver location');
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = 'Connection failed. This is likely a CORS issue.';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'Authentication failed. Please login again.';
          } else if (e.response?.statusCode == 404) {
            errorMessage = 'Driver location not found or not available.';
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ===== UTILITY METHODS =====

  /// Token management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Quick connection test
  static Future<bool> testConnection() async {
    try {
      final dio = _createDioClient();
      final response = await dio.get('$baseUrl/');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Validate driver data before sending
  static bool validateDriverData(Map<String, dynamic> data) {
    final requiredFields = ['name', 'email', 'phone'];

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
}
