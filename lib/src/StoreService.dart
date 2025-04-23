import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreService {
  // Base URL API
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Get all Stores with pagination
  static Future<Map<String, dynamic>> getAllStores({int page = 1, int limit = 10}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/stores?page=$page&limit=$limit',
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
        throw Exception('Failed to load Stores: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching Stores: $e');
      throw e;
    }
  }

  // Get Store by ID
  static Future<Map<String, dynamic>> getStoreById(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/stores/$id',
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
        throw Exception('Failed to get Store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching Store: $e');
      throw e;
    }
  }

  // Create new store
  static Future<Map<String, dynamic>> createStore(
      String name,
      String email,
      String password,
      String phone,
      String storeName,
      String address,
      String description,
      String openTime,
      String closeTime,
      String latitude,
      String longitude,
      String? imageBase64,
      ) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final dio = Dio();

    try {
      // Menyiapkan data untuk dikirim sesuai dengan format yang diharapkan backend
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'storeName': storeName,
        'address': address,
        'description': description,
        'openTime': openTime,
        'closeTime': closeTime,
        'latitude': latitude,
        'longitude': longitude, // Perbaikan: 'longitude' bukan 'longtitude'
        'image': imageBase64,
      };

      final response = await dio.post(
        '$baseUrl/stores',
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
        throw Exception('Failed to create store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error creating store: $e');
      throw e;
    }
  }

  // Update existing Store
  static Future<Map<String, dynamic>> updateStore(
      String id,
      Map<String, dynamic> storeData,
      ) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/stores/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: storeData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update Store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error updating Store: $e');
      throw e;
    }
  }

  // Delete Store
  static Future<Map<String, dynamic>> deleteStore(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.delete(
        '$baseUrl/stores/$id',
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
        throw Exception('Failed to delete Store: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error deleting Store: $e');
      throw e;
    }
  }

  // Update Store profile
  static Future<Map<String, dynamic>> updateStoreProfile(Map<String, dynamic> storeData) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    final dio = Dio();

    try {
      final response = await dio.put(
        '$baseUrl/stores/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: storeData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update store profile: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error updating store profile: $e');
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

// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class StoreService {
//   // Base URL API
//   static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
//   static final FlutterSecureStorage _storage = FlutterSecureStorage();
//
//   // Get all Stores with pagination
//   static Future<Map<String, dynamic>> getAllStores({int page = 1, int limit = 10}) async {
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
//         '$baseUrl/stores?page=$page&limit=$limit',
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
//         throw Exception('Failed to load Stores: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error fetching Stores: $e');
//       throw e;
//     }
//   }
//
//   // Get Store by ID
//   static Future<Map<String, dynamic>> getStoreById(String id) async {
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
//         '$baseUrl/Stores/$id',
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
//         throw Exception('Failed to get Store: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error fetching Store: $e');
//       throw e;
//     }
//   }
//
//   // File StoreService.dart
//   static Future<Map<String, dynamic>> createStore(
//       String name,
//       String email,
//       String password,
//       String phone,
//       String storeName,
//       String address,
//       String description,
//       String openTime,
//       String closeTime,
//       String? imageBase64,
//       String latitude,
//       String longitude,
//       ) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
//     }
//
//     final request = html.HttpRequest();
//
//     // Membuka koneksi POST ke API
//     request.open('POST', '$baseUrl/stores');
//     request.setRequestHeader('Content-Type', 'application/json');
//     request.setRequestHeader('Authorization', 'Bearer $token');
//
//     final completer = Completer<Map<String, dynamic>>();
//
//     request.onLoadEnd.listen((event) {
//       if (request.status == 201) {
//         final Map<String, dynamic> data = json.decode(request.responseText!);
//         completer.complete(data);
//       } else {
//         completer.completeError('Failed to create driver: ${request.statusText}');
//       }
//     });
//
//     // Menyiapkan data untuk dikirim sesuai dengan format yang diharapkan backend
//     final data = jsonEncode({
//       'name': name,
//       'email': email,
//       'password': password,
//       'phone': phone,
//       'storeName': storeName,
//       'address': address,
//       'description': description,
//       'openTime': openTime,
//       'closeTime': closeTime,
//       'latitude': latitude,
//       'longtitude': longitude,
//       'role' : 'store',
//       'image': imageBase64, // Sertakan gambar (base64)
//     });
//
//     // Kirim permintaan ke server
//     request.send(data);
//
//     return completer.future;
//   }
//
//
//   // Update existing Store
//   static Future<Map<String, dynamic>> updateStore(
//       String id,
//       Map<String, dynamic> StoreData,
//       ) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final response = await dio.put(
//         '$baseUrl/Stores/$id',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: StoreData,
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to update Store: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error updating Store: $e');
//       throw e;
//     }
//   }
//
//   // Delete Store
//   static Future<Map<String, dynamic>> deleteStore(String id) async {
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
//         '$baseUrl/Stores/$id',
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
//         throw Exception('Failed to delete Store: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error deleting Store: $e');
//       throw e;
//     }
//   }
//
//   // Update Store status
//   static Future<Map<String, dynamic>> updateStoreStatus(String status) async {
//     final token = await getToken();
//
//     if (token == null) {
//       throw Exception('Token not found. Please login.');
//     }
//
//     final dio = Dio();
//
//     try {
//       final response = await dio.put(
//         '$baseUrl/Stores/status',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         ),
//         data: {'status': status},
//       );
//
//       if (response.statusCode == 200) {
//         return response.data;
//       } else {
//         throw Exception('Failed to update Store status: ${response.statusMessage}');
//       }
//     } catch (e) {
//       print('Error updating Store status: $e');
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
// // // Updated StoreService.dart
// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:dio/dio.dart';
// // import 'dart:html' as html;
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// //
// // class StoreService {
// //   // Base URL API
// //   static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
// //   static final FlutterSecureStorage _storage = FlutterSecureStorage();
// //
// //   // Get all Stores with pagination
// //   static Future<Map<String, dynamic>> getAllStores({int page = 1, int limit = 10}) async {
// //     final token = await getToken();
// //
// //     if (token == null) {
// //       throw Exception('Token not found. Please login.');
// //     }
// //
// //     final dio = Dio();
// //
// //     try {
// //       final response = await dio.get(
// //         '$baseUrl/Stores?page=$page&limit=$limit',
// //         options: Options(
// //           headers: {
// //             'Authorization': 'Bearer $token',
// //             'Content-Type': 'application/json',
// //           },
// //         ),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         return response.data;
// //       } else {
// //         throw Exception('Failed to load Stores: ${response.statusMessage}');
// //       }
// //     } catch (e) {
// //       print('Error fetching Stores: $e');
// //       throw e;
// //     }
// //   }
// //
// //   // Get Store by ID
// //   static Future<Map<String, dynamic>> getStoreById(String id) async {
// //     final token = await getToken();
// //
// //     if (token == null) {
// //       throw Exception('Token not found. Please login.');
// //     }
// //
// //     final dio = Dio();
// //
// //     try {
// //       final response = await dio.get(
// //         '$baseUrl/Stores/$id',
// //         options: Options(
// //           headers: {
// //             'Authorization': 'Bearer $token',
// //             'Content-Type': 'application/json',
// //           },
// //         ),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         return response.data;
// //       } else {
// //         throw Exception('Failed to get Store: ${response.statusMessage}');
// //       }
// //     } catch (e) {
// //       print('Error fetching Store: $e');
// //       throw e;
// //     }
// //   }
// //
// //   // Fungsi untuk membuat customer baru
// //   static Future<Map<String, dynamic>> createStore(String username, String email, String phone, String newPassword, String? imageBase64) async {
// //     final token = await getToken();  // Ambil token yang sudah disimpan
// //
// //     if (token == null) {
// //       throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
// //     }
// //
// //     final request = html.HttpRequest();
// //
// //     // Membuka koneksi POST ke API
// //     request.open('POST', '$baseUrl/customers');
// //     request.setRequestHeader('Content-Type', 'application/json');
// //     request.setRequestHeader('Authorization', 'Bearer $token'); // Menyertakan token di header
// //
// //     final completer = Completer<Map<String, dynamic>>();
// //
// //     request.onLoadEnd.listen((event) {
// //       if (request.status == 201) {
// //         final Map<String, dynamic> data = json.decode(request.responseText!);
// //         completer.complete(data);
// //       } else {
// //         completer.completeError('Failed to create customer: ${request.statusText}');
// //       }
// //     });
// //
// //     // Menyiapkan data untuk dikirim
// //     final data = jsonEncode({
// //       'name': username,
// //       'email': email,
// //       'phone': phone,
// //       'password': newPassword,
// //       'role': 'customer', // Default role adalah 'customer'
// //       'image': imageBase64, // Sertakan gambar (base64)
// //     });
// //
// //     // Kirim permintaan ke server
// //     request.send(data);
// //
// //     return completer.future; // Mengembalikan Future dengan hasil atau error
// //   }
// //
// //   // Update existing Store
// //   static Future<Map<String, dynamic>> updateStore(String StoreId, Map<String, dynamic> StoreData, {
// //     required String id,
// //     String? name,
// //     String? email,
// //     String? phone,
// //     String? password,
// //     String? vehicleNumber,
// //     String? status,
// //     String? imageBase64,
// //   })
// //   async {
// //     final token = await getToken();
// //
// //     if (token == null) {
// //       throw Exception('Token not found. Please login.');
// //     }
// //
// //     final dio = Dio();
// //
// //     try {
// //       final Map<String, dynamic> data = {};
// //
// //       if (name != null) data['name'] = name;
// //       if (email != null) data['email'] = email;
// //       if (phone != null) data['phone'] = phone;
// //       if (password != null) data['password'] = password;
// //       if (vehicleNumber != null) data['vehicle_number'] = vehicleNumber;
// //       if (status != null) data['status'] = status;
// //       if (imageBase64 != null) data['image'] = imageBase64;
// //
// //       final response = await dio.put(
// //         '$baseUrl/Stores/$id',
// //         options: Options(
// //           headers: {
// //             'Authorization': 'Bearer $token',
// //             'Content-Type': 'application/json',
// //           },
// //         ),
// //         data: data,
// //       );
// //
// //       if (response.statusCode == 200) {
// //         return response.data;
// //       } else {
// //         throw Exception('Failed to update Store: ${response.statusMessage}');
// //       }
// //     } catch (e) {
// //       print('Error updating Store: $e');
// //       throw e;
// //     }
// //   }
// //
// //   // Delete Store
// //   static Future<Map<String, dynamic>> deleteStore(String id) async {
// //     final token = await getToken();
// //
// //     if (token == null) {
// //       throw Exception('Token not found. Please login.');
// //     }
// //
// //     final dio = Dio();
// //
// //     try {
// //       final response = await dio.delete(
// //         '$baseUrl/Stores/$id',
// //         options: Options(
// //           headers: {
// //             'Authorization': 'Bearer $token',
// //             'Content-Type': 'application/json',
// //           },
// //         ),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         return response.data;
// //       } else {
// //         throw Exception('Failed to delete Store: ${response.statusMessage}');
// //       }
// //     } catch (e) {
// //       print('Error deleting Store: $e');
// //       throw e;
// //     }
// //   }
// //
// //   // Token Management Methods
// //   static Future<void> saveToken(String token) async {
// //     await _storage.write(key: 'auth_token', value: token);
// //   }
// //
// //   // Get token from secure storage
// //   static Future<String?> getToken() async {
// //     return await _storage.read(key: 'auth_token');
// //   }
// // }