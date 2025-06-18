// // FIXED: api_constant.dart untuk backend URL: https://delpick.horas-code.my.id/api/v1/
//
// class ApiConstants {
//   // ✅ CONFIRMED BASE URLS
//   static const String productionUrl = 'https://delpick.horas-code.my.id/api/v1';
//   static const String developmentUrl = 'http://localhost:6100/api/v1';
//   static const String stagingUrl =
//       'https://staging.delpick.horas-code.my.id/api/v1';
//   static const String backendUrl = 'https://delpick.horas-code.my.id/api/v1';
//
//   // ✅ FIXED: Always use production URL for hosted backend
//   // static String get baseUrl {
//   //   // For now, always use production since backend is hosted
//   //   return productionUrl;
//   //
//   //   // Original environment-based logic (uncomment if needed):
//   //   // const environment = String.fromEnvironment('ENV', defaultValue: 'production');
//   //   // switch (environment) {
//   //   //   case 'development':
//   //   //     return developmentUrl;
//   //   //   case 'staging':
//   //   //     return stagingUrl;
//   //   //   default:
//   //   //     return productionUrl;
//   //   // }
//   // }
//   static String get baseUrl {
//     // Untuk development, gunakan CORS proxy
//     const bool isDevelopment = true; // Set ke false untuk production
//
//     if (isDevelopment) {
//       return '$backendUrl'; // https://cors-anywhere.herokuapp.com/https://delpick.horas-code.my.id/api/v1
//     } else {
//       return backendUrl; // Direct ke backend (untuk production)
//     }
//   }
//
//   // API Version
//   static const String apiVersion = 'v1';
//
//   // Request timeouts - increased for hosted backend
//   static const int connectTimeout = 30000; // 30 seconds
//   static const int receiveTimeout = 30000; // 30 seconds
//   static const int sendTimeout = 30000; // 30 seconds
//
//   // Storage keys
//   static const String tokenKey = 'auth_token';
//   static const String userKey = 'user_data';
//   static const String refreshTokenKey = 'refresh_token';
//
//   // ✅ CONFIRMED API ENDPOINTS (based on backend routes)
//   static const String auth = '/auth';
//   static const String customers = '/customers';
//   static const String drivers = '/drivers';
//   static const String stores = '/stores';
//   static const String orders = '/orders';
//   static const String menu = '/menu';
//   static const String driverRequests = '/driver-requests';
//   static const String health = '/health';
//
//   // ✅ CONFIRMED Auth endpoints
//   static const String login = '$auth/login'; // /auth/login
//   static const String logout = '$auth/logout'; // /auth/logout
//   static const String register = '$auth/register'; // /auth/register
//   static const String profile = '$auth/profile'; // /auth/profile
//   static const String forgotPassword =
//       '$auth/forgot-password'; // /auth/forgot-password
//   static const String resetPassword =
//       '$auth/reset-password'; // /auth/reset-password
//   static const String verifyEmail = '$auth/verify-email'; // /auth/verify-email
//   static const String resendVerification =
//       '$auth/resend-verification'; // /auth/resend-verification
//
//   // ✅ CONFIRMED Driver endpoints
//   static const String allDrivers = drivers; // /drivers
//   static const String driverById = '$drivers/{id}'; // /drivers/{id}
//   static const String driverStatus =
//       '$drivers/{id}/status'; // /drivers/{id}/status
//   static const String driverLocation =
//       '$drivers/{id}/location'; // /drivers/{id}/location
//
//   // ✅ CONFIRMED Customer endpoints
//   static const String allCustomers = customers; // /customers
//   static const String customerById = '$customers/{id}'; // /customers/{id}
//
//   // ✅ CONFIRMED Store endpoints
//   static const String allStores = stores; // /stores
//   static const String storeById = '$stores/{id}'; // /stores/{id}
//
//   // ✅ CONFIRMED Menu endpoints
//   static const String allMenuItems = menu; // /menu
//   static const String menuByStore =
//       '$menu/store/{store_id}'; // /menu/store/{store_id}
//   static const String menuItemById = '$menu/{id}'; // /menu/{id}
//   static const String menuItemStatus = '$menu/{id}/status'; // /menu/{id}/status
//
//   // ✅ CONFIRMED Order endpoints
//   static const String allOrders = orders; // /orders
//   static const String orderById = '$orders/{id}'; // /orders/{id}
//   static const String customerOrders =
//       '$orders/customer/orders'; // /orders/customer/orders
//   static const String storeOrders =
//       '$orders/store/orders'; // /orders/store/orders
//   static const String orderStatus =
//       '$orders/{id}/status'; // /orders/{id}/status
//   static const String orderReview =
//       '$orders/{id}/review'; // /orders/{id}/review
//
//   // ✅ CONFIRMED Tracking endpoints
//   static const String orderTracking =
//       '$orders/{id}/tracking'; // /orders/{id}/tracking
//   static const String trackingStart =
//       '$orders/{id}/tracking/start'; // /orders/{id}/tracking/start
//   static const String trackingComplete =
//       '$orders/{id}/tracking/complete'; // /orders/{id}/tracking/complete
//   static const String trackingLocation =
//       '$orders/{id}/tracking/location'; // /orders/{id}/tracking/location
//   static const String trackingHistory =
//       '$orders/{id}/tracking/history'; // /orders/{id}/tracking/history
//
//   // ✅ CONFIRMED Driver Request endpoints
//   static const String allDriverRequests = driverRequests; // /driver-requests
//   static const String driverRequestById =
//       '$driverRequests/{id}'; // /driver-requests/{id}
//   static const String respondDriverRequest =
//       '$driverRequests/{id}/respond'; // /driver-requests/{id}/respond
//
//   // ✅ CONFIRMED Health endpoints
//   static const String healthCheck = '$health'; // /health
//   static const String healthDatabase = '$health/db'; // /health/db
//   static const String healthCache = '$health/cache'; // /health/cache
//   static const String healthStorage = '$health/storage'; // /health/storage
//
//   // HTTP Status Codes
//   static const int statusOk = 200;
//   static const int statusCreated = 201;
//   static const int statusAccepted = 202;
//   static const int statusNoContent = 204;
//   static const int statusBadRequest = 400;
//   static const int statusUnauthorized = 401;
//   static const int statusForbidden = 403;
//   static const int statusNotFound = 404;
//   static const int statusConflict = 409;
//   static const int statusUnprocessableEntity = 422;
//   static const int statusInternalServerError = 500;
//
//   // ✅ FIXED: Headers optimized for hosted backend
//   static Map<String, String> get defaultHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'User-Agent': 'DelPick-Admin-Flutter',
//       };
//
//   static Map<String, String> authHeaders(String token) => {
//         ...defaultHeaders,
//         'Authorization': 'Bearer $token',
//       };
//
//   // ✅ CONFIRMED: Response keys sesuai backend format
//   static const String statusCodeKey = 'statusCode';
//   static const String messageKey = 'message';
//   static const String dataKey = 'data';
//   static const String errorsKey = 'errors';
//
//   // ✅ CONFIRMED: Pagination keys sesuai backend format (snake_case)
//   static const String totalItemsKey = 'total_items';
//   static const String totalPagesKey = 'total_pages';
//   static const String currentPageKey = 'current_page';
//
//   // Default pagination values
//   static const int defaultPage = 1;
//   static const int defaultLimit = 10;
//   static const int maxLimit = 100;
//
//   // File upload limits
//   static const int maxFileSize = 5 * 1024 * 1024; // 5MB
//   static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
//
//   static String buildUrl(String endpoint) => '$baseUrl$endpoint';
//
//   static String buildUrlWithParams(
//       String endpoint, Map<String, String> params) {
//     String result = endpoint;
//     params.forEach((key, value) {
//       result = result.replaceAll('{$key}', value);
//     });
//     return buildUrl(result);
//   }
//
//   static Map<String, dynamic> buildQueryParams({
//     int? page,
//     int? limit,
//     String? search,
//     String? sortBy,
//     String? sortOrder,
//   }) {
//     final params = <String, dynamic>{};
//     if (page != null) params['page'] = page;
//     if (limit != null) params['limit'] = limit;
//     if (search != null && search.isNotEmpty) params['search'] = search;
//     if (sortBy != null) params['sortBy'] = sortBy;
//     if (sortOrder != null) params['sortOrder'] = sortOrder;
//     return params;
//   }
//
//   static void printConfig() {
//     print('🔧 ========== API CONFIGURATION ==========');
//     print('📍 Base URL: $baseUrl');
//     print('🔐 Login URL: $baseUrl$login');
//     print(
//         '🚨 CORS Proxy: ${baseUrl.contains('cors-anywhere') ? 'ENABLED' : 'DISABLED'}');
//     print('🔧 ========== END CONFIGURATION ==========');
//   }
//
//   // ✅ CONFIRMED: Status values sesuai backend enum
//   static const List<String> orderStatuses = [
//     'pending',
//     'confirmed',
//     'preparing',
//     'ready_for_pickup',
//     'on_delivery',
//     'delivered',
//     'cancelled'
//   ];
//
//   static const List<String> deliveryStatuses = [
//     'pending',
//     'picked_up',
//     'on_way',
//     'delivered'
//   ];
//
//   static const List<String> driverStatuses = ['active', 'inactive', 'busy'];
//   static const List<String> storeStatuses = ['active', 'inactive', 'closed'];
//
//   // ✅ CONFIRMED: User roles sesuai backend
//   static const String adminRole = 'admin';
//   static const String storeRole = 'store';
//   static const String driverRole = 'driver';
//   static const String customerRole = 'customer';
//
//   // Error messages
//   static const String networkError = 'Network connection error';
//   static const String serverError = 'Internal server error';
//   static const String unauthorizedError = 'Authentication required';
//   static const String forbiddenError = 'Access denied';
//   static const String notFoundError = 'Resource not found';
//   static const String validationError = 'Validation failed';
//   static const String conflictError = 'Resource already exists';
//
//   // Success messages
//   static const String loginSuccess = 'Login successful';
//   static const String logoutSuccess = 'Logout successful';
//   static const String createSuccess = 'Created successfully';
//   static const String updateSuccess = 'Updated successfully';
//   static const String deleteSuccess = 'Deleted successfully';
//
//   // Utility methods
//   static String replacePathParams(String path, Map<String, String> params) {
//     String result = path;
//     params.forEach((key, value) {
//       result = result.replaceAll('{$key}', value);
//     });
//     return result;
//   }
//
//   // static String buildUrl(String endpoint) {
//   //   return '$baseUrl$endpoint';
//   // }
//   //
//   // static String buildUrlWithParams(
//   //     String endpoint, Map<String, String> params) {
//   //   final path = replacePathParams(endpoint, params);
//   //   return buildUrl(path);
//   // }
//
//   // static Map<String, dynamic> buildQueryParams({
//   //   int? page,
//   //   int? limit,
//   //   String? search,
//   //   String? sortBy,
//   //   String? sortOrder,
//   //   Map<String, dynamic>? additionalParams,
//   // }) {
//   //   final params = <String, dynamic>{};
//   //
//   //   if (page != null) params['page'] = page;
//   //   if (limit != null) params['limit'] = limit;
//   //   if (search != null && search.isNotEmpty) params['search'] = search;
//   //   if (sortBy != null) params['sortBy'] = sortBy;
//   //   if (sortOrder != null) params['sortOrder'] = sortOrder;
//   //
//   //   if (additionalParams != null) {
//   //     params.addAll(additionalParams);
//   //   }
//   //
//   //   return params;
//   // }
//
//   // ✅ ADDED: Debug helpers for hosted backend
//   static void printCurrentConfig() {
//     print('📍 Current Backend URL: $baseUrl');
//     print('🔗 Login Endpoint: $baseUrl$login');
//     print('🏥 Health Endpoint: $baseUrl$healthCheck');
//   }
//
//   // Validate status codes
//   static bool isSuccessStatusCode(int statusCode) {
//     return statusCode >= 200 && statusCode < 300;
//   }
//
//   static bool isClientError(int statusCode) {
//     return statusCode >= 400 && statusCode < 500;
//   }
//
//   static bool isServerError(int statusCode) {
//     return statusCode >= 500;
//   }
//
//   static String getErrorMessage(int statusCode) {
//     switch (statusCode) {
//       case statusBadRequest:
//         return validationError;
//       case statusUnauthorized:
//         return unauthorizedError;
//       case statusForbidden:
//         return forbiddenError;
//       case statusNotFound:
//         return notFoundError;
//       case statusConflict:
//         return conflictError;
//       case statusInternalServerError:
//         return serverError;
//       default:
//         return 'Unknown error occurred';
//     }
//   }
// }
class ApiConstants {
  // Base URLs
  static const String productionUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String developmentUrl = 'http://localhost:5000/api/v1';
  static const String stagingUrl =
      'https://staging.delpick.horas-code.my.id/api/v1';

