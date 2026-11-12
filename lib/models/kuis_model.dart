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

  // Membuat URL gambar. Bagian ini tetap menggunakan storage Laravel.
  static String? _makeMediaUrl(dynamic value, String baseUrl) {
    if (value == null) return null;

    final path = value.toString().trim();

    if (path.isEmpty || path == 'null') return null;

    final root = Uri.parse(baseUrl);
    final serverRoot = _getServerRoot(baseUrl);

    final uri = Uri.tryParse(path);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      final host = uri.host.toLowerCase();

      if (host == '127.0.0.1' ||
          host == 'localhost' ||
          host == '0.0.0.0') {
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

    return Uri.parse(serverRoot)
        .resolve(Uri.encodeFull(cleanPath))
        .toString();
  }

  // Membuat URL audio melalui route Laravel khusus agar tidak terkena CORS.
  static String? _makeAudioUrl(dynamic value, String baseUrl) {
    if (value == null) return null;

    final path = value.toString().trim();

    if (path.isEmpty || path == 'null') return null;

    final root = Uri.parse(baseUrl);
    final serverRoot = _getServerRoot(baseUrl);

    final uri = Uri.tryParse(path);

    String filePath;

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      filePath = uri.path;
    } else {
      filePath = path;
    }

    filePath = filePath.replaceAll('\\', '/');

    // Mengambil nama file audio saja.
    final filename = filePath.split('/').last;

    if (filename.isEmpty) return null;

    // Audio menggunakan route khusus Laravel.
    return Uri.parse(serverRoot)
        .resolve('audio-kuis/${Uri.encodeComponent(filename)}')
        .toString();
  }

  // Membaca gambar dalam bentuk List, JSON String, atau satu path.
  static List<String> _getImages(dynamic value, String baseUrl) {
    if (value == null) return [];

    dynamic data = value;

    if (data is String) {
      final text = data.trim();

      if (text.isEmpty) return [];

      try {
        data = jsonDecode(text);
      } catch (_) {
        data = [text];
      }
    }

    if (data is! List) return [];

    return data
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

      // Gambar tetap menggunakan URL storage Laravel.
      gambarUrls: _getImages(
        map['gambar_urls'] ?? map['gambar'],
        baseUrl,
      ),

      // Audio pertanyaan menggunakan route khusus.
      audioPertanyaanUrl: _makeAudioUrl(
        map['audio_pertanyaan_url'] ?? map['audio_pertanyaan'],
        baseUrl,
      ),

      pilihanA: map['pilihan_a']?.toString() ?? '',
      pilihanB: map['pilihan_b']?.toString() ?? '',
      pilihanC: map['pilihan_c']?.toString() ?? '',
      pilihanD: map['pilihan_d']?.toString() ?? '',

      // Audio setiap pilihan jawaban menggunakan route khusus.
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
