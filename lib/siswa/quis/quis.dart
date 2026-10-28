import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

const String baseUrl = 'http://127.0.0.1:8000';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kuis BUBA',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFFF8EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E60BE),
        ),
      ),
      home: const HalamanKuis(),
    );
  }
}

class HalamanKuis extends StatefulWidget {
  const HalamanKuis({super.key});

  @override
  State<HalamanKuis> createState() => _HalamanKuisState();
}

class _HalamanKuisState extends State<HalamanKuis> {
  final AudioPlayer audioPlayer = AudioPlayer();

  List<dynamic> daftarKelas = [];
  List<dynamic> daftarKategori = [];
  List<dynamic> daftarKuis = [];

  Map<String, dynamic>? soalAktif;

  dynamic kelasDipilih;
  dynamic kategoriDipilih;

  String? jawabanDipilih;
  bool sudahDiperiksa = false;
  bool jawabanBenar = false;

  int indexSoal = 0;
  int jumlahBenar = 0;
  int jumlahDijawab = 0;
  bool halamanHasil = false;

  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    ambilKelas();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // Mengambil data kelas dari Laravel
  Future<void> ambilKelas() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/siswa/kuis/pilih-kelas'),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data kelas.');
      }

      final data = decodeResponse(response.body);

      setState(() {
        daftarKelas = data['kelas'] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = pesanError(e);
      });
    }
  }

  // Mengambil kategori berdasarkan nama kelas
  Future<void> ambilKategori(dynamic kelas) async {
    setState(() {
      kelasDipilih = kelas;
      kategoriDipilih = null;
      daftarKategori = [];
      daftarKuis = [];
      soalAktif = null;
      jawabanDipilih = null;
      sudahDiperiksa = false;
      loading = true;
      errorMessage = null;
    });

    try {
      final namaKelas = Uri.encodeComponent(
        kelas['nama_kelas'].toString(),
      );

      final response = await http.get(
        Uri.parse('$baseUrl/api/siswa/kuis/$namaKelas'),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil kategori.');
      }

      final data = decodeResponse(response.body);

      setState(() {
        daftarKategori = data['kategori'] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = pesanError(e);
      });
    }
  }

  // Mengambil daftar soal berdasarkan ID kelas dan kategori
  Future<void> ambilDaftarKuis(dynamic kategori) async {
    setState(() {
      kategoriDipilih = kategori;
      daftarKuis = [];
      soalAktif = null;
      jawabanDipilih = null;
      sudahDiperiksa = false;
      indexSoal = 0;
      jumlahBenar = 0;
      jumlahDijawab = 0;
      halamanHasil = false;
      loading = true;
      errorMessage = null;
    });

    try {
      final idKelas = kelasDipilih['id'];
      final idKategori = kategori['id'];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/siswa/kuis/kuis-list/$idKelas/$idKategori',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil daftar soal.');
      }

      final data = decodeResponse(response.body);
      final hasil = List<dynamic>.from(data['kuis'] ?? []);

      setState(() {
        daftarKuis = hasil;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = pesanError(e);
      });
    }
  }

  // Mengambil detail soal berdasarkan kode kuis
  Future<void> ambilDetailSoal(int index) async {
    if (index < 0 || index >= daftarKuis.length) return;

    setState(() {
      loading = true;
      jawabanDipilih = null;
      sudahDiperiksa = false;
      soalAktif = null;
      errorMessage = null;
    });

    await audioPlayer.stop();

    try {
      final kodeKuis = Uri.encodeComponent(
        daftarKuis[index]['kode_kuis'].toString(),
      );

      final idKelas = kelasDipilih['id'];
      final idKategori = kategoriDipilih['id'];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/siswa/kuis/kuis-show/'
          '$idKelas/$idKategori/$kodeKuis',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil detail soal.');
      }

      final data = decodeResponse(response.body);

      setState(() {
        soalAktif = Map<String, dynamic>.from(data['dataKuis']);
        indexSoal = index;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = pesanError(e);
      });
    }
  }

  Map<String, dynamic> decodeResponse(String body) {
    return Map<String, dynamic>.from(jsonDecode(body));
  }

  String pesanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  // Memutar audio pertanyaan atau pilihan
  Future<void> putarAudio(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      tampilkanPesan('Audio tidak dapat diputar.');
    }
  }

  // Memeriksa jawaban berdasarkan data Laravel
  void periksaJawaban() {
    if (jawabanDipilih == null) {
      tampilkanPesan('Silakan pilih jawaban terlebih dahulu!');
      return;
    }

    final jawabanBenarDatabase =
        soalAktif?['jawaban']?.toString().toUpperCase();

    setState(() {
      sudahDiperiksa = true;
      jawabanBenar =
          jawabanDipilih!.toUpperCase() == jawabanBenarDatabase;
      jumlahDijawab++;
      if (jawabanBenar) jumlahBenar++;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          jawabanBenar ? 'Hebat! 🎉' : 'Coba Lagi! 😊',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          jawabanBenar
              ? 'Jawaban kamu benar!'
              : 'Belum tepat. Yuk, coba perhatikan kembali jawabannya.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E60BE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Oke'),
            ),
          ),
        ],
      ),
    );
  }

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  void kembaliKeKategori() {
    setState(() {
      kategoriDipilih = null;
      daftarKuis = [];
      soalAktif = null;
    });
  }

  void kembaliKeKelas() {
    setState(() {
      kelasDipilih = null;
      kategoriDipilih = null;
      daftarKategori = [];
      daftarKuis = [];
      soalAktif = null;
    });
  }
  
