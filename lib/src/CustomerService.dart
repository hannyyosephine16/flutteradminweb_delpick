import 'dart:convert';
import 'package:dio/dio.dart';
import 'BaseService.dart';
import 'api_constant.dart';

class CustomerService extends BaseService {
  /// Get all customers with pagination and filtering
  static Future<Map<String, dynamic>> getAllCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final response = await BaseService.get(
        ApiConstants.customers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load customers: ${e.toString()}');
    }
  }

  /// Get customer by ID
  static Future<Map<String, dynamic>> getCustomerById(String id) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.customerById,
        {'id': id},
      );

      final response = await BaseService.get(endpoint);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  /// Create new customer (Admin only)
  static Future<Map<String, dynamic>> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? imageBase64,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        if (imageBase64 != null && imageBase64.isNotEmpty) 'image': imageBase64,
      };

      final response = await BaseService.post(
        ApiConstants.customers,
        data: data,
      );

      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  /// Update customer (Admin only)
  static Future<Map<String, dynamic>> updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.customerById,
        {'id': id},
      );

      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        if (imageBase64 != null && imageBase64.isNotEmpty) 'image': imageBase64,
      };

      final response = await BaseService.put(endpoint, data: data);
      return BaseService.extractData(response);
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  /// Delete customer (Admin only)
  static Future<bool> deleteCustomer(String id) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.customerById,
        {'id': id},
      );

      await BaseService.delete(endpoint);
      return true;
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  /// Test connection to backend
  static Future<bool> testConnection() async {
    return await BaseService.testConnection();
  }

  /// Diagnose connection issues
  static Future<Map<String, String>> diagnoseConnection() async {
    final results = <String, String>{};

    try {
      // Test base connectivity
      final isConnected = await BaseService.testConnection();
      results['connectivity'] = isConnected
          ? 'Success - Backend reachable'
          : 'Failed - Backend unreachable';

      // Test authentication endpoint
      try {
        await BaseService.get('/health');
        results['health_endpoint'] = 'Success - Health endpoint accessible';
      } catch (e) {
        results['health_endpoint'] = 'Failed - Health endpoint error: $e';
      }

      // Test customer endpoint (requires auth)
      final token = await BaseService.getToken();
      if (token != null) {
        try {
          await BaseService.get('${ApiConstants.customers}?limit=1');
          results['customer_endpoint'] =
              'Success - Customer endpoint accessible';
        } catch (e) {
          if (e.toString().contains('401')) {
            results['customer_endpoint'] = 'Failed - Authentication required';
          } else {
            results['customer_endpoint'] =
                'Failed - Customer endpoint error: $e';
          }
        }
      } else {
        results['customer_endpoint'] = 'Skipped - No authentication token';
      }
    } catch (e) {
      results['connectivity'] = 'Failed - Connection error: $e';
    }

    return results;
  }

  /// Get customer statistics (if available)
  static Future<Map<String, dynamic>?> getCustomerStats() async {
    try {
      final response = await BaseService.get('${ApiConstants.customers}/stats');
      return BaseService.extractData(response);
    } catch (e) {
      // Stats endpoint might not exist, return null
      return null;
    }
  }

  /// Search customers by name or email
  static Future<Map<String, dynamic>> searchCustomers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = BaseService.buildQueryParams(
        page: page,
        limit: limit,
        search: query,
      );

      final response = await BaseService.get(
        ApiConstants.customers,
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }

  /// Validate customer data before submission
  static Map<String, String?> validateCustomerData({
    required String name,
    required String email,
    required String phone,
    String? password,
  }) {
    Map<String, String?> errors = {};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      errors['email'] = 'Invalid email format';
    }

    // Phone validation - FIXED: Added missing closing quote and proper regex
    if (phone.trim().isEmpty) {
      errors['phone'] = 'Phone is required';
    } else if (!RegExp(r'^\+?[0-9]{10,15}$')
        .hasMatch(phone.replaceAll(' ', ''))) {
      errors['phone'] = 'Invalid phone format';
    }

    // Password validation (for create operations)
    if (password != null) {
      if (password.isEmpty) {
        errors['password'] = 'Password is required';
      } else if (password.length < 6) {
        errors['password'] = 'Password must be at least 6 characters';
      }
    }

    return errors;
  }

  /// Format customer data for display
  static Map<String, dynamic> formatCustomerData(
      Map<String, dynamic> customer) {
    return {
      'id': customer['id']?.toString() ?? '',
      'name': customer['name'] ?? 'Unknown',
      'email': customer['email'] ?? '',
      'phone': customer['phone'] ?? '',
      'role': customer['role'] ?? 'customer',
      'avatar': customer['avatar'],
      'created_at': customer['created_at'],
      'updated_at': customer['updated_at'],
    };
  }

  /// Extract customer list from API response
  static List<Map<String, dynamic>> extractCustomerList(
      Map<String, dynamic> response) {
    final data = BaseService.extractData(response);

    if (data is Map<String, dynamic>) {
      // If data contains customers array
      if (data.containsKey('customers')) {
        return List<Map<String, dynamic>>.from(data['customers'] ?? []);
      }
      // If data contains data array
      else if (data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
    }
    // If data is direct array
    else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    return [];
  }

  /// Get pagination info from response
  static Map<String, dynamic> extractPaginationInfo(
      Map<String, dynamic> response) {
    return BaseService.extractPaginationData(response);
  }
}
