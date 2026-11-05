class MateriModel {
  final int id;
  final String kodeMateri;
  final String namaMateri;
  final String isiMateri;
  final String? gambar;
  final String? audio;
  final int kategoriId;
  final int kelasId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MateriModel({
    required this.id,
    required this.kodeMateri,
    required this.namaMateri,
    required this.isiMateri,
    this.gambar,
    this.audio,
    required this.kategoriId,
    required this.kelasId,
    this.createdAt,
    this.updatedAt,
  });

  // Mengubah JSON dari API menjadi objek MateriModel
  factory MateriModel.fromJson(Map<String, dynamic> json) {
    return MateriModel(
      id: int.parse(json['id'].toString()),
      kodeMateri: json['kode_materi'] ?? '',
      namaMateri: json['nama_materi'] ?? '',
      isiMateri: json['isi_materi'] ?? '',
      gambar: json['gambar'],
      audio: json['audio'],
      kategoriId: int.parse(json['kategori_id'].toString()),
      kelasId: int.parse(json['kelas_id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // Mengubah objek MateriModel menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_materi': kodeMateri,
      'nama_materi': namaMateri,
      'isi_materi': isiMateri,
      'gambar': gambar,
      'audio': audio,
      'kategori_id': kategoriId,
      'kelas_id': kelasId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}