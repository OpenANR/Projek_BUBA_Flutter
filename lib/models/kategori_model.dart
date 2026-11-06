class KategoriModel {
  const KategoriModel({
    required this.id,
    required this.namaKategori,
  });

  final int id;
  final String namaKategori;

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['kategori_id'];
    final rawNama = json['nama_kategori'] ??
        json['namaKategori'] ??
        json['nama'] ??
        json['name'];

    final id = int.tryParse(rawId.toString());
    final nama = rawNama?.toString().trim();

    if (id == null || nama == null || nama.isEmpty) {
      throw const FormatException('Data kategori dari API tidak valid.');
    }

    return KategoriModel(id: id, namaKategori: nama);
  }
}
