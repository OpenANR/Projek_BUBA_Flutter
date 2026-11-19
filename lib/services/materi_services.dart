import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/materi_model.dart';
import 'auth_services.dart';

class MateriServices {
  // URL API Laravel
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

  // Mengambil seluruh materi berdasarkan kelas dan kategori
  Future<List<MateriModel>> getMateri({
    required int kelasId,
    required int kategoriId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/siswa/materi').replace(
        queryParameters: {
          'kelas_id': kelasId.toString(),
          'kategori_id': kategoriId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        final List<dynamic> data;
        if (decodedData is Map && decodedData['data'] is List) {
          data = decodedData['data'];
        } else if (decodedData is List) {
          data = decodedData;
        } else {
          throw Exception('Format data materi tidak sesuai');
        }

        return data
            .map((json) => MateriModel.fromJson(
                  Map<String, dynamic>.from(json),
                  baseUrl: baseUrl,
                ))
            .toList();
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded is Map ? decoded['message'] : null;
        throw Exception(
          message ?? 'Gagal mengambil materi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Mengambil detail satu materi berdasarkan kode_materi
  Future<MateriModel> getDetailMateri(String kodeMateri) async {
    try {
      final uri = Uri.parse('$baseUrl/siswa/materi/$kodeMateri');

      final response = await http.get(
        uri,
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        final dynamic data;
        if (decodedData is Map && decodedData['data'] != null) {
          data = decodedData['data'];
        } else {
          data = decodedData;
        }

        if (data is! Map) {
          throw Exception('Format detail materi tidak sesuai');
        }

        return MateriModel.fromJson(
          Map<String, dynamic>.from(data),
          baseUrl: baseUrl,
        );
      } else {
        final decoded = jsonDecode(response.body);
        final message = decoded is Map ? decoded['message'] : null;
        throw Exception(
          message ??
              'Gagal mengambil detail materi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
