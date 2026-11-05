import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/materi_model.dart';

class MateriServices {
  // URL API Laravel
  static const String baseUrl = 'http://http://127.0.0.1:8000/api';

  // Mengambil semua data materi
  Future<List<MateriModel>> getMateri({
    int? kelasId,
    int? kategoriId,
  }) async {
    try {
      // Parameter untuk filter kelas dan kategori
      final queryParameters = <String, String>{};

      if (kelasId != null) {
        queryParameters['kelas_id'] = kelasId.toString();
      }

      if (kategoriId != null) {
        queryParameters['kategori_id'] = kategoriId.toString();
      }

      final uri = Uri.parse('$baseUrl/materi').replace(
        queryParameters:
            queryParameters.isEmpty ? null : queryParameters,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // Menyesuaikan jika API menggunakan format pagination
        // atau langsung mengembalikan array JSON
        final List<dynamic> data;

        if (decodedData is List) {
          data = decodedData;
        } else if (decodedData is Map &&
            decodedData['data'] is List) {
          data = decodedData['data'];
        } else {
          throw Exception('Format data materi tidak sesuai');
        }

        return data
            .map((json) => MateriModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Gagal mengambil materi. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}