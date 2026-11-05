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

  factory KuisModel.fromMap(Map<String, dynamic> map) {
    return KuisModel(
      id: int.parse(map['id'].toString()),
      kodeKuis: map['kode_kuis']?.toString() ?? '',
      pertanyaan: map['pertanyaan']?.toString() ?? '',
      gambarUrls: (map['gambar_urls'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      audioPertanyaanUrl: map['audio_pertanyaan_url']?.toString(),
      pilihanA: map['pilihan_a']?.toString() ?? '',
      pilihanB: map['pilihan_b']?.toString() ?? '',
      pilihanC: map['pilihan_c']?.toString() ?? '',
      pilihanD: map['pilihan_d']?.toString() ?? '',
      audioPilihanAUrl: map['audio_pilihan_a_url']?.toString(),
      audioPilihanBUrl: map['audio_pilihan_b_url']?.toString(),
      audioPilihanCUrl: map['audio_pilihan_c_url']?.toString(),
      audioPilihanDUrl: map['audio_pilihan_d_url']?.toString(),
    );
  }
}
