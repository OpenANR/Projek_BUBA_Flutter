import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/materi_model.dart';
import 'auth_services.dart';
import 'materi_media_cache.dart';

class MateriServices {
  // ==========================================================
  // BASE URL API
  // ==========================================================

  static const String baseUrl =
      'http://192.168.0.140:8000/api';

  // ==========================================================
  // HEADER API
  // ==========================================================

  static Future<Map<String, String>> _headers() async {
    final token = await AuthServices.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',

      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ==========================================================
  // CACHE KEY LIST MATERI
  // ==========================================================

  String _materiCacheKey(
    int kelasId,
    int kategoriId,
  ) {
    return 'materi_cache_${kelasId}_$kategoriId';
  }

  // ==========================================================
  // CACHE KEY DETAIL MATERI
  // ==========================================================

  String _detailCacheKey(
    String kodeMateri,
  ) {
    return 'materi_detail_$kodeMateri';
  }

  // ==========================================================
  // SIMPAN LIST MATERI KE CACHE
  // ==========================================================

  Future<void> _saveMateriCache(
    int kelasId,
    int kategoriId,
    List<MateriModel> materi,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final data = materi.map((item) {
      return item.toJson();
    }).toList();

    await prefs.setString(
      _materiCacheKey(
        kelasId,
        kategoriId,
      ),
      jsonEncode(data),
    );

    print(
      'List materi berhasil disimpan ke cache.',
    );

    // Simpan detail masing-masing materi
    for (final item in materi) {
      await _saveDetailCache(item);
    }
  }

  // ==========================================================
  // AMBIL LIST MATERI DARI CACHE
  // ==========================================================

  Future<List<MateriModel>> _getMateriCache(
    int kelasId,
    int kategoriId,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(
      _materiCacheKey(
        kelasId,
        kategoriId,
      ),
    );

    if (jsonString == null ||
        jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      final result =
          decoded.map<MateriModel>((item) {
        return MateriModel.fromJson(
          Map<String, dynamic>.from(item),
          baseUrl: baseUrl,
        );
      }).toList();

      print(
        'Materi berhasil dibaca dari cache.',
      );

      return result;
    } catch (e) {
      print(
        'Gagal membaca cache materi: $e',
      );

      return [];
    }
  }

  // ==========================================================
  // SIMPAN DETAIL MATERI + MEDIA
  // ==========================================================

  Future<void> _saveDetailCache(
    MateriModel materi,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    String? localGambar;
    String? localAudio;

    // --------------------------------------------------------
    // DOWNLOAD GAMBAR
    // --------------------------------------------------------

    if (materi.gambarUrl != null &&
        materi.gambarUrl!.isNotEmpty) {
      localGambar =
          await MateriMediaCache.downloadFile(
        materi.gambarUrl,
      );
    }

    // --------------------------------------------------------
    // DOWNLOAD AUDIO
    // --------------------------------------------------------

    if (materi.audioUrl != null &&
        materi.audioUrl!.isNotEmpty) {
      localAudio =
          await MateriMediaCache.downloadFile(
        materi.audioUrl,
      );
    }

    // --------------------------------------------------------
    // DATA YANG DISIMPAN
    // --------------------------------------------------------

    final data = {
      ...materi.toJson(),

      'local_gambar': localGambar,
      'local_audio': localAudio,
    };

    await prefs.setString(
      _detailCacheKey(
        materi.kodeMateri,
      ),
      jsonEncode(data),
    );

    print(
      'Detail materi berhasil disimpan ke cache: '
      '${materi.kodeMateri}',
    );
  }

  // ==========================================================
  // AMBIL DETAIL MATERI DARI CACHE
  // ==========================================================

  Future<MateriModel?> _getDetailCache(
    String kodeMateri,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(
      _detailCacheKey(kodeMateri),
    );

    if (jsonString == null ||
        jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(decoded);

      // ======================================================
      // CEK GAMBAR LOKAL
      // ======================================================

      final localGambar =
          data['local_gambar']?.toString();

      if (localGambar != null &&
          localGambar.isNotEmpty) {
        final file =
            File(localGambar);

        if (await file.exists()) {
          data['gambar_url'] =
              file.path;
        }
      }

      // ======================================================
      // CEK AUDIO LOKAL
      // ======================================================

      final localAudio =
          data['local_audio']?.toString();

      if (localAudio != null &&
          localAudio.isNotEmpty) {
        final file =
            File(localAudio);

        if (await file.exists()) {
          data['audio_url'] =
              file.path;
        }
      }

      return MateriModel.fromJson(
        data,
        baseUrl: baseUrl,
      );
    } catch (e) {
      print(
        'Gagal membaca cache detail materi: $e',
      );

      return null;
    }
  }

  // ==========================================================
  // GET LIST MATERI
  // ==========================================================

  Future<List<MateriModel>> getMateri({
    required int kelasId,
    required int kategoriId,
  }) async {
    try {
      final queryParameters =
          <String, String>{
        'kelas_id':
            kelasId.toString(),

        'kategori_id':
            kategoriId.toString(),
      };

      final uri =
          Uri.parse(
            '$baseUrl/materi',
          ).replace(
            queryParameters:
                queryParameters,
          );

      print('');
      print(
        '======================================',
      );
      print(
        'REQUEST API MATERI',
      );
      print(
        '$uri',
      );
      print(
        '======================================',
      );

      // ======================================================
      // REQUEST API
      // ======================================================

      final response =
          await http
              .get(
                uri,
                headers:
                    await _headers(),
              )
              .timeout(
                const Duration(
                  seconds: 5,
                ),
              );

      print(
        'Status API Materi: '
        '${response.statusCode}',
      );

      print(
        'Response API Materi: '
        '${response.body}',
      );

      // ======================================================
      // RESPONSE BERHASIL
      // ======================================================

      if (response.statusCode == 200) {
        final decodedData =
            jsonDecode(
          response.body,
        );

        List<dynamic> data;

        // Format:
        // {
        //   "data": [...]
        // }

        if (decodedData is Map &&
            decodedData['data']
                is List) {
          data =
              decodedData['data'];
        }

        // Format:
        // [...]
        else if (decodedData
            is List) {
          data =
              decodedData;
        }

        // Format salah
        else {
          throw Exception(
            'Format data materi tidak sesuai.',
          );
        }

        // ====================================================
        // UBAH JSON MENJADI MODEL
        // ====================================================

        final materi =
            data.map<MateriModel>(
          (json) {
            return MateriModel
                .fromJson(
              Map<String,
                  dynamic>.from(
                json,
              ),
              baseUrl:
                  baseUrl,
            );
          },
        ).toList();

        print(
          'Jumlah materi dari API: '
          '${materi.length}',
        );

        // ====================================================
        // SIMPAN KE CACHE
        // ====================================================

        await _saveMateriCache(
          kelasId,
          kategoriId,
          materi,
        );

        print(
          'Materi terbaru berhasil disimpan ke perangkat.',
        );

        return materi;
      }

      // ======================================================
      // RESPONSE BUKAN 200
      // ======================================================

      print(
        'API mengembalikan status '
        '${response.statusCode}.',
      );

      // Coba cache
      final cachedMateri =
          await _getMateriCache(
        kelasId,
        kategoriId,
      );

      if (cachedMateri.isNotEmpty) {
        print(
          'Menggunakan materi dari cache.',
        );

        return cachedMateri;
      }

      // Ambil message dari server
      String message =
          'Gagal mengambil materi. '
          'Status: ${response.statusCode}';

      try {
        final decoded =
            jsonDecode(
          response.body,
        );

        if (decoded is Map &&
            decoded['message'] !=
                null) {
          message =
              decoded['message']
                  .toString();
        }
      } catch (_) {}

      throw Exception(
        message,
      );
    } catch (e) {
      // ======================================================
      // OFFLINE / ERROR
      // ======================================================

      print('');
      print(
        '======================================',
      );
      print(
        'API MATERI TIDAK DAPAT DIAKSES',
      );
      print(
        '$e',
      );
      print(
        'Mencoba mengambil cache...',
      );
      print(
        '======================================',
      );

      final cachedMateri =
          await _getMateriCache(
        kelasId,
        kategoriId,
      );

      // ======================================================
      // CACHE TERSEDIA
      // ======================================================

      if (cachedMateri.isNotEmpty) {
        print(
          'OFFLINE MODE',
        );

        print(
          'Jumlah materi dari cache: '
          '${cachedMateri.length}',
        );

        return cachedMateri;
      }

      // ======================================================
      // CACHE KOSONG
      // ======================================================

      throw Exception(
        'Tidak dapat terhubung ke server '
        'dan materi belum tersedia secara offline.',
      );
    }
  }

  // ==========================================================
  // GET DETAIL MATERI
  // ==========================================================

  Future<MateriModel> getDetailMateri(
    String kodeMateri,
  ) async {
    try {
      final uri =
          Uri.parse(
        '$baseUrl/siswa/materi/$kodeMateri',
      );

      print('');
      print(
        '======================================',
      );
      print(
        'REQUEST DETAIL MATERI',
      );
      print(
        '$uri',
      );
      print(
        '======================================',
      );

      // ======================================================
      // REQUEST API
      // ======================================================

      final response =
          await http
              .get(
                uri,
                headers:
                    await _headers(),
              )
              .timeout(
                const Duration(
                  seconds: 5,
                ),
              );

      print(
        'Status Detail Materi: '
        '${response.statusCode}',
      );

      print(
        'Response Detail Materi: '
        '${response.body}',
      );

      // ======================================================
      // BERHASIL
      // ======================================================

      if (response.statusCode == 200) {
        final decodedData =
            jsonDecode(
          response.body,
        );

        dynamic data;

        // Format:
        // {
        //   "data": {...}
        // }

        if (decodedData is Map &&
            decodedData['data'] !=
                null) {
          data =
              decodedData['data'];
        }

        // Format:
        // {...}
        else {
          data =
              decodedData;
        }

        if (data is! Map) {
          throw Exception(
            'Format detail materi tidak sesuai.',
          );
        }

        // ====================================================
        // UBAH JSON MENJADI MODEL
        // ====================================================

        final materi =
            MateriModel.fromJson(
          Map<String,
              dynamic>.from(
            data,
          ),
          baseUrl:
              baseUrl,
        );

        // ====================================================
        // SIMPAN DETAIL + GAMBAR + AUDIO
        // ====================================================

        await _saveDetailCache(
          materi,
        );

        print(
          'Detail materi berhasil diperbarui.',
        );

        return materi;
      }

      // ======================================================
      // SERVER ERROR → CACHE
      // ======================================================

      final cachedMateri =
          await _getDetailCache(
        kodeMateri,
      );

      if (cachedMateri !=
          null) {
        print(
          'Detail materi menggunakan cache.',
        );

        return cachedMateri;
      }

      throw Exception(
        'Gagal mengambil detail materi. '
        'Status: ${response.statusCode}',
      );
    } catch (e) {
      // ======================================================
      // OFFLINE → CACHE
      // ======================================================

      print('');
      print(
        '======================================',
      );
      print(
        'DETAIL MATERI OFFLINE',
      );
      print(
        '$e',
      );
      print(
        'Mencoba cache detail...',
      );
      print(
        '======================================',
      );

      final cachedMateri =
          await _getDetailCache(
        kodeMateri,
      );

      // ======================================================
      // CACHE DITEMUKAN
      // ======================================================

      if (cachedMateri !=
          null) {
        print(
          'Detail materi berhasil dibuka dari cache.',
        );

        return cachedMateri;
      }

      // ======================================================
      // CACHE TIDAK ADA
      // ======================================================

      throw Exception(
        'Materi belum tersedia secara offline.',
      );
    }
  }
}