import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthResult {
  final bool isSuccess;
  final bool isEmailVerified;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.isEmailVerified = true,
    this.errorMessage,
  });
}

class AuthServices {
  static const String baseUrl = 'http://192.168.0.111:8000/api';

  Future<AuthResult> login(String email, String password) async {
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
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Format respons login dari server tidak valid.',
          );
        }
        final data = decoded;
        final token = data['token'] ?? data['access_token'];
        if (token is! String || token.isEmpty) {
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Token login tidak ditemukan dalam respons server.',
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final bool isEmailVerified = data['email_verified'] == true;
        final userData = data['user'];

        if (userData != null) {
          UserModel user = UserModel.fromMap(userData);
          await prefs.setString('user_data', user.toJson());
        }

        return AuthResult(
          isSuccess: true,
          isEmailVerified: isEmailVerified,
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          return AuthResult(
            isSuccess: false,
            errorMessage: decoded['message'].toString(),
          );
        }
      } on FormatException {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Login gagal (HTTP ${response.statusCode}). Periksa alamat dan port server API.',
        );
      }

      return AuthResult(
        isSuccess: false,
        errorMessage: 'Login gagal (HTTP ${response.statusCode}).',
      );
    } on FormatException {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Format respons login dari server tidak valid.',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Tidak bisa terhubung ke server. $e',
      );
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

  static Future<bool> checkVerificationStatus() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/email/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['email_verified'] == true) {
          final userData = decoded['user'];
          if (userData != null) {
            final prefs = await SharedPreferences.getInstance();
            UserModel user = UserModel.fromMap(userData);
            await prefs.setString('user_data', user.toJson());
          }
          return true;
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
    return false;
  }

  static Future<String?> resendVerificationEmail() async {
    try {
      final token = await getToken();
      if (token == null) return 'Token tidak ditemukan. Silakan login kembali.';

      final response = await http.post(
        Uri.parse('$baseUrl/email/resend'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
      return 'Email verifikasi berhasil dikirim ulang.';
    } catch (e) {
      return 'Gagal menghubungi server untuk kirim ulang email: $e';
    }
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
