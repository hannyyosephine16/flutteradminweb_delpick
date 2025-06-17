// lib/Common/AppConfig.dart - Update yang sudah ada
class AppConfig {
  // Environment
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'development');

  // API Configuration - Dynamic based on environment
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://delpick.horas-code.my.id/api/v1';
      case 'staging':
        return 'https://staging.delpick.horas-code.my.id/api/v1';
      default:
        return 'http://localhost:6100/api/v1';
    }
  }

  // Tetap sama seperti sebelumnya...
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
// ... rest of the config
}
