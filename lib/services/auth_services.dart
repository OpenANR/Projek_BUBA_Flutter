import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthServices {
  static const String baseUrl = 'http://0.0.0.0:8000/api';

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          return 'Format respons login dari server tidak valid.';
        }
        final data = decoded;
        final token = data['token'] ?? data['access_token'];
        if (token is! String || token.isEmpty) {
          return 'Token login tidak ditemukan dalam respons server.';
        }
        final userData = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (userData != null) {
          UserModel user = UserModel.fromMap(userData);
          await prefs.setString('user_data', user.toJson());
        }

        return null;
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      } on FormatException {
        return 'Login gagal (HTTP ${response.statusCode}). Periksa alamat dan port server API.';
      }

      return 'Login gagal (HTTP ${response.statusCode}).';
    } on FormatException {
      return 'Format respons login dari server tidak valid.';
    } catch (e) {
      return 'Tidak bisa terhubung ke server. $e';
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  static Future<bool> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('Gagal memanggil API Logout: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data');
    }
    return true;
  }
}
