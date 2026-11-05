class KelasModel {
  const KelasModel({required this.id, required this.namaKelas});

  final int id;
  final String namaKelas;

  int get kelasId => id;

  factory KelasModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    final rawNamaKelas = map['nama_kelas'];

    if (id == null || id <= 0) {
      throw const FormatException('ID kelas dari API tidak valid.');
    }
    if (rawNamaKelas is! String || rawNamaKelas.trim().isEmpty) {
      throw const FormatException('Nama kelas dari API tidak valid.');
    }

    return KelasModel(id: id, namaKelas: rawNamaKelas);
  }
}
