import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomerService {
  static const String baseUrl = 'http://127.0.0.1:5000/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Get all customers with proper error handling
  static Future<Map<String, dynamic>?> getAllCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'ASC',
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    print('🔄 Fetching customers - Page: $page, Limit: $limit');
    print('🔗 URL: $baseUrl/customers');
    print('🔑 Token: ${token.substring(0, 20)}...');

    final dio = Dio();

    // Configure timeouts properly
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 30);

    // Enable logging for debugging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

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

      final response = await dio.get(
        '$baseUrl/customers',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Data Keys: ${response.data?.keys}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Log response structure for debugging
        if (responseData is Map<String, dynamic>) {
          print('✅ Response is Map');
          print('📋 Response keys: ${responseData.keys.toList()}');

          // Check if response has the expected structure
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            print('📦 Data keys: ${data?.keys}');

            // Check if data contains customers array
            if (data is Map<String, dynamic> && data.containsKey('customers')) {
              print('👥 Customers array length: ${data['customers']?.length}');
              print('📈 Total items: ${data['totalItems']}');

              // Return the full response for UI to process
              return responseData;
            } else {
              print('⚠️  Data does not contain customers array');
              print('📄 Data content: $data');

              // If data is directly the customers array (alternative backend format)
              if (data is List) {
                return {
                  'message': 'Success',
                  'data': {
                    'customers': data,
                    'totalItems': data.length,
                    'totalPages': 1,
                    'currentPage': 1,
                  }
                };
              }
            }
          } else {
            print('⚠️  Response does not contain data key');
            print('📄 Full response: $responseData');

            // If response is directly the array (alternative format)
            if (responseData is List) {
              return {
                'message': 'Success',
                'data': {
                  'customers': responseData,
                  'totalItems': responseData.length,
                  'totalPages': 1,
                  'currentPage': 1,
                }
              };
            }
          }
        }

        // If we reach here, the response format is unexpected
        throw Exception(
            'Unexpected response format: ${responseData.runtimeType}');
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Error Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Admin role required.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('API endpoint not found. Check server URL.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Check if server is running.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to fetch customers: $e');
    }
  }

  /// Get customer by ID
  static Future<Map<String, dynamic>?> getCustomerById(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    print('🔄 Fetching customer by ID: $id');

    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 30);

    try {
      final response = await dio.get(
        '$baseUrl/customers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('📊 Get Customer Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Return the full response to match expected format
          return responseData;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Customer not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access denied. Admin role required.');
      }
      throw Exception('Failed to fetch customer: ${e.message}');
    }
  }

  /// Create customer
  static Future<Map<String, dynamic>?> createCustomer(
      String username,
      String email,
      String phone,
      String newPassword,
      String? imageBase64) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    print('🔄 Creating customer: $email');

    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 30);

    try {
      final requestData = {
        'name': username,
        'email': email,
        'phone': phone,
        'password': newPassword,
      };

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        requestData['image'] = imageBase64;
      }

      final response = await dio.post(
        '$baseUrl/customers',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['message'] ?? 'Validation error';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create customer: ${e.message}');
    }
  }

  /// Update customer
  static Future<Map<String, dynamic>?> updateCustomer(
      String id,
      String name,
      String email,
      String phone,
      String currentPassword,
      String newPassword,
      String? imageBase64) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    print('🔄 Updating customer: $id');

    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 30);

    try {
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'phone': phone
      };

      if (newPassword.isNotEmpty) {
        requestData['password'] = newPassword;
      }

      if (imageBase64 != null && imageBase64.isNotEmpty) {
        requestData['image'] = imageBase64;
      }

      final response = await dio.put(
        '$baseUrl/customers/$id',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Customer not found');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['message'] ?? 'Validation error';
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update customer: ${e.message}');
    }
  }

  /// Delete customer
  static Future<bool> deleteCustomer(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    print('🔄 Deleting customer: $id');

    final dio = Dio();
    dio.options.connectTimeout = Duration(seconds: 10);
    dio.options.receiveTimeout = Duration(seconds: 30);

    try {
      final response = await dio.delete(
        '$baseUrl/customers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete customer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Customer not found');
      }
      throw Exception('Failed to delete customer: ${e.message}');
    }
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Helper method untuk debugging
  static Future<void> debugApiConnection() async {
    print('🔍 ========== API DEBUG ==========');

    final token = await getToken();
    print('🔑 Token exists: ${token != null}');

    if (token != null) {
      print('🔑 Token preview: ${token.substring(0, 20)}...');

      try {
        final dio = Dio();
        dio.options.connectTimeout = Duration(seconds: 5);
        dio.options.receiveTimeout = Duration(seconds: 10);

        final response = await dio.get(
          '$baseUrl/customers?limit=1',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        print('✅ API connection successful');
        print('📊 Status: ${response.statusCode}');
        print('📄 Response type: ${response.data.runtimeType}');
        print('📄 Response keys: ${response.data?.keys}');
      } catch (e) {
        print('❌ API connection failed: $e');
      }
    }

    print('🔍 ========== DEBUG END ==========');
  }
}
