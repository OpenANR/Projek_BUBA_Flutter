import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/kuis_model.dart';
import 'auth_services.dart';

class KuisServices {
  static const String baseUrl = AuthServices.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthServices.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mengambil daftar soal berdasarkan kelas dan kategori
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List daftarSoal = data['data'];

      return daftarSoal
          .map((item) => KuisModel.fromMap(item))
          .toList();
    }

    throw Exception(data['message'] ?? 'Gagal mengambil daftar kuis.');
  }

  // Mengirim jawaban siswa ke Laravel
  Future<Map<String, dynamic>> submitKuis({
    required int kelasId,
    required int kategoriId,
    required Map<int, String> jawaban,
  }) async {
    final uri = Uri.parse('$baseUrl/siswa/kuis/submit');

    final body = {
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['hasil']);
    }

    throw Exception(data['message'] ?? 'Gagal mengirim jawaban kuis.');
  }

  // Mengambil riwayat hasil kuis
  Future<List<Map<String, dynamic>>> getRiwayatKuis() async {
    final uri = Uri.parse('$baseUrl/siswa/hasil-kuis');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List daftarHasil = data['data'];

      return daftarHasil
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat kuis.');
  }
}