  // Current environment
  static String get baseUrl {
    const environment =
        String.fromEnvironment('ENV', defaultValue: 'production');
    switch (environment) {
      case 'development':
        return developmentUrl;
      case 'staging':
        return stagingUrl;
      default:
        return productionUrl;
    }
  }

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // Auth endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String register = '$auth/register';
  static const String profile = '$auth/profile';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';
  static const String resendVerification = '$auth/resend-verification';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '$users/profile';
  static const String userNotifications = '$users/notifications';

  // Customer endpoints
  static const String customers = '/customers';
  static const String customerById = '$customers/{id}';

  // Driver endpoints
  static const String drivers = '/drivers';
  static const String driverById = '$drivers/{id}';
  static const String driverStatus = '$drivers/{id}/status';
  static const String driverLocation = '$drivers/{id}/location';

  // Store endpoints
  static const String stores = '/stores';
  static const String storeById = '$stores/{id}';

  // Menu endpoints
  static const String menu = '/menu';
  static const String menuByStore = '$menu/store/{store_id}';
  static const String menuItemById = '$menu/{id}';
  static const String menuItemStatus = '$menu/{id}/status';

  // Order endpoints
  static const String orders = '/orders';
  static const String orderById = '$orders/{id}';
  static const String customerOrders = '$orders/customer/orders';
  static const String storeOrders = '$orders/store/orders';
  static const String orderStatus = '$orders/{id}/status';
  static const String orderReview = '$orders/{id}/review';

