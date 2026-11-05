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

  // Mengubah nilai API menjadi integer dengan aman
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Hasil Kuis',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 15),

              // Kartu hasil nilai
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        skor >= 70
                            ? Icons.emoji_events
                            : Icons.school,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Kuis Selesai!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      pesanHasil,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'NILAI KAMU',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$skor',
                      style: const TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const Text(
                      'dari 100',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Bintang yang Kamu Dapatkan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: Icon(
                            index < jumlahBintang
                                ? Icons.star
                                : Icons.star_border,
                            size: 38,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '$jumlahBintang dari 5 bintang',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rincian hasil
              const Text(
                'Rincian Hasil',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _statistikCard(
                      icon: Icons.check_circle,
                      warna: Colors.green,
                      judul: 'Benar',
                      nilai: jumlahBenar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statistikCard(
                      icon: Icons.cancel,
                      warna: Colors.red,
                      judul: 'Salah',
                      nilai: jumlahSalah,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statistikCard(
                      icon: Icons.quiz,
                      warna: Colors.blue,
                      judul: 'Total',
                      nilai: totalSoal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status reward
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: terkunci
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: terkunci
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      terkunci
                          ? Icons.lock_open
                          : Icons.lock_outline,
                      size: 35,
                      color: terkunci
                          ? Colors.green
                          : Colors.orange,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Tombol kembali ke daftar kuis
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
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kembali ke Daftar Kuis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Terus belajar dan kumpulkan bintang!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kartu statistik
  Widget _statistikCard({
    required IconData icon,
    required Color warna,
    required String judul,
    required int nilai,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: warna, size: 30),

          const SizedBox(height: 10),

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
            ),
          ),
        ],
      ),
    );
  }
}
