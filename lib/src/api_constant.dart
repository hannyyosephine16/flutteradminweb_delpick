// Updated api_constant.dart untuk format respons backend yang sebenarnya

class ApiConstants {
  // Environment Configuration
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'production');
  static const bool isDevelopment = environment == 'development';
  static const bool isProduction = environment == 'production';

  // Base URLs
  static const String productionUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String developmentUrl = 'http://localhost:5000/api/v1';
  static const String stagingUrl =
      'https://staging.delpick.horas-code.my.id/api/v1';

  // Current environment base URL
  static String get baseUrl {
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

  // ✅ UPDATED: Response keys sesuai format backend yang sebenarnya
  // Format backend: { "message": "Login berhasil", "data": { "token": "...", "user": {...} } }
  static const String messageKey = 'message';
  static const String dataKey = 'data';
  static const String errorsKey = 'errors';
  static const String statusCodeKey = 'statusCode'; // Kept for compatibility

  // ✅ UPDATED: Pagination keys (sesuai format backend)
  static const String totalItemsKey = 'totalItems';
  static const String totalPagesKey = 'totalPages';
  static const String currentPageKey = 'currentPage';

  // ✅ Alternative pagination keys (jika backend menggunakan snake_case)
  static const String totalItemsSnakeKey = 'total_items';
  static const String totalPagesSnakeKey = 'total_pages';
  static const String currentPageSnakeKey = 'current_page';

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
        if (isDevelopment) ...{
          'Cache-Control': 'no-cache',
        },
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
    print('🌍 Environment: $environment');
    print('📍 Base URL: $baseUrl');
    print('🔐 Login URL: $baseUrl$login');
    print('🏥 Health URL: $baseUrl$health');
    print('⏱️ Timeout: ${connectTimeout}ms');
    print('🔧 ========== END CONFIGURATION ==========');
  }

  // ✅ UPDATED: Response validation untuk format backend yang sebenarnya
  static bool isValidResponse(Map<String, dynamic> response) {
    // ✅ Format backend yang sebenarnya: { "message": "...", "data": {...} }
    if (response.containsKey(messageKey)) {
      return true;
    }

    // ✅ Format direct auth response: { "token": "...", "user": {...} }
    if (response.containsKey('token') && response.containsKey('user')) {
      return true;
    }

    // ✅ Legacy format support: { "statusCode": 200, "message": "...", "data": {...} }
    if (response.containsKey(statusCodeKey) &&
        response.containsKey(messageKey)) {
      return true;
    }

    return false;
  }

  static bool isSuccessResponse(Map<String, dynamic> response) {
    // ✅ Check HTTP status first (this should be handled at HTTP level)
    // If statusCode exists in response, check it
    if (response.containsKey(statusCodeKey)) {
      final statusCode = response[statusCodeKey];
      return statusCode == statusOk || statusCode == statusCreated;
    }

    // ✅ For actual backend format, if we get a response with message, it's usually success
    // Backend only returns response with message on success, errors are handled differently
    if (response.containsKey(messageKey)) {
      return true;
    }

    // ✅ Direct auth format with token means success
    if (response.containsKey('token')) {
      return true;
    }

    return false;
  }

  // ✅ UPDATED: Extract data dari format backend yang sebenarnya
  static dynamic extractData(Map<String, dynamic> response) {
    // ✅ Format: { "message": "...", "data": {...} }
    if (response.containsKey(dataKey)) {
      return response[dataKey];
    }

    // ✅ Format direct: { "token": "...", "user": {...} }
    if (response.containsKey('token')) {
      return response;
    }

    // ✅ Fallback: return whole response
    return response;
  }

  // ✅ UPDATED: Extract error message dari format backend yang sebenarnya
  static String getErrorMessage(Map<String, dynamic> response) {
    // ✅ Check message field first
    if (response.containsKey(messageKey)) {
      return response[messageKey].toString();
    }

    // ✅ Check errors field
    if (response.containsKey(errorsKey)) {
      final errors = response[errorsKey];
      if (errors is String) return errors;
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
    }

    // ✅ Fallback to status code mapping
    final statusCode = response[statusCodeKey];
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
      case statusUnprocessableEntity:
        return validationError;
      case statusInternalServerError:
        return serverError;
      default:
        return 'An error occurred';
    }
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

  // ✅ NEW: Backend response format examples for documentation
  static const Map<String, dynamic> exampleLoginResponse = {
    "message": "Login berhasil",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": 1,
        "name": "Admin",
        "email": "admin@delpick.com",
        "role": "admin",
        "phone": "0812345678",
        "fcm_token": null,
        "avatar": "/uploads/users/avatar_1750164718970.jpeg",
        "created_at": "2025-06-16T01:04:38.000Z",
        "updated_at": "2025-06-17T12:51:58.000Z"
      }
    }
  };

  static const Map<String, dynamic> exampleErrorResponse = {
    "message": "Invalid email or password",
    "errors": "Authentication failed"
  };

  // ✅ Helper methods untuk debugging
  static void logResponseFormat(Map<String, dynamic> response) {
    print('📊 === RESPONSE FORMAT ANALYSIS ===');
    print('📊 Keys: ${response.keys.toList()}');
    print('📊 Has Message: ${response.containsKey(messageKey)}');
    print('📊 Has Data: ${response.containsKey(dataKey)}');
    print('📊 Has StatusCode: ${response.containsKey(statusCodeKey)}');
    print('📊 Is Valid: ${isValidResponse(response)}');
    print('📊 Is Success: ${isSuccessResponse(response)}');
    print('📊 === END ANALYSIS ===');
  }

  // ✅ Helper untuk validasi struktur respons login
  static bool isValidLoginResponse(Map<String, dynamic> response) {
    if (!isValidResponse(response)) return false;

    final data = extractData(response);
    if (data is! Map<String, dynamic>) return false;

    final dataMap = data as Map<String, dynamic>;
    return dataMap.containsKey('token') && dataMap.containsKey('user');
  }

  /// Format currency (Indonesian Rupiah)
  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format time for display
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format datetime for display
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// Get order status display text
  static String getOrderStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'on_delivery':
        return 'On Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Get driver status display text
  static String getDriverStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'busy':
        return 'Busy';
      default:
        return 'Unknown';
    }
  }
}
