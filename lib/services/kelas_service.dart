import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kelas_model.dart';
import 'auth_services.dart';

class KelasServiceException implements Exception {
  const KelasServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KelasService {
  KelasService({this._client});

  static const String _cacheKeyPrefix = 'kelas_siswa_cache_';

  final http.Client? _client;

  Future<List<KelasModel>> getKelasSiswa() async {
    final token = await AuthServices.getToken();
    if (token == null || token.trim().isEmpty) {
      throw const KelasServiceException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
      );
    }

    try {
      final uri = Uri.parse('${AuthServices.baseUrl}/siswa/kelas');
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final client = _client;
      final response =
          await (client == null
                  ? http.get(uri, headers: headers)
                  : client.get(uri, headers: headers))
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
        final error = KelasServiceException(
          _responseMessage(response.body) ??
              'Gagal mengambil kelas (HTTP ${response.statusCode}).',
        );
        if (response.statusCode >= 500) {
          return await _cachedKelasOrThrow(error);
        }
        throw error;
      }
      if (response.statusCode == 204 || response.body.trim().isEmpty) {
        return await _saveKelasCache(const []);
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
      if (rawKelas == null) return await _saveKelasCache(const []);
      if (rawKelas is! List) {
        throw const FormatException(
          'Format daftar kelas dari API tidak valid.',
        );
      }

      final kelasList = rawKelas
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Format data kelas dari API tidak valid.',
              );
            }
            return KelasModel.fromMap(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
      return await _saveKelasCache(kelasList);
    } on TimeoutException {
      return await _cachedKelasOrThrow(
        const KelasServiceException(
          'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.',
        ),
      );
    } on http.ClientException {
      return await _cachedKelasOrThrow(
        const KelasServiceException(
          'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan.',
        ),
      );
    } on FormatException catch (error) {
      throw KelasServiceException(error.message);
    }
  }

  Future<List<KelasModel>> _saveKelasCache(List<KelasModel> kelasList) async {
    final user = await AuthServices.getUser();
    if (user != null && user.id > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_cacheKeyPrefix${user.id}',
        jsonEncode(
          kelasList
              .map((kelas) => {'id': kelas.id, 'nama_kelas': kelas.namaKelas})
              .toList(growable: false),
        ),
      );
    }
    return kelasList;
  }

  Future<List<KelasModel>> _cachedKelasOrThrow(
    KelasServiceException networkError,
  ) async {
    final user = await AuthServices.getUser();
    if (user == null || user.id <= 0) throw networkError;

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('$_cacheKeyPrefix${user.id}');
    if (cachedJson == null) throw networkError;

    final decoded = jsonDecode(cachedJson);
    if (decoded is! List) {
      throw const FormatException('Cache daftar kelas tidak valid.');
    }
    return decoded
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Cache data kelas tidak valid.');
          }
          return KelasModel.fromMap(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
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
