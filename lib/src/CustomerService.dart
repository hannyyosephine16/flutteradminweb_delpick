// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'BaseService.dart';
// import 'api_constant.dart';
//
// class CustomerService extends BaseService {
//   /// Get all customers with pagination and filtering
//   static Future<Map<String, dynamic>> getAllCustomers({
//     int page = 1,
//     int limit = 10,
//     String? search,
//     String sortBy = 'created_at',
//     String sortOrder = 'DESC',
//   }) async {
//     try {
//       final queryParams = BaseService.buildQueryParams(
//         page: page,
//         limit: limit,
//         search: search,
//         sortBy: sortBy,
//         sortOrder: sortOrder,
//       );
//
//       final response = await BaseService.get(
//         ApiConstants.customers,
//         queryParameters: queryParams,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to load customers: ${e.toString()}');
//     }
//   }
//
//   /// Get customer by ID
//   static Future<Map<String, dynamic>> getCustomerById(String id) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.customerById,
//         {'id': id},
//       );
//
//       final response = await BaseService.get(endpoint);
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to get customer: ${e.toString()}');
//     }
//   }
//
//   /// Create new customer (Admin only)
//   static Future<Map<String, dynamic>> createCustomer({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     String? imageBase64,
//   }) async {
//     try {
//       final data = {
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'password': password,
//         if (imageBase64 != null && imageBase64.isNotEmpty) 'image': imageBase64,
//       };
//
//       final response = await BaseService.post(
//         ApiConstants.customers,
//         data: data,
//       );
//
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to create customer: ${e.toString()}');
//     }
//   }
//
//   /// Update customer (Admin only)
//   static Future<Map<String, dynamic>> updateCustomer({
//     required String id,
//     required String name,
//     required String email,
//     required String phone,
//     String? imageBase64,
//   }) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.customerById,
//         {'id': id},
//       );
//
//       final data = {
//         'name': name,
//         'email': email,
//         'phone': phone,
//         if (imageBase64 != null && imageBase64.isNotEmpty) 'image': imageBase64,
//       };
//
//       final response = await BaseService.put(endpoint, data: data);
//       return BaseService.extractData(response);
//     } catch (e) {
//       throw Exception('Failed to update customer: ${e.toString()}');
//     }
//   }
//
//   /// Delete customer (Admin only)
//   static Future<bool> deleteCustomer(String id) async {
//     try {
//       final endpoint = BaseService.buildUrlWithParams(
//         ApiConstants.customerById,
//         {'id': id},
//       );
//
//       await BaseService.delete(endpoint);
//       return true;
//     } catch (e) {
//       throw Exception('Failed to delete customer: ${e.toString()}');
//     }
//   }
//
//   /// Test connection to backend
//   static Future<bool> testConnection() async {
//     return await BaseService.testConnection();
//   }
//
//   /// Diagnose connection issues
//   static Future<Map<String, String>> diagnoseConnection() async {
//     final results = <String, String>{};
//
//     try {
//       // Test base connectivity
//       final isConnected = await BaseService.testConnection();
//       results['connectivity'] = isConnected
//           ? 'Success - Backend reachable'
//           : 'Failed - Backend unreachable';
//
//       // Test authentication endpoint
//       try {
//         await BaseService.get('/health');
//         results['health_endpoint'] = 'Success - Health endpoint accessible';
//       } catch (e) {
//         results['health_endpoint'] = 'Failed - Health endpoint error: $e';
//       }
//
//       // Test customer endpoint (requires auth)
//       final token = await BaseService.getToken();
//       if (token != null) {
//         try {
//           await BaseService.get('${ApiConstants.customers}?limit=1');
//           results['customer_endpoint'] =
//               'Success - Customer endpoint accessible';
//         } catch (e) {
//           if (e.toString().contains('401')) {
//             results['customer_endpoint'] = 'Failed - Authentication required';
//           } else {
//             results['customer_endpoint'] =
//                 'Failed - Customer endpoint error: $e';
//           }
//         }
//       } else {
//         results['customer_endpoint'] = 'Skipped - No authentication token';
//       }
//     } catch (e) {
//       results['connectivity'] = 'Failed - Connection error: $e';
//     }
//
//     return results;
//   }
//
//   /// Get customer statistics (if available)
//   static Future<Map<String, dynamic>?> getCustomerStats() async {
//     try {
//       final response = await BaseService.get('${ApiConstants.customers}/stats');
//       return BaseService.extractData(response);
//     } catch (e) {
//       // Stats endpoint might not exist, return null
//       return null;
//     }
//   }
//
//   /// Search customers by name or email
//   static Future<Map<String, dynamic>> searchCustomers(
//     String query, {
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final queryParams = BaseService.buildQueryParams(
//         page: page,
//         limit: limit,
//         search: query,
//       );
//
//       final response = await BaseService.get(
//         ApiConstants.customers,
//         queryParameters: queryParams,
//       );
//
//       return response;
//     } catch (e) {
//       throw Exception('Failed to search customers: ${e.toString()}');
//     }
//   }
//
//   /// Validate customer data before submission
//   static Map<String, String?> validateCustomerData({
//     required String name,
//     required String email,
//     required String phone,
//     String? password,
//   }) {
//     Map<String, String?> errors = {};
//
//     // Name validation
//     if (name.trim().isEmpty) {
//       errors['name'] = 'Name is required';
//     } else if (name.trim().length < 2) {
//       errors['name'] = 'Name must be at least 2 characters';
//     }
//
//     // Email validation
//     if (email.trim().isEmpty) {
//       errors['email'] = 'Email is required';
//     } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
//       errors['email'] = 'Invalid email format';
//     }
//
//     // Phone validation - FIXED: Added missing closing quote and proper regex
//     if (phone.trim().isEmpty) {
//       errors['phone'] = 'Phone is required';
//     } else if (!RegExp(r'^\+?[0-9]{10,15}$')
//         .hasMatch(phone.replaceAll(' ', ''))) {
//       errors['phone'] = 'Invalid phone format';
//     }
//
//     // Password validation (for create operations)
//     if (password != null) {
//       if (password.isEmpty) {
//         errors['password'] = 'Password is required';
//       } else if (password.length < 6) {
//         errors['password'] = 'Password must be at least 6 characters';
//       }
//     }
//
//     return errors;
//   }
//
//   /// Format customer data for display
//   static Map<String, dynamic> formatCustomerData(
//       Map<String, dynamic> customer) {
//     return {
//       'id': customer['id']?.toString() ?? '',
//       'name': customer['name'] ?? 'Unknown',
//       'email': customer['email'] ?? '',
//       'phone': customer['phone'] ?? '',
//       'role': customer['role'] ?? 'customer',
//       'avatar': customer['avatar'],
//       'created_at': customer['created_at'],
//       'updated_at': customer['updated_at'],
//     };
//   }
//
//   /// Extract customer list from API response
//   static List<Map<String, dynamic>> extractCustomerList(
//       Map<String, dynamic> response) {
//     final data = BaseService.extractData(response);
//
//     if (data is Map<String, dynamic>) {
//       // If data contains customers array
//       if (data.containsKey('customers')) {
//         return List<Map<String, dynamic>>.from(data['customers'] ?? []);
//       }
//       // If data contains data array
//       else if (data.containsKey('data')) {
//         return List<Map<String, dynamic>>.from(data['data'] ?? []);
//       }
//     }
//     // If data is direct array
//     else if (data is List) {
//       return List<Map<String, dynamic>>.from(data);
//     }
//
//     return [];
//   }
//
//   /// Get pagination info from response
//   static Map<String, dynamic> extractPaginationInfo(
//       Map<String, dynamic> response) {
//     return BaseService.extractPaginationData(response);
//   }
// }
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
  static Future<Map<String, dynamic>?> getCustomerById(String id) async {
    try {
      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.customerById,
        {'id': id},
      );

      final response = await BaseService.get(endpoint);
      return response; // Return full response including data wrapper
    } catch (e) {
      print('Error getting customer by ID: $e');
      return null;
    }
  }

  /// Create new customer (Admin only)
  /// Fixed to match backend expectation
  static Future<Map<String, dynamic>?> createCustomer(
    String name,
    String email,
    String phone,
    String password,
    String? imageBase64,
  ) async {
    try {
      print('🔄 Creating customer with data:');
      print('- Name: $name');
      print('- Email: $email');
      print('- Phone: $phone');
      print('- Has image: ${imageBase64 != null}');

      // Prepare data according to backend validation schema
      final data = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      };

      // Add image only if it exists and is properly formatted
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        if (imageBase64.startsWith('data:image/')) {
          data['image'] = imageBase64;
          print('✅ Image included in request (${imageBase64.length} chars)');
        } else {
          print('⚠️ Image format invalid, skipping image upload');
        }
      }

      print('📤 Sending create customer request...');

      final response = await BaseService.post(
        ApiConstants.customers,
        data: data,
      );

      print('📥 Create customer response received');
      print('Response keys: ${response.keys}');

      if (response['statusCode'] == 201 || response['statusCode'] == 200) {
        print('✅ Customer created successfully');
        return response;
      } else {
        print('❌ Unexpected response: ${response['statusCode']}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating customer: $e');

      // More specific error handling
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        throw Exception('Email already exists. Please use a different email.');
      } else if (e.toString().contains('400') ||
          e.toString().contains('validation')) {
        throw Exception('Invalid data provided. Please check all fields.');
      } else if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please login again.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      }

      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  /// Update customer (Admin only)
  /// Fixed to match backend expectation
  static Future<Map<String, dynamic>?> updateCustomer(
    String id,
    String name,
    String email,
    String phone,
    String? currentPassword, // Not used in update, but kept for compatibility
    String? newPassword, // Not used in update, but kept for compatibility
    String? imageBase64,
  ) async {
    try {
      print('🔄 Updating customer with ID: $id');
      print('- Name: $name');
      print('- Email: $email');
      print('- Phone: $phone');
      print('- Has image: ${imageBase64 != null}');

      final endpoint = BaseService.buildUrlWithParams(
        ApiConstants.customerById,
        {'id': id},
      );

      // Prepare data according to backend validation schema
      final data = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      };

      // Add image only if it exists and is properly formatted
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        if (imageBase64.startsWith('data:image/')) {
          data['image'] = imageBase64;
          print('✅ Image included in update request');
        } else {
          print('⚠️ Image format invalid, skipping image update');
        }
      }

      print('📤 Sending update customer request...');

      final response = await BaseService.put(endpoint, data: data);

      print('📥 Update customer response received');

      if (response['statusCode'] == 200) {
        print('✅ Customer updated successfully');
        return response;
      } else {
        print('❌ Unexpected response: ${response['statusCode']}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating customer: $e');

      // More specific error handling
      if (e.toString().contains('404')) {
        throw Exception('Customer not found.');
      } else if (e.toString().contains('409') ||
          e.toString().contains('Conflict')) {
        throw Exception('Email already exists. Please use a different email.');
      } else if (e.toString().contains('400') ||
          e.toString().contains('validation')) {
        throw Exception('Invalid data provided. Please check all fields.');
      } else if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please login again.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      }

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
      print('❌ Error deleting customer: $e');

      if (e.toString().contains('404')) {
        throw Exception('Customer not found.');
      } else if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please login again.');
      } else if (e.toString().contains('403')) {
        throw Exception('Access denied. Admin privileges required.');
      }

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

    // Name validation (min 3, max 50 chars - sesuai backend validation)
    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.trim().length < 3) {
      errors['name'] = 'Name must be at least 3 characters';
    } else if (name.trim().length > 50) {
      errors['name'] = 'Name must not exceed 50 characters';
    }

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      errors['email'] = 'Invalid email format';
    }

    // Phone validation - sesuai backend pattern: /^[0-9]{10,13}$/
    if (phone.trim().isEmpty) {
      errors['phone'] = 'Phone is required';
    } else {
      final cleanPhone =
          phone.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits
      if (!RegExp(r'^[0-9]{10,13}$').hasMatch(cleanPhone)) {
        errors['phone'] = 'Phone must be 10-13 digits only';
      }
    }

    // Password validation (min 6, max 50 chars - sesuai backend validation)
    if (password != null && password.isNotEmpty) {
      if (password.length < 6) {
        errors['password'] = 'Password must be at least 6 characters';
      } else if (password.length > 50) {
        errors['password'] = 'Password must not exceed 50 characters';
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
      'fcm_token': customer['fcm_token'],
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

  /// Helper to clean phone number for backend
  static String cleanPhoneNumber(String phone) {
    // Remove all non-digit characters
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Helper to validate image format
  static bool isValidImageFormat(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) return true; // Optional

    return imageBase64.startsWith('data:image/') &&
        imageBase64.contains(';base64,');
  }
}
