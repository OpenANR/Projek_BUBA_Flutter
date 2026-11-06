import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/kelas_model.dart';
import '../../models/materi_model.dart';
import '../../services/auth_services.dart';
import '../../services/materi_services.dart';

class HalamanMateri extends StatefulWidget {
  final KelasModel? kelas;

  const HalamanMateri({
    super.key,
    this.kelas,
  });

  @override
  State<HalamanMateri> createState() => _HalamanMateriState();
}

class _HalamanMateriState extends State<HalamanMateri> {
  // ============================================================
  // DATA
  // ============================================================

  List<KelasModel> daftarKelas = [];
  List<dynamic> daftarKategori = [];
  List<MateriModel> daftarMateri = [];

  MateriModel? materiAktif;

  KelasModel? kelasDipilih;
  dynamic kategoriDipilih;

  bool loading = false;
  String errorMessage = '';

  final AudioPlayer audioPlayer = AudioPlayer();

  final MateriServices materiServices = MateriServices();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.kelas != null) {
      kelasDipilih = widget.kelas;
      ambilKategori();
    } else {
      ambilKelas();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // ============================================================
  // AMBIL KELAS
  // ============================================================

  Future<void> ambilKelas() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final hasil = await materiServices.getKelas();

      if (!mounted) return;

      setState(() {
        daftarKelas = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // AMBIL KATEGORI
  // ============================================================

  Future<void> ambilKategori() async {
    if (kelasDipilih == null) return;

    setState(() {
      loading = true;
      errorMessage = '';
      kategoriDipilih = null;
      daftarMateri = [];
      materiAktif = null;
    });

    try {
      final hasil = await materiServices.getKategori(
        kelasDipilih!.namaKelas,
      );

      if (!mounted) return;

      setState(() {
        daftarKategori = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // AMBIL DAFTAR MATERI
  // ============================================================

  Future<void> ambilDaftarMateri() async {
    if (kelasDipilih == null ||
        kategoriDipilih == null) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = '';
      daftarMateri = [];
      materiAktif = null;
    });

    try {
      final int idKelas = kelasDipilih!.id;

      final int idKategori = int.parse(
        kategoriDipilih['id'].toString(),
      );

      final hasil = await materiServices.getMateri(
        kelasId: idKelas,
        kategoriId: idKategori,
      );

      if (!mounted) return;

      setState(() {
        daftarMateri = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // DETAIL MATERI
  // ============================================================

  Future<void> ambilDetailMateri(int index) async {
    if (index < 0 || index >= daftarMateri.length) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final MateriModel materi = daftarMateri[index];

      if (!mounted) return;

      setState(() {
        materiAktif = materi;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // AUDIO
  // ============================================================

  Future<void> putarAudio(String url) async {
    try {
      await audioPlayer.stop();

      await audioPlayer.play(
        UrlSource(url),
      );
    } catch (e) {
      debugPrint('Gagal memutar audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
    } catch (e) {
      debugPrint('Gagal menghentikan audio: $e');
    }
  }

  // ============================================================
  // URL GAMBAR
  // ============================================================

  String getImageUrl(String? gambar) {
    if (gambar == null || gambar.isEmpty) {
      return '';
    }

    if (gambar.startsWith('http://') ||
        gambar.startsWith('https://')) {
      return gambar;
    }

    final baseUrl =
        AuthServices.baseUrl.replaceFirst('/api', '');

    return '$baseUrl/storage/$gambar';
  }

  // ============================================================
  // URL AUDIO
  // ============================================================

  String getAudioUrl(String audio) {
    if (audio.startsWith('http://') ||
        audio.startsWith('https://')) {
      return audio;
    }

    final baseUrl =
        AuthServices.baseUrl.replaceFirst('/api', '');

    return '$baseUrl/storage/$audio';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/backgroundSplash.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              headerBuba(),
              Expanded(
                child: isiHalaman(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget headerBuba() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (materiAktif != null) {
                stopAudio();

                setState(() {
                  materiAktif = null;
                });
              } else if (kategoriDipilih != null) {
                setState(() {
                  kategoriDipilih = null;
                  daftarMateri = [];
                });
              } else if (widget.kelas == null &&
                  kelasDipilih != null) {
                setState(() {
                  kelasDipilih = null;
                  daftarKategori = [];
                });
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 5),

          const Expanded(
            child: Text(
              'MATERI BUBA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ISI HALAMAN
  // ============================================================

  Widget isiHalaman() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return halamanError();
    }

    if (kelasDipilih == null) {
      return halamanPilihKelas();
    }

    if (kategoriDipilih == null) {
      return halamanPilihKategori();
    }

    if (daftarMateri.isEmpty) {
      return halamanKosong();
    }

    if (materiAktif == null) {
      return halamanDaftarMateri();
    }

    return halamanDetailMateri();
  }

  // ============================================================
  // HALAMAN ERROR
  // ============================================================

  Widget halamanError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 70,
            ),

            const SizedBox(height: 20),

            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                if (kelasDipilih == null) {
                  ambilKelas();
                } else if (kategoriDipilih == null) {
                  ambilKategori();
                } else {
                  ambilDaftarMateri();
                }
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PILIH KELAS
  // ============================================================

  Widget halamanPilihKelas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            '📚 PILIH KELAS!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Pilih kelas untuk melihat materi pembelajaran.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 30),

          ...daftarKelas.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final kelas = entry.value;

              final warna = [
                const Color(0xFF71BF4F),
                const Color(0xFFFAA63A),
                const Color(0xFFD8759C),
                const Color(0xFF5EBEF3),
                const Color(0xFF9C65CD),
              ][index % 5];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    kelasDipilih = kelas;
                  });

                  ambilKategori();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          kelas.namaKelas,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PILIH KATEGORI
  // ============================================================

  Widget halamanPilihKategori() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          const Text(
            '📖 PILIH KATEGORI!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Kelas ${kelasDipilih!.namaKelas}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 30),

          ...daftarKategori.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final kategori = entry.value;

              final warna = [
                const Color(0xFF71BF4F),
                const Color(0xFFFAA63A),
                const Color(0xFFD8759C),
                const Color(0xFF5EBEF3),
                const Color(0xFF9C65CD),
                const Color(0xFFFFD629),
                const Color(0xFF3CBDB1),
                const Color(0xFFF36B6B),
              ][index % 8];

              final namaKategori =
                  kategori['nama_kategori'] ??
                  kategori['nama'] ??
                  'Kategori';

              return GestureDetector(
                onTap: () {
                  setState(() {
                    kategoriDipilih = kategori;
                  });

                  ambilDaftarMateri();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          namaKategori.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DAFTAR MATERI
  // ============================================================

  Widget halamanDaftarMateri() {
    final namaKategori =
        kategoriDipilih['nama_kategori'] ??
        kategoriDipilih['nama'] ??
        'Kategori';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '📚 PILIH MATERI!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Ayo pilih materi yang ingin kamu pelajari!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              namaKategori.toString(),
              style: const TextStyle(
                color: Color(0xFF1E60BE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Wrap(
            spacing: 15,
            runSpacing: 15,
            children:
                daftarMateri.asMap().entries.map(
              (entry) {
                return kartuMateri(
                  entry.key,
                  entry.value,
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU MATERI
  // ============================================================

  Widget kartuMateri(
    int index,
    MateriModel materi,
  ) {
    final warna = [
      const Color(0xFF71BF4F),
      const Color(0xFFFAA63A),
      const Color(0xFFD8759C),
      const Color(0xFF5EBEF3),
      const Color(0xFF9C65CD),
      const Color(0xFFFFD629),
      const Color(0xFF3CBDB1),
      const Color(0xFFF36B6B),
    ][index % 8];

    final imageUrl = getImageUrl(
      materi.gambar,
    );

    return GestureDetector(
      onTap: () {
        ambilDetailMateri(index);
      },
      child: Container(
        width:
            MediaQuery.of(context).size.width > 600
                ? 270
                : MediaQuery.of(context).size.width - 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color:
                              warna.withOpacity(0.2),
                          child: Icon(
                            Icons.menu_book,
                            color: warna,
                            size: 65,
                          ),
                        );
                      },
                      loadingBuilder:
                          (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }

                        return Container(
                          color:
                              warna.withOpacity(0.2),
                          child: Center(
                            child:
                                CircularProgressIndicator(
                              color: warna,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color:
                          warna.withOpacity(0.2),
                      child: Icon(
                        Icons.menu_book,
                        color: warna,
                        size: 65,
                      ),
                    ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.kodeMateri,
                    style: TextStyle(
                      color: warna,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    materi.namaMateri,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: warna,
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: const Text(
                      'Pelajari →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
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

  // ============================================================
  // DETAIL MATERI
  // ============================================================

  Widget halamanDetailMateri() {
    final MateriModel materi =
        materiAktif!;

    final imageUrl = getImageUrl(
      materi.gambar,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '📖 DETAIL MATERI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (imageUrl.isNotEmpty)
            Container(
              width: double.infinity,
              constraints:
                  const BoxConstraints(
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                            0.2),
                    blurRadius: 10,
                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior:
                  Clip.antiAlias,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color:
                        Colors.white.withOpacity(
                            0.8),
                    child:
                        const Center(
                      child: Icon(
                        Icons
                            .image_not_supported,
                        size: 60,
                        color:
                            Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                          0.15),
                  blurRadius: 10,
                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  materi.kodeMateri,
                  style: const TextStyle(
                    color:
                        Color(0xFF5EBEF3),
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  materi.namaMateri,
                  style: const TextStyle(
                    color:
                        Colors.black87,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 15),

                if (materi
                    .isiMateri
                    .isNotEmpty) ...[
                  const Text(
                    'Materi',
                    style: TextStyle(
                      color:
                          Color(0xFF1E60BE),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    materi.isiMateri,
                    style:
                        const TextStyle(
                      color:
                          Colors.black87,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ],

                if (materi.audio != null &&
                    materi.audio!.isNotEmpty) ...[
                  const SizedBox(height: 25),

                  const Text(
                    '🔊 Audio Materi',
                    style: TextStyle(
                      color:
                          Color(0xFF1E60BE),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            putarAudio(
                              getAudioUrl(
                                materi.audio!,
                              ),
                            );
                          },
                          icon:
                              const Icon(
                            Icons.play_arrow,
                          ),
                          label:
                              const Text(
                            'Putar Audio',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                                    0xFF5EBEF3),
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      IconButton(
                        onPressed:
                            stopAudio,
                        icon:
                            const Icon(
                          Icons.stop,
                        ),
                        color:
                            const Color(
                                0xFFF36B6B),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child:
                ElevatedButton.icon(
              onPressed: () {
                stopAudio();

                setState(() {
                  materiAktif = null;
                });
              },
              icon:
                  const Icon(
                Icons.arrow_back,
              ),
              label:
                  const Text(
                'Kembali ke Daftar Materi',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                        0xFF1E60BE),
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HALAMAN KOSONG
  // ============================================================

  Widget halamanKosong() {
    final namaKategori =
        kategoriDipilih[
                'nama_kategori'] ??
            kategoriDipilih['nama'] ??
            'Kategori';

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(0.9),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.menu_book,
                size: 60,
                color:
                    Color(0xFF5EBEF3),
              ),
            ),

            const SizedBox(
                height: 25),

            const Text(
              'Belum Ada Materi',
              style: TextStyle(
                color:
                    Colors.white,
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            Text(
              'Belum tersedia materi untuk kategori $namaKategori.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 15,
              ),
            ),

            const SizedBox(
                height: 25),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  kategoriDipilih =
                      null;
                  daftarMateri =
                      [];
                  materiAktif =
                      null;
                });
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white,
                foregroundColor:
                    const Color(
                        0xFF1E60BE),
              ),
              child:
                  const Text(
                'Pilih Kategori Lain',
              ),
            ),
          ],
        ),
      ),
    );
  }
}