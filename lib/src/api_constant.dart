// lib/src/api_constant.dart
class ApiConstants {
  // Base URLs - Environment based
  static const String productionUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String developmentUrl = 'http://localhost:6100/api/v1';
  static const String stagingUrl =
      'https://staging.delpick.horas-code.my.id/api/v1';

  // Get current base URL
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

  // API Version
  static const String apiVersion = 'v1';

  // Request timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // API Endpoints
  static const String auth = '/auth';
  static const String customers = '/customers';
  static const String drivers = '/drivers';
  static const String stores = '/stores';
  static const String orders = '/orders';
  static const String menu = '/menu';
  static const String driverRequests = '/driver-requests';
  static const String health = '/health';

  // Auth endpoints
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String register = '$auth/register';
  static const String profile = '$auth/profile';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';
  static const String resendVerification = '$auth/resend-verification';

  // Driver endpoints
  static const String allDrivers = drivers;
  static const String driverById = '$drivers/{id}';
  static const String driverStatus = '$drivers/{id}/status';
  static const String driverLocation = '$drivers/{id}/location';

  // Customer endpoints
  static const String allCustomers = customers;
  static const String customerById = '$customers/{id}';

  // Store endpoints
  static const String allStores = stores;
  static const String storeById = '$stores/{id}';

  // Menu endpoints
  static const String allMenuItems = menu;
  static const String menuByStore = '$menu/store/{store_id}';
  static const String menuItemById = '$menu/{id}';
  static const String menuItemStatus = '$menu/{id}/status';

  // Order endpoints
  static const String allOrders = orders;
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
  static const String allDriverRequests = driverRequests;
  static const String driverRequestById = '$driverRequests/{id}';
  static const String respondDriverRequest = '$driverRequests/{id}/respond';

  // Health endpoints
  static const String healthCheck = '$health';
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

  // Request headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // Response keys - sesuai dengan backend response format
  static const String statusCodeKey = 'statusCode';
  static const String messageKey = 'message';
  static const String dataKey = 'data';
  static const String errorsKey = 'errors';

  // Pagination keys
  static const String totalItemsKey = 'totalItems';
  static const String totalPagesKey = 'totalPages';
  static const String currentPageKey = 'currentPage';

  // Default pagination values
  static const int defaultPage = 1;
  static const int defaultLimit = 10;
  static const int maxLimit = 100;

  // File upload limits
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

  // Order status values - sesuai dengan backend enum
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'on_delivery',
    'delivered',
    'cancelled'
  ];

  // Delivery status values
  static const List<String> deliveryStatuses = [
    'pending',
    'picked_up',
    'on_way',
    'delivered'
  ];

  // Driver status values
  static const List<String> driverStatuses = ['active', 'inactive', 'busy'];

  // Store status values
  static const List<String> storeStatuses = ['active', 'inactive', 'closed'];

  // User roles
  static const String adminRole = 'admin';
  static const String storeRole = 'store';
  static const String driverRole = 'driver';
  static const String customerRole = 'customer';

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

  // Utility methods
  static String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  // Build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Build URL with path parameters
  static String buildUrlWithParams(
      String endpoint, Map<String, String> params) {
    final path = replacePathParams(endpoint, params);
    return buildUrl(path);
  }

  // Build query parameters
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

  // Validate status codes
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500;
  }

  // Get error message based on status code
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case statusBadRequest:
        return validationError;
      case statusUnauthorized:
        return unauthorizedError;
      case statusForbidden:
        return forbiddenError;
      case statusNotFound:
        return notFoundError;
      case statusConflict:
        return conflictError;
      case statusInternalServerError:
        return serverError;
      default:
        return 'Unknown error occurred';
    }
  }
}
