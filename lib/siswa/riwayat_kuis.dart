import 'package:flutter/material.dart';
import '../services/kuis_services.dart';

class RiwayatKuisPage extends StatefulWidget {
  const RiwayatKuisPage({super.key});

  @override
  State<RiwayatKuisPage> createState() => _RiwayatKuisPageState();
}

class _RiwayatKuisPageState extends State<RiwayatKuisPage> {
  final KuisServices _services = KuisServices();

  List<Map<String, dynamic>> daftarRiwayat = [];

  bool isLoading = true;
  String? pesanError;

  static const Color _blue = Color(0xFF1E60BE);
  static const Color _lightBlue = Color(0xFF5EBEF3);
  static const Color _green = Color(0xFF71BF4F);
  static const Color _darkGreen = Color(0xFF62AA43);
  static const Color _cream = Color(0xFFFFF8EE);

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    setState(() {
      isLoading = true;
      pesanError = null;
    });

    try {
      final data = await _services.getRiwayatKuis();

      if (!mounted) return;

      setState(() {
        daftarRiwayat = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        pesanError = e.toString();
        isLoading = false;
      });
    }
  }

  // Mengambil data relasi dari API
  Map<String, dynamic> ambilMap(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  dynamic ambilNilai(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (data[key] != null) {
        return data[key];
      }
    }

    return null;
  }

  int angka(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String namaKuis(Map<String, dynamic> item) {
    final quis = ambilMap(item, 'quis');

    return (ambilNilai(item, ['kode_kuis', 'nama_kuis']) ??
                ambilNilai(quis, ['kode_kuis', 'nama_kuis']))
            ?.toString() ??
        'Kuis';
  }

  String namaKelas(Map<String, dynamic> item) {
    final quis = ambilMap(item, 'quis');
    final kelas = ambilMap(quis, 'kelas');

    return (item['nama_kelas'] ?? kelas['nama_kelas'])?.toString() ??
        'Kelas tidak tersedia';
  }

  String namaKategori(Map<String, dynamic> item) {
    final quis = ambilMap(item, 'quis');
    final kategori = ambilMap(quis, 'kategori');

    return (item['nama_kategori'] ?? kategori['nama_kategori'])
            ?.toString() ??
        'Kategori tidak tersedia';
  }

  int get totalKuis => daftarRiwayat.length;

  int get totalBintang {
    return daftarRiwayat.fold(
      0,
      (total, item) => total + angka(item['jumlah_bintang']),
    );
  }

  // Reward diperoleh dihitung dari riwayat dengan minimal 3 bintang.
  int get totalReward {
    return daftarRiwayat.where(
      (item) => angka(item['jumlah_bintang']) >= 3,
    ).length;
  }

  int get rataRata {
    if (daftarRiwayat.isEmpty) return 0;

    final totalSkor = daftarRiwayat.fold<int>(
      0,
      (total, item) => total + angka(item['skor']),
    );

    return (totalSkor / daftarRiwayat.length).round();
  }

  String formatTanggal(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];

      return '${date.day} ${bulan[date.month - 1]} ${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  // KARTU RINGKASAN
  Widget kartuRingkasan({
    required String emoji,
    required int nilai,
    required String judul,
    required Color warnaLatar,
    required Color warnaTeks,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            '$nilai',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: warnaTeks,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            judul,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: warnaTeks,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU RIWAYAT
  Widget kartuRiwayat(Map<String, dynamic> reward) {
    final skor = angka(reward['skor']);
    final benar = angka(reward['jumlah_benar']);
    final salah = angka(reward['jumlah_salah']);
    final bintang = angka(reward['jumlah_bintang']).clamp(0, 5);

    final tanggal = formatTanggal(
      reward['created_at'] ??
          reward['tanggal'] ??
          reward['tanggal_pengerjaan'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KARTU
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKuis(reward),
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${namaKelas(reward)} • ${namaKategori(reward)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📅 ', style: TextStyle(fontSize: 12)),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          // NILAI, BENAR, SALAH
          Row(
            children: [
              Expanded(
                child: _kotakHasil(
                  judul: 'NILAI',
                  nilai: '$skor',
                  warnaLatar: const Color(0xFFEAF5FF),
                  warnaTeks: _blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kotakHasil(
                  judul: 'BENAR',
                  nilai: '$benar',
                  warnaLatar: const Color(0xFFDCFCE7),
                  warnaTeks: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _kotakHasil(
                  judul: 'SALAH',
                  nilai: '$salah',
                  warnaLatar: const Color(0xFFFEE2E2),
                  warnaTeks: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // BINTANG
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'BINTANG YANG DIPEROLEH',
                  style: TextStyle(
                    color: Color(0xFFA16207),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  bintang > 0
                      ? List.generate(bintang, (_) => '⭐').join()
                      : '😢',
                  style: const TextStyle(
                    fontSize: 27,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bintang dari 5 bintang',
                  style: const TextStyle(
                    color: Color(0xFFA16207),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kotakHasil({
    required String judul,
    required String nilai,
    required Color warnaLatar,
    required Color warnaTeks,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            judul,
            style: TextStyle(
              color: warnaTeks,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            nilai,
            style: TextStyle(
              color: warnaTeks,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL KEMBALI
  Widget tombolKembali(BuildContext context) {
    return Material(
      color: _lightBlue,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 4,
        ),
      ),
      elevation: 5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pop(context),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  // BANNER JUDUL
  Widget bannerJudul() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'RIWAYAT REWARD',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // TAMPILAN KOSONG
  Widget tampilanKosong() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF9BCDF1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text('📚', style: TextStyle(fontSize: 55)),
          const SizedBox(height: 12),
          const Text(
            'BELUM ADA RIWAYAT',
            style: TextStyle(
              color: _blue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Kamu belum mengerjakan kuis.\n'
            'Yuk, mulai belajar dan kumpulkan bintang!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          tombolPilihKonten(),
        ],
      ),
    );
  }

  Widget tombolPilihKonten() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
      ),
      child: const Text(
        '🏠  Mulai Belajar',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget tombolPilihKontenBawah() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightBlue,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
      ),
      child: const Text(
        '🏠  Pilih Konten',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // BACKGROUND BUBA
          Image.asset(
            'assets/images/backgroundSplash.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),

          SafeArea(
            child: Stack(
              children: [
                // TOMBOL KEMBALI
                Positioned(
                  left: 15,
                  top: 15,
                  child: tombolKembali(context),
                ),

                // KONTEN UTAMA
                Column(
                  children: [
                    const SizedBox(height: 15),

                    // HEADER BANNER
                    bannerJudul(),

                    const SizedBox(height: 22),

                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : pesanError != null
                              ? Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red,
                                          size: 45,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Gagal Memuat Riwayat',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _blue,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          pesanError!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        ElevatedButton(
                                          onPressed: loadRiwayat,
                                          child: const Text('Coba Lagi'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: loadRiwayat,
                                  child: ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      15,
                                      0,
                                      15,
                                      20,
                                    ),
                                    children: [
                                      // KARTU UTAMA
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(17),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.18,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            // JUDUL PRESTASI
                                            const SizedBox(height: 5),
                                            const Text(
                                              '🏆',
                                              style: TextStyle(fontSize: 57),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'PRESTASI BELAJARMU!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _blue,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            const Text(
                                              'Yuk, lihat perjalanan dan hasil belajarmu!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF475569),
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 23),

                                            // RINGKASAN REWARD
                                            GridView.count(
                                              crossAxisCount: 2,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 1.35,
                                              children: [
                                                kartuRingkasan(
                                                  emoji: '📝',
                                                  nilai: totalKuis,
                                                  judul: 'Kuis Dikerjakan',
                                                  warnaLatar:
                                                      const Color(0xFFEAF5FF),
                                                  warnaTeks: _blue,
                                                ),
                                                kartuRingkasan(
                                                  emoji: '⭐',
                                                  nilai: totalBintang,
                                                  judul: 'Total Bintang',
                                                  warnaLatar:
                                                      const Color(0xFFFEF3C7),
                                                  warnaTeks:
                                                      const Color(0xFFD97706),
                                                ),
                                                kartuRingkasan(
                                                  emoji: '🎁',
                                                  nilai: totalReward,
                                                  judul: 'Reward Diperoleh',
                                                  warnaLatar:
                                                      const Color(0xFFDCFCE7),
                                                  warnaTeks:
                                                      const Color(0xFF16A34A),
                                                ),
                                                kartuRingkasan(
                                                  emoji: '🌟',
                                                  nilai: rataRata,
                                                  judul: 'Rata-rata Nilai',
                                                  warnaLatar:
                                                      const Color(0xFFF3E8FF),
                                                  warnaTeks:
                                                      const Color(0xFF9333EA),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 27),

                                            // JUDUL DAFTAR
                                            Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    '📚 Riwayat Kuis',
                                                    style: TextStyle(
                                                      color: _blue,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 13,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFEAF5FF,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      30,
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$totalKuis Riwayat',
                                                    style: const TextStyle(
                                                      color: _blue,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 15),

                                            // DAFTAR RIWAYAT
                                            if (daftarRiwayat.isEmpty)
                                              tampilanKosong()
                                            else
                                              ...daftarRiwayat.map(
                                                (reward) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 14,
                                                  ),
                                                  child: kartuRiwayat(reward),
                                                ),
                                              ),

                                            const SizedBox(height: 15),

                                            // TOMBOL KEMBALI
                                            tombolPilihKontenBawah(),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      const Center(
                                        child: Text(
                                          'BUBA • Belajar sambil bermain 🌈',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
