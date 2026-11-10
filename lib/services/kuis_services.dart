import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kuis_model.dart';
import 'auth_services.dart';

class KuisServices {
  static const String baseUrl = AuthServices.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthServices.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token tidak ditemukan. Silakan login kembali.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mengubah response Laravel menjadi Map.
  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Format respons server tidak valid.');
    } on FormatException {
      throw Exception(
        'Respons server tidak valid (HTTP ${response.statusCode}).',
      );
    }
  }

  // Mengambil seluruh soal berdasarkan kelas dan kategori.
  Future<List<KuisModel>> getKuis({
    required int kelasId,
    required int kategoriId,
  }) async {
    final uri = Uri.parse('$baseUrl/siswa/kuis').replace(
      queryParameters: {
        'kelas_id': kelasId.toString(),
        'kategori_id': kategoriId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      final List daftarSoal = data['data'] ?? [];

      return daftarSoal.map((item) {
        return KuisModel.fromMap(
          Map<String, dynamic>.from(item),
          baseUrl: baseUrl,
        );
      }).toList();
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil daftar kuis.',
    );
  }

  // Mengirim jawaban siswa ke Laravel.
  Future<Map<String, dynamic>> submitKuis({
    required int quisId,
    required int kelasId,
    required int kategoriId,
    required Map<int, String> jawaban,
  }) async {
    final uri = Uri.parse('$baseUrl/siswa/kuis/submit');

    final body = {
      'quis_id': quisId,
      'kelas_id': kelasId,
      'kategori_id': kategoriId,
      'jawaban': jawaban.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };

    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      // Mendukung response Laravel berbentuk:
      // { "success": true, "hasil": {...} }
      // maupun response dengan nilai langsung di bagian utama.
      final hasil = data['hasil'];

      if (hasil is Map) {
        return Map<String, dynamic>.from(hasil);
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'Gagal mengirim jawaban kuis.',
    );
  }

  // Mengambil riwayat hasil kuis.
  Future<List<Map<String, dynamic>>> getRiwayatKuis() async {
    final uri = Uri.parse('$baseUrl/siswa/hasil-kuis');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      final List daftarHasil = data['data'] ?? [];

      return daftarHasil
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil riwayat kuis.',
    );
  }
}
