import 'dart:async';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiService {
  // Base URL API (should be dynamic based on the environment)
  // static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  // Fungsi untuk login admin
  static Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    final request = html.HttpRequest();

    // Membuka koneksi POST ke API
    request.open('POST', '$baseUrl/auth/login');
    request.setRequestHeader('Content-Type', 'application/json');

    // Membuat promise dengan onLoadEnd untuk menangani respon
    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      if (request.status == 200) {
        // Jika status sukses, proses respons JSON
        final Map<String, dynamic> data = json.decode(request.responseText!);

        if (data['data'] != null && data['data']['token'] != null) {
          final String token = data['data']['token'];

          // Menyimpan token ke storage
          _saveToken(token);

          // Kembalikan token
          completer.complete({'token': token});
        } else {
          // Jika data atau token tidak ditemukan
          completer.completeError('Token not found in the response');
        }
      } else {
        // Jika terjadi error, kembalikan pesan error
        completer.completeError('Login failed: ${request.statusText}');
      }
    });

    // Menyiapkan data untuk dikirim
    final data = jsonEncode({'email': email, 'password': password});

    // Kirim permintaan ke server
    request.send(data);

    return completer.future; // Mengembalikan Future dengan hasil atau error
  }

  // static Dio dio = Dio();
  //
  // static Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
  //   try {
  //     final response = await dio.post(
  //       // 'https://delpick.horas-code.my.id/api/v1/auth/login',
  //       'http://127.0.0.1:6100/api/v1/auth/login',
  //       data: {'email': email, 'password': password},
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = response.data;
  //       if (data['data'] != null && data['data']['token'] != null) {
  //         final String token = data['data']['token'];
  //         _saveToken(token);
  //         return {'token': token};
  //       } else {
  //         throw Exception('Token not found in the response');
  //       }
  //     } else {
  //       throw Exception('Login failed: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     throw Exception('Login failed: $e');
  //   }
  // }

  // static Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/auth/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     if (data['data'] != null && data['data']['token'] != null) {
  //       final String token = data['data']['token'];
  //       _saveToken(token);
  //       return {'token': token};
  //     } else {
  //       throw Exception('Token not found in the response');
  //     }
  //   } else {
  //     throw Exception('Login failed: ${response.body}');
  //   }
  // }

  // static Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/auth/login'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email, 'password': password}),
  //   );
  //
  //   print("API Response Status Code: ${response.statusCode}");
  //   print("API Response Body: ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //
  //     // Pastikan respons mengandung 'data' dan 'token'
  //     if (data['data'] != null && data['data']['token'] != null) {
  //       final String token = data['data']['token'];  // Ambil token dari dalam data
  //       await _saveToken(token);  // Menyimpan token ke secure storage
  //       return {'token': token};  // Kembalikan token yang ada dalam data
  //     } else {
  //       throw Exception('Token not found in the response');
  //     }
  //   } else {
  //     throw Exception('Login failed: ${response.body}');
  //   }
  // }

  // Fungsi untuk logout admin
  static Future<void> logoutAdmin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'), // Endpoint untuk logout
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Send the token in the Authorization header
      },
    );

    if (response.statusCode == 200) {
      print('Logged out successfully!');
    } else {
      throw Exception('Failed to logout: ${response.body}');
    }
  }

  // Fungsi untuk membuat customer baru
  static Future<Map<String, dynamic>> createCustomer(String username, String email, String phone, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // Make sure to use the actual token here
      },
      body: json.encode({
        'name': username,
        'email': email,
        'phone': phone,
        'password': newPassword,
        'role': 'customer', // Default role is 'customer'
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;  // Return response body if successful
    } else {
      print('Failed to create customer: ${response.body}');
      throw Exception('Failed to create customer');
    }
  }

  // Fungsi untuk memverifikasi current password
  static Future<bool> verifyCurrentPassword(String currentPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifyPassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // If authentication is required
      },
      body: json.encode({
        'currentPassword': currentPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isVerified']; // Return whether the password is verified
    } else {
      throw Exception('Failed to verify password');
    }
  }

  // Fungsi untuk mengupdate customer
  static Future<Map<String, dynamic>> updateCustomer(String username, String email, String phone, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // If authentication is required
      },
      body: json.encode({
        'name': username,
        'email': email,
        'phone': phone,
        'currentPassword': currentPassword,
        'newPassword': newPassword.isEmpty ? currentPassword : newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;  // Return response body if successful
    } else {
      print('Failed to update customer: ${response.body}');
      throw Exception('Failed to update customer');
    }
  }


  // Fungsi untuk mendapatkan daftar customer
  static Future<void> getAllCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Customer data: $data');
    } else {
      print('Failed to fetch customer data: ${response.body}');
    }
  }

  // Fungsi untuk mendapatkan customer berdasarkan ID
  static Future<void> getCustomerById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Customer data: $data');
    } else {
      print('Failed to fetch customer data: ${response.body}');
    }
  }

  // Token Management Methods
  // Menyimpan token ke secure storage
  static Future<void> _saveToken(String token) async {
    // Menyimpan token dalam browser localStorage
    html.window.localStorage['auth_token'] = token;
  }
  // Fungsi untuk mengambil token
  static Future<String?> getToken() async {
    return html.window.localStorage['auth_token'];
  }
  // static Future<void> _saveToken(String token) async {
  //   await _storage.write(key: 'auth_token', value: token);
  // }

  // Fungsi untuk mengambil token dari secure storage
  // static Future<String?> getToken() async {
  //   return await _storage.read(key: 'auth_token');
  // }
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class ApiService {
//   // Base URL API (ubah sesuai kebutuhan Anda)
//   static const String baseUrl = 'https://delpick.fun/api/v1';
//
//   // Fungsi untuk membuat customer baru
//   static Future<void> createCustomer(String username, String email, String phone, String newpassword) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/auth/register'), // Sesuaikan dengan URL backend
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer your_token', // Jika menggunakan token autentikasi
//       },
//       body: json.encode({
//         'name': username,
//         'email': email,
//         'phone': phone,
//         'password': newpassword,
//         'role': 'customer', // Default role adalah 'customer'
//       }),
//     );
//
//     if (response.statusCode == 201) {
//       print('Customer created successfully!');
//     } else {
//       print('Failed to create customer: ${response.body}');
//       throw Exception('Failed to create customer');
//     }
//   }
//
//   // Fungsi untuk membuat customer baru
//   // static Future<void> createCustomer(String username, String email, String phone, String currpass, String newpassword) async {
//   //   final response = await http.post(
//   //     Uri.parse('$baseUrl/customers'), // Adjust the URL accordingly
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //       'Authorization': 'Bearer your_token', // Jika autentikasi diperlukan
//   //     },
//   //     body: json.encode({
//   //       'name': username,
//   //       'email': email,
//   //       'phone': phone,
//   //       'password': newpassword.isEmpty ? currpass : newpassword,
//   //       'role': 'customer', // Default role 'customer'
//   //     }),
//   //   );
//   //
//   //   if (response.statusCode == 201) {
//   //     print('Customer created successfully!');
//   //   } else {
//   //     print('Failed to create customer: ${response.body}');
//   //   }
//   // }
//
//   // Fungsi untuk mendapatkan daftar customer
//
//   // Fungsi untuk memverifikasi current password (untuk update customer)
//   static Future<bool> verifyCurrentPassword(String currentPassword) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/verifyPassword'), // Endpoint untuk verifikasi password
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer your_token', // Jika autentikasi diperlukan
//       },
//       body: json.encode({
//         'currentPassword': currentPassword,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data['isVerified']; // Menyatakan apakah password valid
//     } else {
//       throw Exception('Failed to verify password');
//     }
//   }
//
//   // Fungsi untuk mengupdate customer
//   static Future<void> updateCustomer(String username, String email, String phone, String currentPassword, String newPassword) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/customers'), // Sesuaikan dengan URL API
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer your_token', // Jika autentikasi diperlukan
//       },
//       body: json.encode({
//         'name': username,
//         'email': email,
//         'phone': phone,
//         'currentPassword': currentPassword,
//         'newPassword': newPassword.isEmpty ? currentPassword : newPassword,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       print('Customer updated successfully!');
//     } else {
//       print('Failed to update customer: ${response.body}');
//       throw Exception('Failed to update customer');
//     }
//   }
//
//
//   static Future<void> getAllCustomers() async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/customers'), // Adjust the URL accordingly
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer your_token', // Jika autentikasi diperlukan
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('Customer data: $data');
//     } else {
//       print('Failed to fetch customer data: ${response.body}');
//     }
//   }
//
//   // Fungsi untuk mendapatkan customer berdasarkan ID
//   static Future<void> getCustomerById(int id) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/customers/$id'), // Adjust the URL accordingly
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer your_token', // Jika autentikasi diperlukan
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('Customer data: $data');
//     } else {
//       print('Failed to fetch customer data: ${response.body}');
//     }
//   }
// }
