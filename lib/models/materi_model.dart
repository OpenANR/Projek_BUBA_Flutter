import 'dart:convert';

import '../services/auth_services.dart';

class MateriModel {
  final int id;
  final String kodeMateri;
  final String namaMateri;
  final String isiMateri;
  final List<String> gambarUrls;
  final String? audioUrl;
  final int? kategoriId;
  final int? kelasId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility getters
  String? get gambarUrl => gambarUrls.isNotEmpty ? gambarUrls.first : null;
  String? get gambar => gambarUrl;
  String? get audio => audioUrl;

  const MateriModel({
    required this.id,
    required this.kodeMateri,
    required this.namaMateri,
    this.isiMateri = '',
    this.gambarUrls = const [],
    this.audioUrl,
    this.kategoriId,
    this.kelasId,
    this.createdAt,
    this.updatedAt,
  });

  // Membersihkan kurung siku, tanda petik, dan spasi yang melilit string
  static String _cleanWrapping(String text) {
    var s = text.trim();
    while (s.isNotEmpty &&
        (s.startsWith('[') ||
            s.startsWith('"') ||
            s.startsWith("'") ||
            s.startsWith(r'\'))) {
      s = s.substring(1).trim();
    }
    while (s.isNotEmpty &&
        (s.endsWith(']') ||
            s.endsWith('"') ||
            s.endsWith("'") ||
            s.endsWith(r'\'))) {
      s = s.substring(0, s.length - 1).trim();
    }
    return s;
  }

  // Ekstrak daftar path bersih dari input (List, JSON String, atau string tunggal)
  static List<String> extractPaths(dynamic value) {
    if (value == null) return [];

    dynamic data = value;

    if (data is String) {
      final text = data.trim();
      if (text.isEmpty || text == 'null') return [];

      if ((text.startsWith('[') && text.endsWith(']')) ||
          (text.startsWith('{') && text.endsWith('}'))) {
        try {
          data = jsonDecode(text);
        } catch (_) {
          final clean = _cleanWrapping(text);
          if (clean.isNotEmpty && clean != 'null') {
            return [clean];
          }
        }
      } else {
        final clean = _cleanWrapping(text);
        if (clean.isNotEmpty && clean != 'null') {
          return [clean];
        }
        return [];
      }
    }

    if (data is List) {
      final result = <String>[];
      for (final item in data) {
        if (item == null) continue;
        final clean = _cleanWrapping(item.toString());
        if (clean.isNotEmpty && clean != 'null') {
          result.add(clean);
        }
      }
      return result;
    } else if (data is Map) {
      final url = data['url'] ?? data['path'] ?? data['file'];
      if (url != null) {
        final clean = _cleanWrapping(url.toString());
        if (clean.isNotEmpty && clean != 'null') return [clean];
      }
    }

    return [];
  }

  // Helper untuk membersihkan / menormalkan sebuah URL media agar sesuai dengan host server
  static String? buildMediaUrl(String path, {String? baseUrl}) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;

    final effectiveBaseUrl = baseUrl ?? AuthServices.baseUrl;
    final root = Uri.tryParse(effectiveBaseUrl);
    if (root == null) return trimmed;

    final serverRoot = '${root.scheme}://${root.authority}/';
    final uri = Uri.tryParse(trimmed);

    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final host = uri.host.toLowerCase();
      if (host == '127.0.0.1' || host == 'localhost' || host == '0.0.0.0') {
        return uri
            .replace(
              host: root.host,
              port: root.hasPort ? root.port : null,
            )
            .toString();
      }
      return trimmed;
    }

    String cleanPath = trimmed.replaceAll('\\', '/');
    cleanPath = cleanPath.replaceFirst(RegExp(r'^/+'), '');
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }

    return Uri.parse(serverRoot).resolve(Uri.encodeFull(cleanPath)).toString();
  }

  // Helper untuk menormalkan satu URL
  static String? normalizeUrl(dynamic value, {String? baseUrl}) {
    final paths = extractPaths(value);
    if (paths.isEmpty) return null;
    return buildMediaUrl(paths.first, baseUrl: baseUrl);
  }

  // Helper untuk menormalkan daftar URL
  static List<String> normalizeUrls(dynamic value, {String? baseUrl}) {
    final paths = extractPaths(value);
    return paths
        .map((p) => buildMediaUrl(p, baseUrl: baseUrl))
        .whereType<String>()
        .toList();
  }

  // Mengubah JSON dari API menjadi objek MateriModel
  factory MateriModel.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    final rawGambar =
        json['gambar_urls'] ?? json['gambar_url'] ?? json['gambar'];
    final rawAudio = json['audio_url'] ?? json['audio'];

    return MateriModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      kodeMateri: (json['kode_materi'] ?? json['kodeMateri'] ?? '').toString(),
      namaMateri: (json['nama_materi'] ?? json['namaMateri'] ?? '').toString(),
      isiMateri: (json['isi_materi'] ?? json['isiMateri'] ?? '').toString(),
      gambarUrls: normalizeUrls(rawGambar, baseUrl: baseUrl),
      audioUrl: normalizeUrl(rawAudio, baseUrl: baseUrl),
      kategoriId: int.tryParse(json['kategori_id']?.toString() ?? ''),
      kelasId: int.tryParse(json['kelas_id']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // Salinan objek dengan perubahan data tertentu
  MateriModel copyWith({
    int? id,
    String? kodeMateri,
    String? namaMateri,
    String? isiMateri,
    List<String>? gambarUrls,
    String? gambarUrl,
    String? audioUrl,
    int? kategoriId,
    int? kelasId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MateriModel(
      id: id ?? this.id,
      kodeMateri: kodeMateri ?? this.kodeMateri,
      namaMateri: namaMateri ?? this.namaMateri,
      isiMateri: isiMateri ?? this.isiMateri,
      gambarUrls:
          gambarUrls ?? (gambarUrl != null ? [gambarUrl] : this.gambarUrls),
      audioUrl: audioUrl ?? this.audioUrl,
      kategoriId: kategoriId ?? this.kategoriId,
      kelasId: kelasId ?? this.kelasId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Mengubah objek MateriModel menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_materi': kodeMateri,
      'nama_materi': namaMateri,
      'isi_materi': isiMateri,
      'gambar_url': gambarUrl,
      'gambar_urls': gambarUrls,
      'audio_url': audioUrl,
      'kategori_id': kategoriId,
      'kelas_id': kelasId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
