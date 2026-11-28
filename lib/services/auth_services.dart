import 'dart:async';
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
  // static const String baseUrl = 'https://buba.wstif-polije.com/api';
  static const String baseUrl = 'http://192.168.1.14:8000/api';

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

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
        // Simpan status verifikasi agar aplikasi tetap bisa dibuka offline.
        await prefs.setBool('email_verified', isEmailVerified);

        final userData = data['user'];

        if (userData != null) {
          UserModel user = UserModel.fromMap(userData);
          await prefs.setString('user_data', user.toJson());
        }

        return AuthResult(isSuccess: true, isEmailVerified: isEmailVerified);
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
          errorMessage:
              'Login gagal (HTTP ${response.statusCode}). Periksa alamat dan port server API.',
        );
      }

      return AuthResult(
        isSuccess: false,
        errorMessage: 'Login gagal (HTTP ${response.statusCode}).',
      );
    } on TimeoutException {
      return AuthResult(
        isSuccess: false,
        errorMessage:
            'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
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

  /// Mengembalikan status verifikasi email.
  ///
  /// - `true`  : email sudah diverifikasi
  /// - `false` : email belum diverifikasi (atau sesi tidak valid)
  /// - `null`  : status tidak dapat dipastikan, misalnya karena offline
  static Future<bool?> checkVerificationStatus() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      final response = await http
          .get(
            Uri.parse('$baseUrl/email/status'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401 || response.statusCode == 403) {
        // Sesi sudah tidak valid. Bersihkan agar pengguna diarahkan ke login.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_data');
        await prefs.remove('email_verified');
        return false;
      }

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final verified = decoded['email_verified'] == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('email_verified', verified);

      final userData = decoded['user'];
      if (userData != null) {
        final UserModel user = UserModel.fromMap(userData);
        await prefs.setString('user_data', user.toJson());
      }

      return verified;
    } catch (_) {
      // Offline / server tidak dapat dihubungi.
      return null;
    }
  }

  /// Status verifikasi yang tersimpan di perangkat.
  static Future<bool?> getLocalVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('email_verified');
  }

  static Future<String?> resendVerificationEmail() async {
    try {
      final token = await getToken();
      if (token == null) return 'Token tidak ditemukan. Silakan login kembali.';

      final response = await http
          .post(
            Uri.parse('$baseUrl/email/resend'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

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
        await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Logout lokal tetap dilanjutkan jika server offline.
    } finally {
      final prefs = await SharedPreferences.getInstance();

      await clearRiwayatCache();
      await prefs.remove('token');
      await prefs.remove('user_data');
      await prefs.remove('email_verified');
    }

    return true;
  }

  // Membuat kunci penyimpanan khusus untuk setiap akun siswa.
  static Future<String?> getRiwayatCacheKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final user = jsonDecode(userJson);

      if (user is! Map) return null;

      final identitas = user['id'] ?? user['kode_user'] ?? user['email'];

      if (identitas != null && identitas.toString().isNotEmpty) {
        return 'riwayat_kuis_${identitas.toString()}';
      }

      // Cadangan jika data pengguna tidak memiliki ID atau kode_user.
      final encoded = base64Url.encode(utf8.encode(userJson));
      return 'riwayat_kuis_$encoded';
    } catch (_) {
      return null;
    }
  }

  // Menghapus cache milik akun yang sedang logout.
  static Future<void> clearRiwayatCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = await getRiwayatCacheKey();

    if (cacheKey != null) {
      await prefs.remove(cacheKey);
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/forgot-password'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          errorMessage: decoded is Map<String, dynamic>
              ? decoded['message']?.toString()
              : null,
        );
      }

      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return AuthResult(
          isSuccess: false,
          errorMessage: decoded['message'].toString(),
        );
      }

      return AuthResult(
        isSuccess: false,
        errorMessage:
            'Gagal mengirim tautan reset password (HTTP ${response.statusCode}).',
      );
    } on TimeoutException {
      return AuthResult(
        isSuccess: false,
        errorMessage:
            'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on FormatException {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Format respon dari server tidak valid',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Tidak bisa terhubung ke server. $e',
      );
    }
  }
}
