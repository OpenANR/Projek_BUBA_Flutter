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
      final headers = <String, String>{'Accept': 'application/json'};
      if (token == null || token.trim().isEmpty) {
        throw const KategoriServiceException(
          'Sesi login tidak ditemukan. Silakan login kembali.',
        );
      }
      headers['Authorization'] = 'Bearer $token';

      final response = await http
          .get(
            Uri.parse('${AuthServices.baseUrl}/siswa/kategori/$kelasId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw KategoriServiceException(
          'Gagal mengambil kategori (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
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
              throw const FormatException('Data kategori dari API tidak valid.');
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
}