  // Tracking endpoints
  static const String orderTracking = '$orders/{id}/tracking';
  static const String trackingStart = '$orders/{id}/tracking/start';
  static const String trackingComplete = '$orders/{id}/tracking/complete';
  static const String trackingLocation = '$orders/{id}/tracking/location';
  static const String trackingHistory = '$orders/{id}/tracking/history';

  // Driver Request endpoints
  static const String driverRequests = '/driver-requests';
  static const String driverRequestById = '$driverRequests/{id}';
  static const String respondDriverRequest = '$driverRequests/{id}/respond';

  // Health endpoints
  static const String health = '/health';
  static const String healthDatabase = '$health/db';
  static const String healthCache = '$health/cache';
  static const String healthStorage = '$health/storage';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusUnprocessableEntity = 422;
  static const int statusInternalServerError = 500;

  // Response keys (sesuai backend format)
  static const String statusCodeKey = 'statusCode';
  static const String messageKey = 'message';
  static const String dataKey = 'data';
  static const String errorsKey = 'errors';

  // Pagination keys (sesuai backend format)
  static const String totalItemsKey = 'totalItems';
  static const String totalPagesKey = 'totalPages';
  static const String currentPageKey = 'currentPage';

  // User roles (sesuai backend enum)
  static const String adminRole = 'admin';
  static const String storeRole = 'store';
  static const String driverRole = 'driver';
  static const String customerRole = 'customer';

