class AppConfig {
  // Environment settings
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'production');
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  static const bool isStaging = environment == 'staging';

  // API Configuration
  static const String productionBaseUrl =
      'https://delpick.horas-code.my.id/api/v1';
  static const String stagingBaseUrl =
      'https://staging.delpick.horas-code.my.id/api/v1';
  static const String developmentBaseUrl = 'http://localhost:5000/api/v1';

  static String get baseUrl {
    switch (environment) {
      case 'development':
        return developmentBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      default:
        return productionBaseUrl;
    }
  }

  // API Version
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String settingsKey = 'app_settings';

  // Network Configuration
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  static const int minPageSize = 1;

  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt'
  ];

  // App Information
  static const String appName = 'DelPick Admin';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCaching = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = isProduction;

  // Cache Configuration
  static const int cacheExpiration = 3600; // 1 hour in seconds
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB

  // Theme Configuration
  static const String defaultTheme = 'light';
  static const List<String> availableThemes = ['light', 'dark', 'system'];

  // Language Configuration
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'id'];

  // Security Configuration
  static const int sessionTimeout = 3600; // 1 hour in seconds
  static const bool enableBiometric = true;
  static const bool enableAutoLogout = true;

  // Database Configuration (for local storage)
  static const String databaseName = 'delpick_admin.db';
  static const int databaseVersion = 1;

  // Error Handling
  static const int maxRetryAttempts = 3;
  static const int retryDelayMilliseconds = 1000;

  // Date & Time Format
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Debug Configuration
  static bool get enableDebugMode => isDevelopment;
  static bool get enableVerboseLogging => isDevelopment;

  // Helper methods
  static bool isValidEnvironment(String env) {
    return ['development', 'staging', 'production'].contains(env);
  }

  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': '$appName/$appVersion',
        'X-App-Version': appVersion,
        'X-Platform': 'flutter',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // Utility methods
  static void printConfiguration() {
    if (enableDebugMode) {
      print('🔧 ========== APP CONFIGURATION ==========');
      print('📱 App: $appName v$appVersion');
      print('🌍 Environment: $environment');
      print('📍 Base URL: $baseUrl');
      print('🔒 Security: ${enableBiometric ? 'Enabled' : 'Disabled'}');
      print('📊 Analytics: ${enableAnalytics ? 'Enabled' : 'Disabled'}');
      print('💾 Caching: ${enableCaching ? 'Enabled' : 'Disabled'}');
      print('🔧 ========== END CONFIGURATION ==========');
    }
  }

  static bool get isDebugMode {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  static String getConfigSummary() {
    return '''
App Configuration:
- Name: $appName
- Version: $appVersion
- Environment: $environment
- Base URL: $baseUrl
- Debug Mode: $isDebugMode
- Features: ${_getEnabledFeatures().join(', ')}
    ''';
  }

  static List<String> _getEnabledFeatures() {
    final features = <String>[];
    if (enableLogging) features.add('Logging');
    if (enableCaching) features.add('Caching');
    if (enablePushNotifications) features.add('Push Notifications');
    if (enableAnalytics) features.add('Analytics');
    if (enableBiometric) features.add('Biometric Auth');
    return features;
  }

  static bool isValidName(String name) {
    return name.length >= minNameLength && name.length <= maxNameLength;
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength &&
        password.length <= maxPasswordLength;
  }

  // Environment-specific configurations
  static Map<String, dynamic> get environmentConfig {
    switch (environment) {
      case 'development':
        return {
          'logLevel': 'debug',
          'enableMocking': true,
          'enableTestData': true,
          'connectTimeout': 10000,
        };
      case 'staging':
        return {
          'logLevel': 'info',
          'enableMocking': false,
          'enableTestData': false,
          'connectTimeout': 20000,
        };
      default:
        return {
          'logLevel': 'error',
          'enableMocking': false,
          'enableTestData': false,
          'connectTimeout': 30000,
        };
    }
  }

  // Error codes mapping
  static const Map<int, String> errorMessages = {
    400: 'Bad Request',
    401: 'Unauthorized',
    403: 'Forbidden',
    404: 'Not Found',
    409: 'Conflict',
    422: 'Validation Error',
    500: 'Internal Server Error',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Timeout',
  };

  static String getErrorMessage(int statusCode) {
    return errorMessages[statusCode] ?? 'Unknown Error';
  }
}
