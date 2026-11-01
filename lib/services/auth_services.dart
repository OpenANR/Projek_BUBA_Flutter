import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthServices {
  static const String baseUrl = 'http://192.168.1.14:8000/api';

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (userData != null) {
          UserModel user = UserModel.fromMap(userData);
          await prefs.setString('user_data', user.toJson());
        }

        return null;
      } else {
        return data['message'] ?? 'Login gagal';
      }
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
