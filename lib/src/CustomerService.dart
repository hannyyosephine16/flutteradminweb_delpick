import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomerService {
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Create customer
  static Future<Map<String, dynamic>> createCustomer(
      String username,
      String email,
      String phone,
      String newPassword,
      String? imageBase64) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();
    request.open('POST', '$baseUrl/customers');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token');

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      try {
        if (request.status == 201) {
          final Map<String, dynamic> response =
              json.decode(request.responseText!);
          // Backend response format: {message, data, errors}
          completer.complete(response['data'] ?? response);
        } else {
          final errorResponse = json.decode(request.responseText ?? '{}');
          final errorMessage =
              errorResponse['message'] ?? 'Failed to create customer';
          completer.completeError(Exception(errorMessage));
        }
      } catch (e) {
        completer.completeError(
            Exception('Failed to create customer: ${request.statusText}'));
      }
    });

    final data = jsonEncode({
      'name': username,
      'email': email,
      'phone': phone,
      'password': newPassword,
      'image': imageBase64,
    });

    request.send(data);
    return completer.future;
  }

  // Update customer
  static Future<Map<String, dynamic>> updateCustomer(
      String id,
      String name,
      String email,
      String phone,
      String currentPassword,
      String newPassword,
      String? imageBase64) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found, please login first');
    }

    final request = html.HttpRequest();
    request.open('PUT', '$baseUrl/customers/$id');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token');

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      try {
        if (request.status == 200) {
          final Map<String, dynamic> response =
              json.decode(request.responseText!);
          completer.complete(response['data'] ?? response);
        } else {
          final errorResponse = json.decode(request.responseText ?? '{}');
          final errorMessage =
              errorResponse['message'] ?? 'Failed to update customer';
          completer.completeError(Exception(errorMessage));
        }
      } catch (e) {
        completer.completeError(
            Exception('Failed to update customer: ${request.statusText}'));
      }
    });

    final Map<String, dynamic> dataToSend = {
      'name': name,
      'email': email,
      'phone': phone
    };

    if (newPassword.isNotEmpty) {
      dataToSend['password'] = newPassword;
    }

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      dataToSend['image'] = imageBase64;
    }

    request.send(jsonEncode(dataToSend));
    return completer.future;
  }

  // Get customer by ID
  static Future<Map<String, dynamic>> getCustomerById(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();
    request.open('GET', '$baseUrl/customers/$id');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token');

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      try {
        if (request.status == 200) {
          final Map<String, dynamic> response =
              json.decode(request.responseText!);
          completer.complete(response['data'] ?? response);
        } else {
          final errorResponse = json.decode(request.responseText ?? '{}');
          final errorMessage =
              errorResponse['message'] ?? 'Customer tidak ditemukan';
          completer.completeError(Exception(errorMessage));
        }
      } catch (e) {
        completer.completeError(Exception(
            'Gagal mendapatkan data customer: ${request.statusText}'));
      }
    });

    request.send();
    return completer.future;
  }

  // Get all customers with proper pagination handling
  static Future<Map<String, dynamic>> getAllCustomers(
      int page, int limit) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/customers?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Backend response format: {message, data: {totalItems, totalPages, currentPage, customers}}
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to load customers: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching customers: $e');
      throw e;
    }
  }

  // Delete customer
  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

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
        final responseData = response.data;
        return responseData['data'] ?? responseData;
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
}
