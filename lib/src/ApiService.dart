import 'dart:async';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web/helpers.dart';

class ApiService {
  // Base URL API (should be dynamic based on the environment)
  // static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Fungsi untuk login admin
  static Future<Map<String, dynamic>> loginAdmin(
      String email, String password) async {
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
          saveToken(token);

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

  static Future<void> logoutAdmin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'), // Endpoint untuk logout
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token', // Send the token in the Authorization header
      },
    );

    if (response.statusCode == 200) {
      print('Logged out successfully!');
    } else {
      throw Exception('Failed to logout: ${response.body}');
    }
  }

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

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // static Future<void> _saveToken(String token) async {
  //   await _storage.write(key: 'auth_token', value: token);
  // }
  //
  // // Fungsi untuk mengambil token dari secure storage
  // static Future<String?> getToken() async {
  //   return await _storage.read(key: 'auth_token');
  // }
}
