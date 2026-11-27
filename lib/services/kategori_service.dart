import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kategori_model.dart';
import 'auth_services.dart';

class KategoriServiceException implements Exception {
  const KategoriServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KategoriService {
  static String _cacheKey(int kelasId) => 'cached_kategori_kelas_$kelasId';

  Future<List<KategoriModel>> getKategori({required int kelasId}) async {
    try {
      final token = await AuthServices.getToken();
      if (token == null || token.trim().isEmpty) {
        throw const KategoriServiceException(
          'Sesi login tidak ditemukan. Silakan login kembali.',
        );
      }

      final response = await http
          .get(
            Uri.parse('${AuthServices.baseUrl}/siswa/kategori/$kelasId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        throw const KategoriServiceException(
          'Sesi login tidak valid atau telah berakhir. Silakan login kembali.',
        );
      }
      if (response.statusCode == 403) {
        throw const KategoriServiceException(
          'Akun ini tidak memiliki akses untuk melihat kategori.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw KategoriServiceException(
          _responseMessage(response.body) ??
              'Gagal mengambil kategori (HTTP ${response.statusCode}).',
        );
      }
      if (response.statusCode == 204 || response.body.trim().isEmpty) {
        await _saveCache(kelasId, const []);
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == false) {
        throw KategoriServiceException(
          decoded['message']?.toString() ?? 'Gagal mengambil data kategori.',
        );
      }

      final rawList = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
              ? (decoded['kategori'] ?? decoded['data'])
              : null;

      if (rawList is! List) {
        throw const FormatException(
          'Format daftar kategori dari API tidak valid.',
        );
      }

      final result = rawList
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Data kategori dari API tidak valid.',
              );
            }
            return KategoriModel.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);

      // Simpan ke SharedPreferences setiap kali berhasil fetch dari API
      await _saveCache(kelasId, result);

      return result;
    } on TimeoutException {
      return _fallbackOrThrow(
        kelasId,
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      return _fallbackOrThrow(
        kelasId,
        'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan.',
      );
    } on FormatException catch (error) {
      throw KategoriServiceException(error.message);
    }
  }

  Future<void> _saveCache(int kelasId, List<KategoriModel> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey(kelasId), jsonString);
  }

  Future<List<KategoriModel>> _getCache(int kelasId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey(kelasId));
    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => KategoriModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<List<KategoriModel>> _fallbackOrThrow(
    int kelasId,
    String errorMessage,
  ) async {
    final cached = await _getCache(kelasId);
    if (cached.isNotEmpty) {
      return cached;
    }
    throw KategoriServiceException(errorMessage);
  }

  String? _responseMessage(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}