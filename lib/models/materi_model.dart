import '../services/auth_services.dart';

class MateriModel {
  final int id;
  final String kodeMateri;
  final String namaMateri;
  final String isiMateri;
  final String? gambarUrl;
  final String? audioUrl;
  final int? kategoriId;
  final int? kelasId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility getters
  String? get gambar => gambarUrl;
  String? get audio => audioUrl;

  const MateriModel({
    required this.id,
    required this.kodeMateri,
    required this.namaMateri,
    this.isiMateri = '',
    this.gambarUrl,
    this.audioUrl,
    this.kategoriId,
    this.kelasId,
    this.createdAt,
    this.updatedAt,
  });

  // Helper untuk membersihkan / menormalkan URL media agar sesuai dengan host server
  static String? normalizeUrl(dynamic value, {String? baseUrl}) {
    if (value == null) return null;
    final path = value.toString().trim();
    if (path.isEmpty || path == 'null') return null;

    final effectiveBaseUrl = baseUrl ?? AuthServices.baseUrl;
    final root = Uri.tryParse(effectiveBaseUrl);
    if (root == null) return path;

    final serverRoot = '${root.scheme}://${root.authority}/';
    final uri = Uri.tryParse(path);

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
      return path;
    }

    String cleanPath = path.replaceAll('\\', '/');
    cleanPath = cleanPath.replaceFirst(RegExp(r'^/+'), '');
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }

    return Uri.parse(serverRoot).resolve(Uri.encodeFull(cleanPath)).toString();
  }

  // Mengubah JSON dari API menjadi objek MateriModel
  factory MateriModel.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    final rawGambar = json['gambar_url'] ?? json['gambar'];
    final rawAudio = json['audio_url'] ?? json['audio'];

    return MateriModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      kodeMateri: (json['kode_materi'] ?? json['kodeMateri'] ?? '').toString(),
      namaMateri: (json['nama_materi'] ?? json['namaMateri'] ?? '').toString(),
      isiMateri: (json['isi_materi'] ?? json['isiMateri'] ?? '').toString(),
      gambarUrl: normalizeUrl(rawGambar, baseUrl: baseUrl),
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
      gambarUrl: gambarUrl ?? this.gambarUrl,
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
      'audio_url': audioUrl,
      'kategori_id': kategoriId,
      'kelas_id': kelasId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
