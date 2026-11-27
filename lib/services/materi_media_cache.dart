import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MateriMediaCache {
  // ==========================================================
  // MENDAPATKAN FOLDER PENYIMPANAN MATERI
  // ==========================================================

  static Future<Directory> _getMateriDirectory() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final materiDirectory =
        Directory('${directory.path}/materi');

    if (!await materiDirectory.exists()) {
      await materiDirectory.create(
        recursive: true,
      );
    }

    return materiDirectory;
  }

  // ==========================================================
  // MEMBUAT NAMA FILE
  // ==========================================================

  static String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      String fileName =
          uri.pathSegments.isNotEmpty
              ? uri.pathSegments.last
              : '';

      if (fileName.isEmpty) {
        fileName = 'media_${url.hashCode}';
      }

      fileName = fileName.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );

      return fileName;
    } catch (_) {
      return 'media_${url.hashCode}';
    }
  }

  // ==========================================================
  // DOWNLOAD FILE DARI SERVER
  // ==========================================================

  static Future<String?> downloadFile(
    String? url,
  ) async {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    try {
      final directory =
          await _getMateriDirectory();

      final fileName =
          _fileNameFromUrl(url);

      final file =
          File('${directory.path}/$fileName');

      // Jika sudah pernah didownload,
      // tidak perlu download lagi.
      if (await file.exists()) {
        print(
          'Media sudah tersedia: ${file.path}',
        );

        return file.path;
      }

      print(
        'Mendownload media: $url',
      );

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        await file.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        print(
          'Media berhasil disimpan:',
        );
        print(file.path);

        return file.path;
      }

      print(
        'Gagal download media.',
      );
      print(
        'Status: ${response.statusCode}',
      );

      return null;
    } catch (e) {
      print(
        'Error download media: $e',
      );

      return null;
    }
  }

  // ==========================================================
  // CEK FILE LOKAL
  // ==========================================================

  static Future<String?> getLocalFile(
    String? localPath,
  ) async {
    if (localPath == null ||
        localPath.trim().isEmpty) {
      return null;
    }

    final file =
        File(localPath);

    if (await file.exists()) {
      return file.path;
    }

    return null;
  }
}