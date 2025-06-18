// lib/src/api_index.dart
// Export all API related files for easy import

// Core API files
import '../src/api_config.dart';
import 'BaseService.dart';
import 'api_constant.dart';

export 'api_constant.dart';
export 'ApiHelper.dart';
export 'ApiService.dart';
export 'BaseService.dart';
export 'api_config.dart';

// Individual services would be in separate files, but here's the structure:

/*
// To use these services, create separate files:

// lib/services/auth_service.dart
// lib/services/customer_service.dart
// lib/services/driver_service.dart
// lib/services/store_service.dart
// lib/services/menu_service.dart
// lib/services/order_service.dart
// lib/services/tracking_service.dart
// lib/services/driver_request_service.dart
// lib/services/health_service.dart

// Then import like this:
// import 'package:your_app/src/api_index.dart';
// import 'package:your_app/services/customer_service.dart';

// Usage example:
void main() async {
  // Initialize services
  BaseService.initialize();

  // Test connection
  final isConnected = await HealthService.isBackendHealthy();
  print('Backend health: $isConnected');

  // Login admin
  try {
    final response = await AuthService.login('admin@example.com', 'password');
    print('Login successful: ${response['user']['name']}');
  } catch (e) {
    print('Login failed: $e');
  }

  // Get customers
  try {
    final response = await CustomerService.getCustomers(page: 1, limit: 10);
    final customers = response['data'];
    print('Customers: ${customers.length}');
  } catch (e) {
    print('Get customers failed: $e');
  }
}
*/

// API Response wrapper for consistent handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    final success = json['statusCode'] >= 200 && json['statusCode'] < 300;

    return ApiResponse<T>(
      success: success,
      statusCode: json['statusCode'] ?? 500,
      message: json['message'] ?? 'Unknown error',
      data: success && json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      errors: json['errors'],
      pagination: {
        'totalItems': json['totalItems'],
        'totalPages': json['totalPages'],
        'currentPage': json['currentPage'],
      },
    );
  }

  factory ApiResponse.success(T data,
      {String message = 'Success', int statusCode = 200}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message,
      {int statusCode = 500, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasPagination => pagination != null;
}

// API Exception for better error handling
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode = 500, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final responseData = error.response.data;
      return ApiException(
        responseData['message'] ?? 'Unknown server error',
        statusCode: error.response.statusCode ?? 500,
        errors: responseData['errors'],
      );
    } else {
      return ApiException('Network error: ${error.message}');
    }
  }
}

// Pagination helper class
class PaginationInfo {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
  })  : hasNextPage = currentPage < totalPages,
        hasPreviousPage = currentPage > 1;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      itemsPerPage: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}

// Service initialization helper
class ApiServiceManager {
  static bool _initialized = false;

  static Future<void> initialize({
    bool enableLogging = false,
    String? customBaseUrl,
  }) async {
    if (_initialized) return;

    // Print configuration
    AppConfig.printConfiguration();

    // Initialize base service
    BaseService.initialize();

    // Test connection
    final isHealthy = await BaseService.testConnection();
    print(
        '🏥 Backend health check: ${isHealthy ? '✅ Healthy' : '❌ Unhealthy'}');

    _initialized = true;
    print('✅ API Services initialized successfully');
  }

  static bool get isInitialized => _initialized;

  static Future<bool> testAllServices() async {
    try {
      // Test each critical service
      await BaseService.testConnection();
      return true;
    } catch (e) {
      print('❌ Service test failed: $e');
      return false;
    }
  }

  static void debugConfiguration() {
    print('🔧 ========== API DEBUG INFO ==========');
    print('📱 App: ${AppConfig.appName} v${AppConfig.appVersion}');
    print('🌍 Environment: ${AppConfig.environment}');
    print('📍 Base URL: ${AppConfig.baseUrl}');
    print('🔧 Initialized: $_initialized');
    print('🔧 ========== END DEBUG INFO ==========');
  }
}

// Helper functions for common operations
class ApiHelper {
  static Map<String, dynamic> parseResponse(Map<String, dynamic> response) {
    return {
      'success': ApiConstants.isSuccessResponse(response),
      'data': ApiConstants.extractData(response),
      'message': response[ApiConstants.messageKey],
      'pagination': {
        'totalItems': response[ApiConstants.totalItemsKey],
        'totalPages': response[ApiConstants.totalPagesKey],
        'currentPage': response[ApiConstants.currentPageKey],
      },
    };
  }

  static String formatErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return error.toString();
    }
  }

  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }

  static bool isAuthError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 401;
    }
    return false;
  }
}
