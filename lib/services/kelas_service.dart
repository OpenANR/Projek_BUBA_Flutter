import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kelas_model.dart';
import 'auth_services.dart';

class KelasServiceException implements Exception {
  const KelasServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KelasService {
  Future<List<KelasModel>> getKelasSiswa() async {
    final token = await AuthServices.getToken();
    if (token == null || token.trim().isEmpty) {
      throw const KelasServiceException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final response = await http
          .get(
            Uri.parse('${AuthServices.baseUrl}/siswa/kelas'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        throw const KelasServiceException(
          'Sesi login tidak valid atau telah berakhir. Silakan login kembali.',
        );
      }
      if (response.statusCode == 403) {
        throw const KelasServiceException(
          'Akun ini tidak memiliki akses untuk melihat kelas.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw KelasServiceException(
          _responseMessage(response.body) ??
              'Gagal mengambil kelas (HTTP ${response.statusCode}).',
        );
      }
      if (response.statusCode == 204 || response.body.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Format respons kelas dari API tidak valid.',
        );
      }
      if (decoded['success'] != true) {
        throw KelasServiceException(
          decoded['message']?.toString() ?? 'Gagal mengambil data kelas.',
        );
      }

      final rawKelas = decoded['kelas'];
      if (rawKelas == null) return const [];
      if (rawKelas is! List) {
        throw const FormatException(
          'Format daftar kelas dari API tidak valid.',
        );
      }

      return rawKelas
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Format data kelas dari API tidak valid.',
              );
            }
            return KelasModel.fromMap(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    } on TimeoutException {
      throw const KelasServiceException(
        'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const KelasServiceException(
        'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan.',
      );
    } on FormatException catch (error) {
      throw KelasServiceException(error.message);
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
