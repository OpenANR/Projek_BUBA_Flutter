import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kuis_model.dart';
import 'auth_services.dart';

class KuisServices {
  static const String baseUrl = AuthServices.baseUrl;
  bool kategoriTerkunci = false;

  Future<Map<String, String>> _headers() async {
    final token = await AuthServices.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Silakan login kembali.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Format respons server tidak valid.');
    } on FormatException {
      throw Exception('Respons server tidak valid.');
    }
  }

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

    late http.Response response;

    try {
      response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception(
        'Kuis memerlukan koneksi internet. Koneksi ke server terlalu lama.',
      );
    } on http.ClientException {
      throw Exception(
        'Kuis memerlukan koneksi internet. Periksa jaringan lalu coba lagi.',
      );
    }

    final data = _decodeResponse(response);
    kategoriTerkunci = data['terkunci'] == true;

    if (response.statusCode == 200 && data['success'] == true) {
      final List daftarSoal = data['data'] ?? [];

      return daftarSoal.map((item) {
        return KuisModel.fromMap(
          Map<String, dynamic>.from(item),
          baseUrl: baseUrl,
        );
      }).toList();
    }

    throw Exception(data['message'] ?? 'Gagal mengambil daftar kuis.');
  }

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
      'jawaban': jawaban.map((key, value) => MapEntry(key.toString(), value)),
    };

    late http.Response response;

    try {
      response = await http
          .post(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception(
        'Kuis memerlukan koneksi internet. Koneksi ke server terlalu lama.',
      );
    } on http.ClientException {
      throw Exception(
        'Kuis memerlukan koneksi internet. Periksa jaringan lalu coba lagi.',
      );
    }

    final data = _decodeResponse(response);

    if (response.statusCode == 200 && data['success'] == true) {
      final hasil = data['hasil'];

      if (hasil is Map) {
        return Map<String, dynamic>.from(hasil);
      }

      return data;
    }

    throw Exception(data['message'] ?? 'Gagal mengirim jawaban kuis.');
  }

  // Mengambil riwayat yang tersimpan di perangkat (tanpa internet).
  Future<List<Map<String, dynamic>>?> getRiwayatKuisLocal() async {
    final cacheKey = await AuthServices.getRiwayatCacheKey();
    if (cacheKey == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final dataLokal = prefs.getString(cacheKey);
    if (dataLokal == null || dataLokal.isEmpty) return null;

    try {
      final decoded = jsonDecode(dataLokal);

      if (decoded is List) {
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (_) {
      // Cache rusak atau format tidak sesuai.
    }

    return null;
  }

  // Mengambil riwayat dari server atau penyimpanan lokal.
  Future<List<Map<String, dynamic>>> getRiwayatKuis() async {
    final cacheKey = await AuthServices.getRiwayatCacheKey();

    if (cacheKey == null) {
      throw Exception('Silakan login kembali untuk melihat riwayat.');
    }

    final prefs = await SharedPreferences.getInstance();
    final localData = await getRiwayatKuisLocal();

    try {
      final uri = Uri.parse('$baseUrl/siswa/hasil-kuis');

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 12));

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        final List daftarHasil = data['data'] ?? [];

        final hasil = daftarHasil
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        // Simpan data terbaru berdasarkan akun siswa.
        await prefs.setString(cacheKey, jsonEncode(hasil));

        return hasil;
      }

      throw Exception('Tidak berhasil mengambil data terbaru.');
    } catch (_) {
      // Jika server tidak dapat dihubungi, gunakan data lokal.
      if (localData != null) return localData;

      throw Exception(
        'Riwayat reward belum tersedia di perangkat ini. '
        'Hubungkan ke internet untuk memuat riwayat terlebih dahulu.',
      );
    }
  }
}
