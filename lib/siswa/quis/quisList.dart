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
  bool kategoriTerkunci = false;
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
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await _services.getKuis(
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
      );

      if (!mounted) return;

      setState(() {
        daftarKuis = data;
        kategoriTerkunci = _services.kategoriTerkunci;
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

  // HEADER MENGIKUTI HALAMAN PILIH KATEGORI
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E60BE),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white,
                  width: 3.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'DAFTAR KUIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 700 ? 28.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgroundSplash.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: Color(0xFF5CB8E4),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    color: _blue,
                    onRefresh: loadKuis,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        30,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 900,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildWelcomeCard(),
                                const SizedBox(height: 22),
                                _buildInfoCard(),
                                const SizedBox(height: 15),

                                if (!loading &&
                                    error == null &&
                                    kategoriTerkunci) ...[
                                  _buildLockedNotice(),
                                  const SizedBox(height: 15),
                                ],

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

                                const SizedBox(height: 10),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // KARTU SAMBUTAN
  Widget _buildWelcomeCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Container(
          padding: EdgeInsets.all(compact ? 15 : 20),
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
                    Text(
                      'Ayo Kerjakan Kuis!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.namaKelas} • ${widget.namaKategori}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Uji pengetahuanmu dan kumpulkan bintang!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 12 : 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 5 : 8),
              Container(
                width: compact ? 58 : 75,
                height: compact ? 58 : 75,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '📝',
                    style: TextStyle(fontSize: compact ? 32 : 42),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  // PEMBERITAHUAN KATEGORI TERKUNCI
  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _orange,
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_rounded,
            color: Color(0xFFE58A16),
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Kuis Terkunci!',
                  style: TextStyle(
                    color: Color(0xFFB86A0A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Kamu sudah berhasil menyelesaikan kategori ini '
                  'dengan minimal 3 bintang. Kuis tidak dapat '
                  'dikerjakan kembali.',
                  style: TextStyle(
                    color: Color(0xFF795522),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
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
              Flexible(
                child: Container(
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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cardColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
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
                  kategoriTerkunci
                      ? Icons.lock_rounded
                      : Icons.quiz_rounded,
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
              onPressed: kategoriTerkunci
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuisPage(
                            quisId: kuis.id,
                            kelasId: widget.kelasId,
                            kategoriId: widget.kategoriId,
                            namaKategori: widget.namaKategori,
                            daftarKuis: daftarKuis,
                            namaKelas: widget.namaKelas,
                          ),
                        ),
                      );
                    },
              icon: Icon(
                kategoriTerkunci
                    ? Icons.lock_rounded
                    : Icons.play_arrow_rounded,
                size: 25,
              ),
              label: Text(
                kategoriTerkunci ? 'Kuis Terkunci' : 'Mulai Kuis',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                disabledBackgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: kategoriTerkunci ? 0 : 3,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
            CircularProgressIndicator(color: _blue),
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
          Text('📚', style: TextStyle(fontSize: 55)),
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
            'Kuis untuk kategori ini belum tersedia. '
            'Yuk, cek lagi nanti!',
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

// TOMBOL KEMBALI SAMA DENGAN HALAMAN PILIH KATEGORI
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF5EBEF3),
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
