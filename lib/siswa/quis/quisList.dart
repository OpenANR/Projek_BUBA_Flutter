import 'package:flutter/material.dart';

import '../../models/kuis_model.dart';
import '../../services/kuis_services.dart';
import 'quis.dart';

class QuisListPage extends StatefulWidget {
  final int kelasId;
  final int kategoriId;
  final String namaKelas;
  final String namaKategori;

  const QuisListPage({
    super.key,
    required this.kelasId,
    required this.kategoriId,
    this.namaKelas = '',
    this.namaKategori = '',
  });

  @override
  State<QuisListPage> createState() => _QuisListPageState();
}

class _QuisListPageState extends State<QuisListPage> {
  final KuisServices _services = KuisServices();

  List<KuisModel> daftarKuis = [];
  bool loading = true;
  String? error;

  static const Color _blue = Color(0xFF2865CC);
  static const Color _darkBlue = Color(0xFF2459A6);
  static const Color _lightBlue = Color(0xFF5EBEF3);
  static const Color _green = Color(0xFF71BF4F);
  static const Color _orange = Color(0xFFFAA63A);

  @override
  void initState() {
    super.initState();
    loadKuis();
  }

  Future<void> loadKuis() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final data = await _services.getKuis(
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
      );

      if (!mounted) return;

      setState(() {
        daftarKuis = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 10,
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
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'DAFTAR KUIS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgroundSplash.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: RefreshIndicator(
              color: _blue,
              onRefresh: loadKuis,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 75, 20, 30),
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 22),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  if (loading)
                    _buildLoading()
                  else if (error != null)
                    _buildError()
                  else if (daftarKuis.isEmpty)
                    _buildEmpty()
                  else
                    ...List.generate(
                      daftarKuis.length,
                      (index) => _buildCard(
                        daftarKuis[index],
                        index,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU SAMBUTAN
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ayo Kerjakan Kuis!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.namaKelas} • ${widget.namaKategori}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Uji pengetahuanmu dan kumpulkan bintang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                '📝',
                style: TextStyle(fontSize: 42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU INFORMASI JUMLAH KUIS
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _blue,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _blue,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kuis Tersedia',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7DF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${daftarKuis.length} Soal',
              style: const TextStyle(
                color: Color(0xFF4D9633),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU SETIAP KUIS
  Widget _buildCard(KuisModel kuis, int index) {
    final colors = [
      _blue,
      _green,
      _orange,
      const Color(0xFFAB70D6),
    ];

    final cardColor = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: cardColor,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kuis.kodeKuis,
                  style: TextStyle(
                    color: cardColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: cardColor,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            kuis.pertanyaan,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(
            color: Color(0xFFEEEEEE),
            thickness: 1,
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: Colors.grey,
              ),
              SizedBox(width: 7),
              Text(
                'Pertanyaan kuis',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuisPage(
                      quisId: kuis.id,
                      kelasId: widget.kelasId,
                      kategoriId: widget.kategoriId,
                      namaKategori: widget.namaKategori,
                      daftarKuis: daftarKuis,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
                size: 25,
              ),
              label: const Text(
                'Mulai Kuis',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOADING
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(45),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: _blue,
            ),
            SizedBox(height: 15),
            Text(
              'Sedang memuat kuis...',
              style: TextStyle(
                color: _darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // JIKA KUIS KOSONG
  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _lightBlue,
          width: 2,
        ),
      ),
      child: const Column(
        children: [
          Text(
            '📚',
            style: TextStyle(fontSize: 55),
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Kuis',
            style: TextStyle(
              color: _darkBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Kuis untuk kategori ini belum tersedia. Yuk, cek lagi nanti!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // JIKA TERJADI ERROR
  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Kuis',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 17),
          ElevatedButton.icon(
            onPressed: loadKuis,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
