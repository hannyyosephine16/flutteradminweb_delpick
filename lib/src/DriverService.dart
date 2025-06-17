import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';

class DriverService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Configure Dio with CORS handling
  static Dio _createDioClient() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(seconds: 15);
    dio.options.receiveTimeout = Duration(seconds: 30);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
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

  // ===== ADMIN OPERATIONS =====

  /// Get all drivers - Admin only
  static Future<Map<String, dynamic>?> getAllDrivers({
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
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstants.drivers,
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Get driver by ID - Admin only
  static Future<Map<String, dynamic>?> getDriverById(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(ApiConstants.driverById, {'id': id}),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Create driver - Admin only
  static Future<Map<String, dynamic>?> createDriver(
    String name,
    String email,
    String password,
    String phone,
    String licenseNumber,
    String vehiclePlate,
    String? avatar,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'license_number': licenseNumber,
        'vehicle_plate': vehiclePlate,
        if (avatar != null) 'avatar': avatar,
      };

      final response = await dio.post(
        ApiConstants.drivers,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['statusCode'] == 201) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Update driver - Admin only
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
      final response = await dio.put(
        ApiConstants.buildUrlWithParams(ApiConstants.driverById, {'id': id}),
        data: driverData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Delete driver - Admin only
  static Future<Map<String, dynamic>?> deleteDriver(String id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as admin.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.delete(
        ApiConstants.buildUrlWithParams(ApiConstants.driverById, {'id': id}),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  // ===== DRIVER SELF-MANAGEMENT OPERATIONS =====

  /// Update driver location - Driver only
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
      final response = await dio.put(
        '${ApiConstants.drivers}/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Update driver status - Driver only
  static Future<Map<String, dynamic>?> updateDriverStatus(String status) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.put(
        '${ApiConstants.drivers}/status',
        data: {'status': status},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Update driver profile - Driver only
  static Future<Map<String, dynamic>?> updateDriverProfile(
    Map<String, dynamic> profileData,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login as driver.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.put(
        '${ApiConstants.drivers}/update',
        data: profileData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Get driver orders - Driver only
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
      final response = await dio.get(
        '${ApiConstants.drivers}/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  /// Get driver location for tracking
  static Future<Map<String, dynamic>?> getDriverLocation(
      String driverId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication required. Please login.');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.driverLocation, {'id': driverId}),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData['data'];
        }
        throw Exception('Invalid response format: ${responseData['message']}');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
    return null;
  }

  // ===== UTILITY METHODS =====

  static Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

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

  static void _handleDioException(DioException e) {
    String errorMessage;
    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage =
            'Connection failed. Check network or CORS configuration.';
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
    throw Exception(errorMessage);
  }
}
