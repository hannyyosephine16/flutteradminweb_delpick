class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String localUrl = 'http://localhost:6100/api/v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String storesEndpoint = '/stores';
  static const String driversEndpoint = '/drivers';
  static const String customersEndpoint = '/customers';
  static const String ordersEndpoint = '/orders';
  static const String menuEndpoint = '/menu';
  static const String trackingEndpoint = '/tracking';

  // App Settings
  static const String appName = 'DelPick Admin';
  static const String version = '1.0.0';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Roles
  static const String adminRole = 'admin';
  static const String storeRole = 'store';
  static const String driverRole = 'driver';
  static const String customerRole = 'customer';

  // Order Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'on_delivery',
    'delivered',
    'cancelled'
  ];

  // Driver Status
  static const List<String> driverStatuses = [
    'active',
    'inactive',
    'busy'
  ];

  // Store Status
  static const List<String> storeStatuses = [
    'active',
    'inactive',
    'closed'
  ];
}