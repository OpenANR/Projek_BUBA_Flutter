import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/materi_model.dart';
import 'auth_services.dart';

class MateriServices {
  // Gunakan alamat yang sama dengan AuthServices
  static const String baseUrl = 'http://192.168.0.140:8000/api';

  // Header request API + token Sanctum
  static Future<Map<String, String>> _headers() async {
    final token = await AuthServices.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // Mengambil data materi berdasarkan kelas dan kategori
  Future<List<MateriModel>> getMateri({
    required int kelasId,
    required int kategoriId,
  }) async {
    try {
      final queryParameters = <String, String>{
        'kelas_id': kelasId.toString(),
        'kategori_id': kategoriId.toString(),
      };

      final uri = Uri.parse('$baseUrl/materi').replace(
        queryParameters: queryParameters,
      );

      print('Request API Materi: $uri');

      final response = await http.get(
        uri,
        headers: await _headers(),
      );

      print('Status API Materi: ${response.statusCode}');
      print('Response API Materi: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        List<dynamic> data;

        if (decodedData is Map &&
            decodedData['data'] is List) {
          data = decodedData['data'];
        } else if (decodedData is List) {
          data = decodedData;
        } else {
          throw Exception(
            'Format data materi tidak sesuai',
          );
        }

        return data.map((json) {
          return MateriModel.fromJson(
            Map<String, dynamic>.from(json),
            baseUrl: baseUrl,
          );
        }).toList();
      }

      String message =
          'Gagal mengambil materi. Status: ${response.statusCode}';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Mengambil detail materi berdasarkan kode_materi
  Future<MateriModel> getDetailMateri(
    String kodeMateri,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/siswa/materi/$kodeMateri',
      );

      print('Request Detail Materi: $uri');

      final response = await http.get(
        uri,
        headers: await _headers(),
      );

      print(
        'Status Detail Materi: ${response.statusCode}',
      );

      print(
        'Response Detail Materi: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        dynamic data;

        if (decodedData is Map &&
            decodedData['data'] != null) {
          data = decodedData['data'];
        } else {
          data = decodedData;
        }

        if (data is! Map) {
          throw Exception(
            'Format detail materi tidak sesuai',
          );
        }

        return MateriModel.fromJson(
          Map<String, dynamic>.from(data),
          baseUrl: baseUrl,
        );
      }

      String message =
          'Gagal mengambil detail materi. Status: ${response.statusCode}';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map &&
            decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }
}