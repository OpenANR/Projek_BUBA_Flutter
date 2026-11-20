import 'package:flutter/material.dart';

import '../../models/materi_model.dart';
import '../../services/materi_services.dart';
import 'materi.dart';

class MateriListPage extends StatefulWidget {
  final int kelasId;
  final int kategoriId;
  final String namaKelas;
  final String namaKategori;

  const MateriListPage({
    super.key,
    required this.kelasId,
    required this.kategoriId,
    required this.namaKelas,
    required this.namaKategori,
  });

  @override
  State<MateriListPage> createState() => _MateriListPageState();
}

class _MateriListPageState extends State<MateriListPage> {
  final MateriServices _services = MateriServices();

  List<MateriModel> daftarMateri = [];

  bool loading = true;
  String? error;

  final Color blue = const Color(0xFF2865CC);
  final Color darkBlue = const Color(0xFF2459A6);
  final Color lightBlue = const Color(0xFF5EBEF3);
  final Color green = const Color(0xFF71BF4F);
  final Color orange = const Color(0xFFFAA63A);

  @override
  void initState() {
    super.initState();
    loadMateri();
  }

  // ==========================================================
  // AMBIL DATA MATERI
  // ==========================================================
  Future<void> loadMateri() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      print('======================================');
      print('REQUEST LIST MATERI');
      print('Kelas ID    : ${widget.kelasId}');
      print('Kategori ID : ${widget.kategoriId}');
      print('======================================');

      final hasil = await _services.getMateri(
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
      );

      print('Jumlah materi: ${hasil.length}');

      if (!mounted) return;

      setState(() {
        daftarMateri = hasil;
        loading = false;
      });
    } catch (e) {
      print('ERROR LIST MATERI: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'DAFTAR MATERI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),

        centerTitle: true,
      ),

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
          child: RefreshIndicator(
            onRefresh: loadMateri,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                35,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // WELCOME CARD
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Container(
                          width: 60,
                          height: 60,

                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 33,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const Text(
                                'Yuk Belajar! 📚',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2459A6),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                widget.namaKategori,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // INFO KELAS & KATEGORI
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),

                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child: _infoItem(
                            Icons.school_rounded,
                            'Kelas',
                            widget.namaKelas,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 45,
                          color: Colors.white.withOpacity(0.4),
                        ),

                        Expanded(
                          child: _infoItem(
                            Icons.category_rounded,
                            'Kategori',
                            widget.namaKategori,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // JUDUL
                  // ==================================================
                  Row(
                    children: [

                      Container(
                        width: 6,
                        height: 28,

                        decoration: BoxDecoration(
                          color: orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Pilih Materi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2459A6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // LOADING
                  // ==================================================
                  if (loading)
                    _buildLoading()

                  // ==================================================
                  // ERROR
                  // ==================================================
                  else if (error != null)
                    _buildError()

                  // ==================================================
                  // DATA KOSONG
                  // ==================================================
                  else if (daftarMateri.isEmpty)
                    _buildEmpty()

                  // ==================================================
                  // LIST MATERI
                  // ==================================================
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount: daftarMateri.length,

                      itemBuilder: (context, index) {
                        return _buildMateriCard(
                          daftarMateri[index],
                          index,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INFO ITEM
  // ==========================================================
  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          color: Colors.white,
          size: 27,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================
  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 55,
      ),

      child: Column(
        children: [

          CircularProgressIndicator(
            color: blue,
          ),

          const SizedBox(height: 15),

          const Text(
            'Sedang mengambil materi...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================
  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.redAccent,
          ),

          const SizedBox(height: 12),

          const Text(
            'Gagal mengambil materi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            error ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: loadMateri,

            icon: const Icon(
              Icons.refresh_rounded,
            ),

            label: const Text(
              'Coba Lagi',
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================
  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          Icon(
            Icons.menu_book_outlined,
            size: 65,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 15),

          const Text(
            'Belum Ada Materi',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2459A6),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Materi untuk kategori ini belum tersedia.',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARD MATERI
  // ==========================================================
  Widget _buildMateriCard(
    MateriModel materi,
    int index,
  ) {
    final List<Color> warna = [
      const Color(0xFF71BF4F),
      const Color(0xFFFAA63A),
      const Color(0xFFD8759C),
      const Color(0xFF5EBEF3),
      const Color(0xFF9C65CD),
      const Color(0xFFFFD629),
      const Color(0xFF3CBDB1),
      const Color(0xFFF36B6B),
    ];

    final Color warnaCard =
        warna[index % warna.length];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 9,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // KODE + ICON
            // ==================================================
            Row(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: warnaCard.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Text(
                    materi.kodeMateri,
                    style: TextStyle(
                      color: warnaCard,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color: warnaCard,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================
            // NAMA MATERI
            // ==================================================
            Text(
              materi.namaMateri,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // ISI SINGKAT
            // ==================================================
            Text(
              _potongIsi(materi.isiMateri),

              maxLines: 3,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 15),

            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // INFORMASI
            // ==================================================
            Row(
              children: [

                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: warnaCard,
                ),

                const SizedBox(width: 6),

                const Text(
                  'Materi pembelajaran',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(),

                if (materi.gambar != null &&
                    materi.gambar!.isNotEmpty)
                  const Row(
                    children: [

                      Icon(
                        Icons.image_rounded,
                        size: 18,
                        color: Colors.green,
                      ),

                      SizedBox(width: 5),

                      Text(
                        'Gambar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                if (materi.audio != null &&
                    materi.audio!.isNotEmpty)
                  const Row(
                    children: [

                      SizedBox(width: 10),

                      Icon(
                        Icons.volume_up_rounded,
                        size: 18,
                        color: Colors.orange,
                      ),

                      SizedBox(width: 5),

                      Text(
                        'Audio',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================
            // BUTTON PELAJARI
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => MateriPage(
                        materi: materi,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 25,
                ),

                label: const Text(
                  'Pelajari Materi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: warnaCard,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // POTONG ISI
  // ==========================================================
  String _potongIsi(String text) {
    String bersih = text
        .replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        )
        .replaceAll(
          '\n',
          ' ',
        )
        .trim();

    if (bersih.isEmpty) {
      return 'Materi pembelajaran tersedia. Yuk mulai belajar!';
    }

    if (bersih.length <= 150) {
      return bersih;
    }

    return '${bersih.substring(0, 150)}...';
  }
}