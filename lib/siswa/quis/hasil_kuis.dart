import 'package:flutter/material.dart';
import 'quisList.dart';

class HasilKuisPage extends StatelessWidget {
  final Map<String, dynamic> hasil;
  final String namaKategori;
  final int kelasId;
  final int kategoriId;
  final String namaKelas;

  const HasilKuisPage({
    super.key,
    required this.hasil,
    required this.namaKategori,
    required this.kelasId,
    required this.kategoriId,
    this.namaKelas = '',
  });

  static const Color _blue = Color(0xFF2865CC);
  static const Color _darkBlue = Color(0xFF2459A6);
  static const Color _orange = Color(0xFFFAA63A);

  int get totalSoal =>
      int.tryParse('${hasil['total_soal'] ?? 0}') ?? 0;

  int get jumlahBenar =>
      int.tryParse('${hasil['jumlah_benar'] ?? 0}') ?? 0;

  int get jumlahSalah =>
      int.tryParse('${hasil['jumlah_salah'] ?? 0}') ?? 0;

  int get skor =>
      int.tryParse('${hasil['skor'] ?? 0}') ?? 0;

  int get jumlahBintang =>
      (int.tryParse('${hasil['jumlah_bintang'] ?? 0}') ?? 0)
          .clamp(0, 5);

  bool get terkunci {
    final nilai = hasil['terkunci'];
    return nilai == true || nilai.toString() == '1';
  }

  String get pesanHasil {
    if (skor >= 90) {
      return 'Luar biasa! Kamu hebat sekali!';
    } else if (skor >= 70) {
      return 'Bagus sekali! Terus pertahankan!';
    } else if (skor >= 50) {
      return 'Bagus! Terus semangat belajar!';
    } else if (skor >= 20) {
      return 'Jangan menyerah, ayo belajar lagi!';
    } else {
      return 'Tetap semangat! Kamu pasti bisa!';
    }
  }

  // JUDUL HALAMAN
  Widget _judulPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 27,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'HASIL KUIS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // KARTU UMUM
  Widget _kartu({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // KARTU STATISTIK
  Widget _statistikCard({
    required IconData icon,
    required Color warna,
    required String judul,
    required int nilai,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: warna.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: warna,
            size: 29,
          ),
          const SizedBox(height: 9),
          Text(
            '$nilai',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            judul,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // BACKGROUND
            Image.asset(
              'assets/images/backgroundSplash.png',
              fit: BoxFit.cover,
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      12,
                      15,
                      15,
                    ),
                    child: Center(
                      child: _judulPill(),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        5,
                        18,
                        25,
                      ),
                      children: [
                        // KARTU NILAI
                        _kartu(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0C2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  skor >= 70
                                      ? Icons.emoji_events_rounded
                                      : Icons.school_rounded,
                                  size: 57,
                                  color: Colors.orange,
                                ),
                              ),

                              const SizedBox(height: 17),

                              const Text(
                                'Kuis Selesai!',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: _blue,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                pesanHasil,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 22),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F3FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'NILAI KAMU',
                                  style: TextStyle(
                                    color: _darkBlue,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                '$skor',
                                style: const TextStyle(
                                  fontSize: 65,
                                  fontWeight: FontWeight.bold,
                                  color: _blue,
                                ),
                              ),

                              const Text(
                                'dari 100',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 22),

                              const Text(
                                'Bintang yang Kamu Dapatkan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _darkBlue,
                                ),
                              ),

                              const SizedBox(height: 13),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      index < jumlahBintang
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 39,
                                      color: Colors.amber,
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                '$jumlahBintang dari 5 bintang',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _orange,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // RINCIAN HASIL
                        _kartu(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    color: _blue,
                                    size: 25,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Rincian Hasil',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: _blue,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 17),

                              Row(
                                children: [
                                  Expanded(
                                    child: _statistikCard(
                                      icon: Icons.check_circle_rounded,
                                      warna: Colors.green,
                                      judul: 'Benar',
                                      nilai: jumlahBenar,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _statistikCard(
                                      icon: Icons.cancel_rounded,
                                      warna: Colors.red,
                                      judul: 'Salah',
                                      nilai: jumlahSalah,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: _statistikCard(
                                      icon: Icons.quiz_rounded,
                                      warna: _blue,
                                      judul: 'Total',
                                      nilai: totalSoal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // STATUS REWARD
                        _kartu(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: terkunci
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: terkunci
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: terkunci
                                          ? Colors.green.shade200
                                          : Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    terkunci
                                        ? Icons.lock_open_rounded
                                        : Icons.lock_outline_rounded,
                                    size: 30,
                                    color: terkunci
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        terkunci
                                            ? 'Reward Terbuka!'
                                            : 'Reward Belum Terbuka',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: terkunci
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        terkunci
                                            ? 'Selamat! Kamu berhasil mendapatkan minimal 3 bintang.'
                                            : 'Ayo tingkatkan nilaimu untuk mendapatkan minimal 3 bintang.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // TOMBOL KEMBALI
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuisListPage(
                                    kelasId: kelasId,
                                    kategoriId: kategoriId,
                                    namaKelas: namaKelas,
                                    namaKategori: namaKategori,
                                  ),
                                ),
                                (route) => route.isFirst,
                              );
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 23,
                            ),
                            label: const Text(
                              'Kembali ke Daftar Kuis',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Center(
                          child: Text(
                            'Terus belajar dan kumpulkan bintang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