@override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8EE),
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background BUBA
              // Background BUBA
              Image.asset(
                'assets/images/backgroundSplash.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Gagal memuat background: $error');

                  return const ColoredBox(
                    color: Color(0xFFFFF8EE),
                  );
                },
              ),
              // Isi halaman
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          headerBuba(),
                          const SizedBox(height: 24),

                          if (errorMessage != null)
                            errorBox(),

                          if (loading)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            )
                          else if (errorMessage == null)
                            isiHalaman(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

  Widget headerBuba() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E60BE),
        border: Border.all(color: Colors.white, width: 5),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            kelasDipilih == null
                ? 'KUIS BUBA'
                : 'KUIS KELAS ${kelasDipilih['nama_kelas']}'.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Ayo Belajar dan Bermain! ⭐',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget isiHalaman() {
    if (halamanHasil) return halamanHasilKuis();

    if (kelasDipilih == null) {
      return halamanPilihKelas();
    }

    if (kategoriDipilih == null) {
      return halamanPilihKategori();
    }

    if (daftarKuis.isEmpty) {
      return halamanKosong();
    }

    if (soalAktif == null) {
      return halamanDaftarKuis();
    }

    return halamanSoal();
  }

  // Halaman daftar kuis dengan kartu warna-warni
  Widget halamanDaftarKuis() {
    const warna = [
      Color(0xFF71BF4F),
      Color(0xFFFAA63A),
      Color(0xFFD8759C),
      Color(0xFF5EBEF3),
      Color(0xFF9C65CD),
      Color(0xFFFFD629),
      Color(0xFF3CBDB1),
      Color(0xFFF36B6B),
    ];

    const ikon = ['📚', '🎨', '🧩', '🌈', '⭐', '🎵', '🐻', '🎯'];

    return Column(
      children: [
        Row(
          children: [
            tombolKembali(kembaliKeKategori),
            const Spacer(),
            Flexible(
              child: Text(
                'KELAS ${kelasDipilih['nama_kelas']}'.toUpperCase(),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1E60BE),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '🎮 PILIH KUIS!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih kuis yang ingin kamu kerjakan. Yuk, semangat belajar!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Text(
            kategoriDipilih?['nama_kategori']
                    ?.toString()
                    .toUpperCase() ??
                '',
            style: const TextStyle(
              color: Color(0xFF1E60BE),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final lebar = constraints.maxWidth >= 700
                ? 230.0
                : constraints.maxWidth >= 480
                    ? 205.0
                    : 165.0;

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 18,
              children: List.generate(daftarKuis.length, (index) {
                final item = daftarKuis[index];
                final pertanyaan =
                    item['pertanyaan']?.toString() ?? '';

                return InkWell(
                  onTap: () => ambilDetailSoal(index),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: lebar,
                    height: 245,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: warna[index % warna.length],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 12,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -18,
                          top: -18,
                          child: Container(
                            width: 75,
                            height: 75,
                            decoration: const BoxDecoration(
                              color: Color(0x33FFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  ikon[index % ikon.length],
                                  style: const TextStyle(fontSize: 66),
                                ),
                              ),
                            ),
                            Text(
                              'KUIS ${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              pertanyaan.length > 55
                                  ? '${pertanyaan.substring(0, 55)}...'
                                  : pertanyaan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                'Kerjakan  ➜',
                                style: TextStyle(
                                  color: Color(0xFF1E60BE),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // Halaman hasil kuis
  Widget halamanHasilKuis() {
    final total = daftarKuis.length;
    final salah = jumlahDijawab - jumlahBenar;
    final nilai = total == 0
        ? 0
        : ((jumlahBenar / total) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 76)),
          const Text(
            'HEBAT SEKALI!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1E60BE),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu sudah menyelesaikan kuis!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF65758B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'NILAI KAMU',
                  style: TextStyle(
                    color: Color(0xFF1E60BE),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$nilai',
                  style: const TextStyle(
                    color: Color(0xFF1E60BE),
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              hasilAngka(
                '✅',
                '$jumlahBenar',
                'Benar',
                const Color(0xFF71BF4F),
              ),
              const SizedBox(width: 8),
              hasilAngka(
                '❌',
                '$salah',
                'Salah',
                const Color(0xFFF36B6B),
              ),
              const SizedBox(width: 8),
              hasilAngka(
                '📝',
                '$total',
                'Total',
                const Color(0xFFFAA63A),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            nilai >= 90
                ? '🌟 Wah, luar biasa! Kamu pintar sekali!'
                : nilai >= 70
                    ? '🎉 Bagus sekali! Terus tingkatkan kemampuanmu!'
                    : nilai >= 50
                        ? '😊 Bagus! Ayo belajar dan mencoba lagi!'
                        : '💪 Jangan menyerah! Yuk, coba lagi!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF24436B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          tombolUtama(
            'Kembali ke Daftar Kuis',
            Icons.arrow_back,
            () {
              setState(() {
                halamanHasil = false;
                soalAktif = null;
                jawabanDipilih = null;
                sudahDiperiksa = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget hasilAngka(
    String ikon,
    String angka,
    String label,
    Color warna,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: warna.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(ikon, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 5),
            Text(
              angka,
              style: TextStyle(
                color: warna,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: warna,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Halaman pilih kelas
  Widget halamanPilihKelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        judulBagian('Pilih Kelas', 'Yuk, pilih kelasmu!'),
        const SizedBox(height: 18),
        if (daftarKelas.isEmpty)
          halamanKosong()
        else
          ...daftarKelas.map((kelas) {
            return kartuPilihan(
              nama: kelas['nama_kelas']?.toString() ?? 'Kelas',
              warna: const Color(0xFF71BF4F),
              icon: Icons.school_rounded,
              onTap: () => ambilKategori(kelas),
            );
          }),
      ],
    );
  }

  // Halaman pilih kategori
  Widget halamanPilihKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tombolKembali(kembaliKeKelas),
        const SizedBox(height: 18),
        judulBagian(
          'Pilih Kategori',
          'Kelas ${kelasDipilih['nama_kelas']}',
        ),
        const SizedBox(height: 18),
        if (daftarKategori.isEmpty)
          halamanKosong()
        else
          ...daftarKategori.map((kategori) {
            return kartuPilihan(
              nama: kategori['nama_kategori']?.toString() ??
                  'Kategori',
              warna: const Color(0xFFFAA63A),
              icon: Icons.category_rounded,
              onTap: () => ambilDaftarKuis(kategori),
            );
          }),
      ],
    );
  }

  // Halaman mengerjakan soal
  Widget halamanSoal() {
    final soal = soalAktif!;

    final pilihan = [
      {'kode': 'A', 'teks': soal['pilihan_a']},
      {'kode': 'B', 'teks': soal['pilihan_b']},
      {'kode': 'C', 'teks': soal['pilihan_c']},
      {'kode': 'D', 'teks': soal['pilihan_d']},
    ];

    final gambar = List<dynamic>.from(soal['gambar'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tombolKembali(kembaliKeKategori),
        const SizedBox(height: 18),
        judulBagian(
          'Ayo Kerjakan!',
          '${kategoriDipilih['nama_kategori']}',
        ),
        const SizedBox(height: 18),

        // Informasi nomor soal
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E60BE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Text(
            'Soal ${indexSoal + 1} dari ${daftarKuis.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Kartu pertanyaan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFF5EBEF3),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 7,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (gambar.isNotEmpty)
                ...gambar.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        url.toString(),
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  );
                }),

              Text(
                soal['pertanyaan']?.toString() ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF24436B),
                ),
              ),

              if (soal['audio_pertanyaan'] != null)
                audioButton(
                  soal['audio_pertanyaan'].toString(),
                  'Dengarkan Pertanyaan',
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Pilihan jawaban
        ...pilihan.map((item) {
          final kode = item['kode'].toString();
          final teks = item['teks']?.toString() ?? '';

          final audio = soal['audio_pilihan_${kode.toLowerCase()}']
              ?.toString();

          final dipilih = jawabanDipilih == kode;

          final benar = soal['jawaban']?.toString().toUpperCase() == kode;

          Color warna = const Color(0xFF5EBEF3);

          if (sudahDiperiksa && benar) {
            warna = const Color(0xFF71BF4F);
          } else if (sudahDiperiksa && dipilih && !jawabanBenar) {
            warna = const Color(0xFFF36B6B);
          } else if (dipilih) {
            warna = const Color(0xFFFAA63A);
          }

          return GestureDetector(
            onTap: sudahDiperiksa
                ? null
                : () {
                    setState(() {
                      jawabanDipilih = kode;
                    });
                  },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      kode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF24436B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      teks,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (audio != null && audio.isNotEmpty)
                    IconButton(
                      onPressed: () => putarAudio(audio),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  if (sudahDiperiksa && benar)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 10),

        if (!sudahDiperiksa)
          tombolUtama(
            'Periksa Jawaban',
            Icons.check_circle,
            periksaJawaban,
          ),

        if (sudahDiperiksa)
          tombolUtama(
            indexSoal == daftarKuis.length - 1
                ? 'Selesai'
                : 'Soal Selanjutnya',
            Icons.arrow_forward_rounded,
            () {
              if (indexSoal < daftarKuis.length - 1) {
                ambilDetailSoal(indexSoal + 1);
              } else {
                setState(() {
                  halamanHasil = true;
                  soalAktif = null;
                });
              }
            },
          ),

        const SizedBox(height: 12),

        if (indexSoal > 0)
          OutlinedButton.icon(
            onPressed: () => ambilDetailSoal(indexSoal - 1),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Soal Sebelumnya'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: const Color(0xFF1E60BE),
              side: const BorderSide(
                color: Color(0xFF1E60BE),
                width: 2,
              ),
            ),
          ),
      ],
    );
  }

  // Tampilan jika belum ada kuis
  Widget halamanKosong() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5EBEF3),
          width: 3,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sentiment_satisfied_alt_rounded,
            size: 65,
            color: Color(0xFFFAA63A),
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Kuis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF24436B),
            ),
          ),
        ],
      ),
    );
  }

  Widget judulBagian(String judul, String subjudul) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF24436B),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subjudul,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF65758B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget kartuPilihan({
    required String nama,
    required Color warna,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: warna,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 35),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nama,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget tombolKembali(VoidCallback onTap) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF5EBEF3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget audioButton(String url, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: ElevatedButton.icon(
        onPressed: () => putarAudio(url),
        icon: const Icon(Icons.volume_up_rounded),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5EBEF3),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget tombolUtama(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E60BE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget errorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.red,
            size: 35,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (kelasDipilih == null) {
                ambilKelas();
              } else if (kategoriDipilih == null) {
                ambilKategori(kelasDipilih);
              } else {
                ambilDaftarKuis(kategoriDipilih);
              }
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
