import 'dart:async';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class CustomerService {
  // Base URL API (should be dynamic based on the environment)
  // static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String baseUrl = 'http://127.0.0.1:6100/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fungsi untuk membuat customer baru
  // static Future<Map<String, dynamic>> createCustomer(String username, String email, String phone, String newPassword, String? imageBase64) async {
  //   final token = await getToken();
  //
  //   if (token == null) {
  //     throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
  //   }
  //
  //   // Buat objek data yang akan dikirim
  //   final Map<String, dynamic> requestData = {
  //     'name': username,
  //     'email': email,
  //     'phone': phone,
  //     'password': newPassword,
  //     'role': 'customer', // Default role adalah 'customer'
  //   };
  //
  //   // Hanya tambahkan image jika tidak null
  //   if (imageBase64 != null && imageBase64.isNotEmpty) {
  //     // Pastikan format base64 sesuai dengan yang diharapkan backend
  //     // Jika backend mengharapkan string base64 tanpa prefix:
  //     // Cek apakah imageBase64 memiliki prefix
  //     if (imageBase64.startsWith('data:')) {
  //       // Ekstrak hanya bagian base64-nya saja
  //       final splitData = imageBase64.split(',');
  //       if (splitData.length > 1) {
  //         requestData['image'] = splitData[1]; // Ambil bagian setelah koma
  //       } else {
  //         requestData['image'] = imageBase64;
  //       }
  //     } else {
  //       requestData['image'] = imageBase64;
  //     }
  //   }
  //
  //   final request = html.HttpRequest();
  //   request.open('POST', '$baseUrl/customers');
  //   request.setRequestHeader('Content-Type', 'application/json');
  //   request.setRequestHeader('Authorization', 'Bearer $token');
  //
  //   final completer = Completer<Map<String, dynamic>>();
  //
  //   request.onLoadEnd.listen((event) {
  //     if (request.status == 201) {
  //       final Map<String, dynamic> data = json.decode(request.responseText!);
  //       completer.complete(data);
  //     } else {
  //       print('Error response: ${request.responseText}'); // Tambahkan log untuk debug
  //       completer.completeError('Failed to create customer: ${request.statusText}');
  //     }
  //   });
  //
  //   // Encode dan kirim data
  //   final jsonData = jsonEncode(requestData);
  //   print('Sending data: $jsonData'); // Tambahkan log untuk debug
  //   request.send(jsonData);
  //
  //   return completer.future;
  // }
  static Future<Map<String, dynamic>> createCustomer(String username, String email, String phone, String newPassword, String? imageBase64) async {
    final token = await getToken();  // Ambil token yang sudah disimpan

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();

    // Membuka koneksi POST ke API
    request.open('POST', '$baseUrl/customers');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token'); // Menyertakan token di header

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      if (request.status == 201) {
        final Map<String, dynamic> data = json.decode(request.responseText!);
        completer.complete(data);
      } else {
        completer.completeError('Failed to create customer: ${request.statusText}');
      }
    });

    // Menyiapkan data untuk dikirim
    final data = jsonEncode({
      'name': username,
      'email': email,
      'phone': phone,
      'password': newPassword,
      'role': 'customer', // Default role adalah 'customer'
      'image': imageBase64, // Sertakan gambar (base64)
    });

    // Kirim permintaan ke server
    request.send(data);

    return completer.future; // Mengembalikan Future dengan hasil atau error
  }

// Fungsi untuk mengupdate customer
  static Future<Map<String, dynamic>> updateCustomer(
      String id,
      String name,
      String email,
      String phone,
      String currentPassword,
      String newPassword,
      String? imageBase64 // Optional base64 image
      )
  async {
    final token = await getToken();  // Get saved token

    if (token == null) {
      throw Exception('Token not found, please login first');
    }

    final request = html.HttpRequest();

    // Open PUT connection to API with customer ID in URL
    request.open('PUT', '$baseUrl/customers/$id');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token'); // Include token in header

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      if (request.status == 200) {
        final Map<String, dynamic> data = json.decode(request.responseText!);
        completer.complete(data);
      } else {
        completer.completeError('Failed to update customer: ${request.statusText}');
      }
    });

    // Prepare data to send
    final Map<String, dynamic> dataToSend = {
      'name': name,
      'email': email,
      'phone': phone
    };

    // Only include password if there's a new one
    if (newPassword.isNotEmpty) {
      dataToSend['password'] = newPassword;
    }

    // Include image if it exists
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      dataToSend['image'] = imageBase64;
    }

    // Send request to server
    request.send(jsonEncode(dataToSend));

    return completer.future; // Return Future with result or error
  }

  // Fungsi untuk getCustomerById
  static Future<Map<String, dynamic>> getCustomerById(String id) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan, harap login terlebih dahulu');
    }

    final request = html.HttpRequest();

    // Membuka koneksi GET ke API dengan ID customer di URL
    request.open('GET', '$baseUrl/customers/$id');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', 'Bearer $token'); // Sertakan token di header

    final completer = Completer<Map<String, dynamic>>();

    request.onLoadEnd.listen((event) {
      if (request.status == 200) {
        final Map<String, dynamic> data = json.decode(request.responseText!);
        completer.complete(data);
      } else {
        completer.completeError('Gagal mendapatkan data customer: ${request.statusText}');
      }
    });

    // Kirim request ke server
    request.send();

    return completer.future; // Mengembalikan Future dengan hasil atau error
  }

  // Fungsi untuk getAllCustomer
  static Future<Map<String, dynamic>> getAllCustomers(int page, int limit) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found. Please login.');
    }

    // Using Dio instead of html.window.fetch
    final dio = Dio();

    try {
      final response = await dio.get(
        '$baseUrl/customers?page=$page&limit=$limit',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // print('Response status: ${response.statusCode}');
      // print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e');
      throw e;
    }
  }


  // Token Management Methods
  //   // Menyimpan token ke secure storage
  //   static Future<void> _saveToken(String token) async {
  //     // Menyimpan token dalam browser localStorage
  //     html.window.localStorage['auth_token'] = token;
  //   }
  //   // Fungsi untuk mengambil token
  //   static Future<String?> getToken() async {
  //     return html.window.localStorage['auth_token'];
  //   }

  static Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Fungsi untuk mengambil token dari secure storage
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}


