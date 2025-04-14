class ApiConstants {
  // Base URL untuk semua API request
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1'; // Ganti dengan URL API Anda

  // Headers yang digunakan untuk setiap request
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token', // Jika menggunakan autentikasi token
  };

  // Token untuk autentikasi (bisa diubah secara dinamis setelah login)
  static String token = ''; // Biasanya diisi dari proses login

  // Helper method untuk mengatur token setelah login
  static void setToken(String newToken) {
    token = newToken;
  }

  // Endpoint URLs
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String driversEndpoint = '/drivers';
  static const String ordersEndpoint = '/orders';
  static const String ordersStatsEndpoint = '/orders/stats';
  static const String storesEndpoint = '/stores';
  static const String customersEndpoint = '/customers';

  // Timeout durations
  static const int connectionTimeout = 10000; // 10 detik
  static const int receiveTimeout = 10000; // 10 detik
}