  // Order statuses (sesuai backend enum)
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'on_delivery',
    'delivered',
    'cancelled'
  ];

  // Delivery statuses (sesuai backend enum)
  static const List<String> deliveryStatuses = [
    'pending',
    'picked_up',
    'on_way',
    'delivered'
  ];

  // Driver statuses (sesuai backend enum)
  static const List<String> driverStatuses = ['active', 'inactive', 'busy'];

  // Store statuses (sesuai backend enum)
  static const List<String> storeStatuses = ['active', 'inactive', 'closed'];

  // Default headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'DelPick-Admin-Flutter',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // Default pagination
  static const int defaultPage = 1;
  static const int defaultLimit = 10;
  static const int maxLimit = 100;

  // File upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

  // Timeout values
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Utility methods
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  static String buildUrlWithParams(
      String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return buildUrl(result);
  }

  static Map<String, dynamic> buildQueryParams({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;

    if (additionalParams != null) {
      params.addAll(additionalParams);
    }

    return params;
  }

  static void printConfig() {
    print('🔧 ========== API CONFIGURATION ==========');
    print('📍 Base URL: $baseUrl');
    print('🔐 Login URL: $baseUrl$login');
    print('🏥 Health URL: $baseUrl$health');
    print('🔧 ========== END CONFIGURATION ==========');
  }

  // Response validation
  static bool isValidResponse(Map<String, dynamic> response) {
    return response.containsKey(statusCodeKey) &&
        response.containsKey(messageKey);
  }

  static bool isSuccessResponse(Map<String, dynamic> response) {
    final statusCode = response[statusCodeKey];
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  static String getErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey(messageKey)) {
      return response[messageKey];
    } else if (response.containsKey(errorsKey)) {
      final errors = response[errorsKey];
      if (errors is String) return errors;
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
    }
    return 'Unknown error occurred';
  }

  static dynamic extractData(Map<String, dynamic> response) {
    return response[dataKey];
  }

  // Error messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Internal server error';
  static const String unauthorizedError = 'Authentication required';
  static const String forbiddenError = 'Access denied';
  static const String notFoundError = 'Resource not found';
  static const String validationError = 'Validation failed';
  static const String conflictError = 'Resource already exists';

  // Success messages
  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logout successful';
  static const String createSuccess = 'Created successfully';
  static const String updateSuccess = 'Updated successfully';
  static const String deleteSuccess = 'Deleted successfully';
}
