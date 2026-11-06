import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kategori_model.dart';
import 'auth_services.dart';

class KategoriServiceException implements Exception {
  const KategoriServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KategoriService {
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

      return rawList
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Data kategori dari API tidak valid.',
              );
            }
            return KategoriModel.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    } on TimeoutException {
      throw const KategoriServiceException(
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const KategoriServiceException(
        'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan.',
      );
    } on FormatException catch (error) {
      throw KategoriServiceException(error.message);
    }
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
