import 'dart:convert';

class KuisModel {
  final int id;
  final String kodeKuis;
  final String pertanyaan;
  final List<String> gambarUrls;
  final String? audioPertanyaanUrl;

  final String pilihanA;
  final String pilihanB;
  final String pilihanC;
  final String pilihanD;

  final String? audioPilihanAUrl;
  final String? audioPilihanBUrl;
  final String? audioPilihanCUrl;
  final String? audioPilihanDUrl;

  KuisModel({
    required this.id,
    required this.kodeKuis,
    required this.pertanyaan,
    required this.gambarUrls,
    this.audioPertanyaanUrl,
    required this.pilihanA,
    required this.pilihanB,
    required this.pilihanC,
    required this.pilihanD,
    this.audioPilihanAUrl,
    this.audioPilihanBUrl,
    this.audioPilihanCUrl,
    this.audioPilihanDUrl,
  });

  // Mengambil alamat utama server Laravel dari baseUrl API.
  static String _getServerRoot(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}/';
  }

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

  // Ekstrak daftar path bersih dari berbagai format input (List, JSON String, string tunggal)
  static List<String> _extractPaths(dynamic value) {
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

  // Membuat URL media (gambar / audio) ke folder storage Laravel
  static String? _makeMediaUrl(dynamic value, String baseUrl) {
    if (value == null) return null;

    final path = value.toString().trim();
    if (path.isEmpty || path == 'null') return null;

    final root = Uri.parse(baseUrl);
    final serverRoot = _getServerRoot(baseUrl);

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

  // Membuat URL audio (mengambil file pertama jika berupa list/array)
  static String? _makeAudioUrl(dynamic value, String baseUrl) {
    final paths = _extractPaths(value);
    if (paths.isEmpty) return null;
    return _makeMediaUrl(paths.first, baseUrl);
  }

  // Membaca gambar dalam bentuk List, JSON String, atau satu path.
  static List<String> _getImages(dynamic value, String baseUrl) {
    final paths = _extractPaths(value);
    return paths
        .map((item) => _makeMediaUrl(item, baseUrl))
        .whereType<String>()
        .toList();
  }

  factory KuisModel.fromMap(
    Map<String, dynamic> map, {
    required String baseUrl,
  }) {
    return KuisModel(
      id: int.tryParse(map['id'].toString()) ?? 0,
      kodeKuis: map['kode_kuis']?.toString() ?? '',
      pertanyaan: map['pertanyaan']?.toString() ?? '',

      // Gambar menggunakan URL storage Laravel.
      gambarUrls: _getImages(
        map['gambar_urls'] ?? map['gambar'],
        baseUrl,
      ),

      // Audio pertanyaan menggunakan URL storage Laravel yang dinormalisasi.
      audioPertanyaanUrl: _makeAudioUrl(
        map['audio_pertanyaan_url'] ?? map['audio_pertanyaan'],
        baseUrl,
      ),

      pilihanA: map['pilihan_a']?.toString() ?? '',
      pilihanB: map['pilihan_b']?.toString() ?? '',
      pilihanC: map['pilihan_c']?.toString() ?? '',
      pilihanD: map['pilihan_d']?.toString() ?? '',

      // Audio setiap pilihan jawaban.
      audioPilihanAUrl: _makeAudioUrl(
        map['audio_pilihan_a_url'] ?? map['audio_pilihan_a'],
        baseUrl,
      ),

      audioPilihanBUrl: _makeAudioUrl(
        map['audio_pilihan_b_url'] ?? map['audio_pilihan_b'],
        baseUrl,
      ),

      audioPilihanCUrl: _makeAudioUrl(
        map['audio_pilihan_c_url'] ?? map['audio_pilihan_c'],
        baseUrl,
      ),

      audioPilihanDUrl: _makeAudioUrl(
        map['audio_pilihan_d_url'] ?? map['audio_pilihan_d'],
        baseUrl,
      ),
    );
  }
}
