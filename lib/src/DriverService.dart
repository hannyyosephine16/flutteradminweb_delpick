import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverService {
  // Base URL API
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all drivers with pagination
  static Future<Map<String, dynamic>> getAllDrivers({int page = 1, int limit = 10}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load drivers: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching drivers: $e');
      throw e;
    }
  }

  // Get driver by ID
  static Future<Map<String, dynamic>> getDriverById(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get driver: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching driver: $e');
      throw e;
    }
  }

  // File DriverService.dart
  static Future<Map<String, dynamic>> createDriver(
      String name,
      String email,
      String password,
      String phone,
      String vehicle_number,
      String? imageBase64) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();

    // Membuka koneksi POST ke API
    request.open('POST', '$baseUrl/drivers');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token');

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      if (request.status == 201) {
        final Map<String, dynamic> data = json.decode(request.responseText!);
        completer.complete(data);
      } else {
        completer.completeError('Failed to create driver: ${request.statusText}');
      }
    });

    // Menyiapkan data untuk dikirim sesuai dengan format yang diharapkan backend
    final data = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'vehicle_number': vehicle_number,
      'image': imageBase64, // Sertakan gambar (base64)
    });

    // Kirim permintaan ke server
    request.send(data);

    return completer.future;
  }

  // Create a new driver
  static Future<Map<String, dynamic>> createDriver2({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleNumber,
    String? imageBase64,
  }) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'vehicle_number': vehicleNumber,
      };

      // Only include image if provided
      if (imageBase64 != null) {
        data['image'] = imageBase64;
      }

      final response = await dio.post(
        '$baseUrl/drivers',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create driver: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error creating driver: $e');
      throw e;
    }
  }

  // Update existing driver
  static Future<Map<String, dynamic>> updateDriver(
      String id,
      Map<String, dynamic> driverData,
      ) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: driverData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update driver: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error updating driver: $e');
      throw e;
    }
  }

  // Delete driver
  static Future<Map<String, dynamic>> deleteDriver(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.delete(
        '$baseUrl/drivers/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete driver: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error deleting driver: $e');
      throw e;
    }
  }

  // Update driver status
  static Future<Map<String, dynamic>> updateDriverStatus(String status) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/drivers/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update driver status: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error updating driver status: $e');
      throw e;
    }
  }

  // Token Management Methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get token from secure storage
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
// // Updated DriverService.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'dart:html' as html;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class DriverService {
//   // Base URL API
//   static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
//   static final FlutterSecureStorage _storage = FlutterSecureStorage();
//
//   // Get all drivers with pagination
//   static Future<Map<String, dynamic>> getAllDrivers({int page = 1, int limit = 10}) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final response = await dio.get(
//         '$baseUrl/drivers?page=$page&limit=$limit',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to load drivers: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error fetching drivers: $e');
//       throw e;
//     }
//   }
//
//   // Get driver by ID
//   static Future<Map<String, dynamic>> getDriverById(String id) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final response = await dio.get(
//         '$baseUrl/drivers/$id',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to get driver: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error fetching driver: $e');
//       throw e;
//     }
//   }
//
//   // Fungsi untuk membuat customer baru
//   static Future<Map<String, dynamic>> createDriver(String username, String email, String phone, String newPassword, String? imageBase64) async {
//     final token = await getToken();  // Ambil token yang sudah disimpan
//
//     if (token == null) {
//       throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
//     }
//
//     final request = html.HttpRequest();
//
//     // Membuka koneksi POST ke API
//     request.open('POST', '$baseUrl/customers');
//     request.setRequestHeader('Content-Type', 'application/json');
//     request.setRequestHeader('Authorization', 'Bearer $token'); // Menyertakan token di header
//
//     final completer = Completer<Map<String, dynamic>>();
//
//     request.onLoadEnd.listen((event) {
//       if (request.status == 201) {
//         final Map<String, dynamic> data = json.decode(request.responseText!);
//         completer.complete(data);
//       } else {
//         completer.completeError('Failed to create customer: ${request.statusText}');
//       }
//     });
//
//     // Menyiapkan data untuk dikirim
//     final data = jsonEncode({
//       'name': username,
//       'email': email,
//       'phone': phone,
//       'password': newPassword,
//       'role': 'customer', // Default role adalah 'customer'
//       'image': imageBase64, // Sertakan gambar (base64)
//     });
//
//     // Kirim permintaan ke server
//     request.send(data);
//
//     return completer.future; // Mengembalikan Future dengan hasil atau error
//   }
//
//   // Update existing driver
//   static Future<Map<String, dynamic>> updateDriver(String driverId, Map<String, dynamic> driverData, {
//     required String id,
//     String? name,
//     String? email,
//     String? phone,
//     String? password,
//     String? vehicleNumber,
//     String? status,
//     String? imageBase64,
//   })
//   async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final Map<String, dynamic> data = {};
//
//       if (name != null) data['name'] = name;
//       if (email != null) data['email'] = email;
//       if (phone != null) data['phone'] = phone;
//       if (password != null) data['password'] = password;
//       if (vehicleNumber != null) data['vehicle_number'] = vehicleNumber;
//       if (status != null) data['status'] = status;
//       if (imageBase64 != null) data['image'] = imageBase64;
//
//       final response = await dio.put(
//         '$baseUrl/drivers/$id',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: data,
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to update driver: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error updating driver: $e');
//       throw e;
//     }
//   }
//
//   // Delete driver
//   static Future<Map<String, dynamic>> deleteDriver(String id) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final response = await dio.delete(
//         '$baseUrl/drivers/$id',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to delete driver: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error deleting driver: $e');
//       throw e;
//     }
//   }
//
//   // Token Management Methods
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: 'auth_token', value: token);
//   }
//
//   // Get token from secure storage
//   static Future<String?> getToken() async {
//     return await _storage.read(key: 'auth_token');
//   }
// }