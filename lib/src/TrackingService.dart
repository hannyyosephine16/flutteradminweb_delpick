import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constant.dart';
import 'dart:math' as math;

class TrackingService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Dio _createDioClient() {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        print('❌ TrackingService Error: ${error.message}');
        handler.next(error);
      },
    ));

    return dio;
  }

  // ✅ Get tracking data for order (untuk customer dan driver)
  static Future<Map<String, dynamic>> getTrackingData(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.orderTracking, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle backend response format
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('statusCode') &&
              responseData['statusCode'] == 200) {
            return responseData;
          } else {
            return responseData;
          }
        } else {
          throw Exception(
              'Format response tidak valid: ${responseData.runtimeType}');
        }
      } else {
        throw Exception(
            'Gagal mengambil data tracking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengambil data tracking');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Start delivery (untuk driver)
  static Future<Map<String, dynamic>> startDelivery(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.post(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingStart, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception('Gagal memulai pengantaran: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'memulai pengantaran');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Complete delivery (untuk driver)
  static Future<Map<String, dynamic>> completeDelivery(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.post(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingComplete, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'Gagal menyelesaikan pengantaran: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'menyelesaikan pengantaran');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Update driver location (untuk driver)
  static Future<Map<String, dynamic>> updateDriverLocation(
      String orderId, double latitude, double longitude) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.put(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingLocation, {'id': orderId}),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'Gagal mengupdate lokasi driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengupdate lokasi driver');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Get tracking history (untuk customer dan driver)
  static Future<Map<String, dynamic>> getTrackingHistory(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.buildUrlWithParams(
            ApiConstants.trackingHistory, {'id': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        return responseData;
      } else {
        throw Exception(
            'Gagal mengambil riwayat tracking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengambil riwayat tracking');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Update driver location secara real-time (tanpa order ID)
  static Future<Map<String, dynamic>> updateDriverLocationRealtime(
      double latitude, double longitude) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      // Berdasarkan backend, endpoint ini ada di drivers routes
      final response = await dio.patch(
        '${ApiConstants.drivers}/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        throw Exception('API Error: ${responseData['message']}');
      } else {
        throw Exception(
            'Gagal mengupdate lokasi driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengupdate lokasi driver real-time');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Get all active orders dengan tracking (untuk admin)
  static Future<Map<String, dynamic>> getAllActiveOrdersWithTracking({
    int page = 1,
    int limit = 10,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      final response = await dio.get(
        ApiConstants.orders,
        queryParameters: ApiConstants.buildQueryParams(
          page: page,
          limit: limit,
          additionalParams: {
            'order_status':
                'on_delivery', // Filter order yang sedang dalam pengantaran
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('statusCode') &&
              responseData['statusCode'] == 200) {
            return responseData;
          } else {
            return responseData;
          }
        } else if (responseData is List) {
          return {
            'statusCode': 200,
            'message': 'Success',
            'data': responseData,
            'totalItems': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };
        } else {
          throw Exception(
              'Format response tidak valid: ${responseData.runtimeType}');
        }
      } else {
        throw Exception(
            'Gagal mengambil data order aktif: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengambil data order aktif');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Get driver active orders (untuk driver)
  static Future<Map<String, dynamic>> getDriverActiveOrders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = _createDioClient();

    try {
      // Menggunakan endpoint driver requests untuk mendapatkan order yang assigned ke driver
      final response = await dio.get(ApiConstants.driverRequests);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['statusCode'] == 200) {
          return responseData;
        }
        return responseData;
      } else {
        throw Exception(
            'Gagal mengambil order aktif driver: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'mengambil order aktif driver');
    }
    throw Exception('Terjadi kesalahan yang tidak terduga');
  }

  // ✅ Calculate estimated delivery time
  static Map<String, dynamic> calculateEstimatedTime({
    required double driverLat,
    required double driverLng,
    required double storeLat,
    required double storeLng,
    required double customerLat,
    required double customerLng,
  }) {
    // Implementasi sederhana kalkulasi jarak menggunakan Haversine formula
    final distanceToStore =
        _calculateDistance(driverLat, driverLng, storeLat, storeLng);
    final distanceToCustomer =
        _calculateDistance(storeLat, storeLng, customerLat, customerLng);

    // Asumsi kecepatan rata-rata 30 km/jam
    const averageSpeed = 30.0; // km/h
    const preparationTime = 10; // minutes

    final timeToStore = (distanceToStore / averageSpeed) * 60; // dalam menit
    final timeToCustomer =
        (distanceToCustomer / averageSpeed) * 60; // dalam menit

    final totalPickupTime = timeToStore + preparationTime;
    final totalDeliveryTime = totalPickupTime + timeToCustomer;

    final now = DateTime.now();
    final estimatedPickupTime =
        now.add(Duration(minutes: totalPickupTime.round()));
    final estimatedDeliveryTime =
        now.add(Duration(minutes: totalDeliveryTime.round()));

    return {
      'distance_to_store': distanceToStore,
      'distance_to_customer': distanceToCustomer,
      'estimated_pickup_time': estimatedPickupTime.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime.toIso8601String(),
      'pickup_duration_minutes': totalPickupTime.round(),
      'delivery_duration_minutes': timeToCustomer.round(),
    };
  }

  // ✅ Haversine formula untuk menghitung jarak
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // ✅ Helper method untuk format tracking update
  static Map<String, dynamic> formatTrackingUpdate({
    required String status,
    required String message,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  }) {
    final Map<String, dynamic> trackingUpdate = {
      'timestamp': DateTime.now().toIso8601String(),
      'status': status,
      'message': message,
    };

    if (latitude != null && longitude != null) {
      trackingUpdate['location'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    if (additionalData != null) {
      trackingUpdate.addAll(additionalData);
    }

    return trackingUpdate;
  }

  // ===== UTILITY METHODS =====

  static Future<String?> _getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  static void _handleDioException(DioException e, String operation) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionError:
        errorMessage = 'Koneksi gagal. Periksa koneksi internet Anda.';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Koneksi timeout. Server mungkin lambat atau tidak dapat dijangkau.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Server response timeout. Request membutuhkan waktu terlalu lama.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          errorMessage = 'Unauthorized: Harap login ulang';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Forbidden: Akses tidak diizinkan';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Resource tidak ditemukan';
        } else if (e.response?.statusCode == 400) {
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Data request tidak valid';
          }
        } else {
          final responseData = e.response?.data;
          if (responseData is Map && responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        }
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    throw Exception('Gagal $operation: $errorMessage');
  }

  /// Test connection to backend
  static Future<bool> testConnection() async {
    try {
      final dio = _createDioClient();
      final response = await dio.get(
          ApiConstants.health); // ✅ Fixed: gunakan 'health' bukan 'healthCheck'
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Validate tracking data
  static bool validateTrackingData(Map<String, dynamic> data) {
    final requiredFields = ['order_id'];

    for (String field in requiredFields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          data[field].toString().trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  /// Get tracking status display name
  static String getTrackingStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'picked_up':
        return 'Telah Diambil';
      case 'on_way':
        return 'Dalam Perjalanan';
      case 'delivered':
        return 'Telah Sampai';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  /// Get order status display name
  static String getOrderStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'preparing':
        return 'Sedang Diproses';
      case 'ready_for_pickup':
        return 'Siap Diambil';
      case 'on_delivery':
        return 'Sedang Diantar';
      case 'delivered':
        return 'Telah Sampai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Status Tidak Diketahui';
    }
  }
}
