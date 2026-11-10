import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/kuis_model.dart';
import '../../services/kuis_services.dart';
import 'hasil_kuis.dart';

class QuisPage extends StatefulWidget {
  final int quisId;
  final int kelasId;
  final int kategoriId;
  final String namaKategori;
  final List<KuisModel> daftarKuis;

  const QuisPage({
    super.key,
    required this.quisId,
    required this.kelasId,
    required this.kategoriId,
    required this.namaKategori,
    required this.daftarKuis,
  });

  @override
  State<QuisPage> createState() => _QuisPageState();
}

class _QuisPageState extends State<QuisPage> {
  final KuisServices _kuisServices = KuisServices();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const Color _blue = Color(0xFF1E60BE);
  static const Color _lightBlue = Color(0xFF5EBEF3);
  static const Color _green = Color(0xFF71BF4F);
  static const Color _orange = Color(0xFFFAA63A);
  static const Color _cream = Color(0xFFFFF8EE);

  int nomorSoal = 0;
  final Map<int, String> jawabanSiswa = {};

  bool isSubmitting = false;
  bool isPlayingAudio = false;

  KuisModel get soal => widget.daftarKuis[nomorSoal];

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        isPlayingAudio = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ================= AUDIO =================

  Future<void> putarAudio(String? url) async {
    if (url == null || url.trim().isEmpty) {
      tampilkanPesan('Audio belum tersedia.');
      return;
    }

    try {
      await _audioPlayer.stop();

      if (!mounted) return;

      setState(() {
        isPlayingAudio = true;
      });

      await _audioPlayer.play(
        UrlSource(url.trim()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPlayingAudio = false;
      });

      tampilkanPesan('Audio tidak dapat diputar. Periksa URL audio.');
    }
  }

  Future<void> hentikanAudio() async {
    try {
      await _audioPlayer.stop();

      if (mounted) {
        setState(() {
          isPlayingAudio = false;
        });
      }
    } catch (_) {
      // Abaikan jika audio sudah berhenti.
    }
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ================= JAWABAN =================

  void pilihJawaban(String pilihan) {
    if (isSubmitting) return;

    setState(() {
      jawabanSiswa[soal.id] = pilihan;
    });
  }

  Future<void> soalSelanjutnya() async {
    if (nomorSoal >= widget.daftarKuis.length - 1) return;

    await hentikanAudio();

    if (!mounted) return;

    setState(() {
      nomorSoal++;
    });
  }

  Future<void> soalSebelumnya() async {
    if (nomorSoal <= 0) return;

    await hentikanAudio();

    if (!mounted) return;

    setState(() {
      nomorSoal--;
    });
  }

  Future<void> pindahKeSoal(int index) async {
    if (index < 0 || index >= widget.daftarKuis.length) return;
    if (index == nomorSoal || isSubmitting) return;

    await hentikanAudio();

    if (!mounted) return;

    setState(() {
      nomorSoal = index;
    });
  }

  // ================= SELESAI KUIS =================

  Future<void> konfirmasiSelesai() async {
    if (isSubmitting) return;

    final belumDijawab = widget.daftarKuis
        .where((item) => !jawabanSiswa.containsKey(item.id))
        .length;

    if (belumDijawab > 0) {
      tampilkanPesan(
        'Masih ada $belumDijawab soal yang belum dijawab.',
      );
      return;
    }

    final lanjut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Selesaikan Kuis?',
          style: TextStyle(
            color: _blue,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin mengirim semua jawaban?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Periksa Lagi',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );

    if (lanjut != true || !mounted) return;

    await hentikanAudio();
    await kirimJawaban();
  }

  Future<void> kirimJawaban() async {
    if (jawabanSiswa.length != widget.daftarKuis.length) {
      tampilkanPesan('Pastikan semua soal sudah dijawab.');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final hasil = await _kuisServices.submitKuis(
        quisId: widget.quisId,
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
        jawaban: jawabanSiswa,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HasilKuisPage(
            hasil: hasil,
            namaKategori: widget.namaKategori,
            kelasId: widget.kelasId,
            kategoriId: widget.kategoriId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      tampilkanPesan('Gagal mengirim jawaban: $e');
    }
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      await hentikanAudio();

                      if (!mounted) return;

                      Navigator.maybePop(context);
                    },
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
                color: _blue,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'KUIS ${widget.namaKategori}'.toUpperCase(),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= KARTU =================

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(17),
    Color borderColor = _blue,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 9,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ================= PROGRESS =================

  Widget progressSoal() {
    final total = widget.daftarKuis.length;
    final terjawab = jawabanSiswa.length;

    return _sectionCard(
      borderColor: _green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: _green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PROGRES PENGERJAAN',
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$terjawab / $total',
                  style: const TextStyle(
                    color: Color(0xFF438C2D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : terjawab / total,
              minHeight: 12,
              backgroundColor: const Color(0xFFE9EEF5),
              color: _green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kamu sudah menjawab $terjawab dari $total soal.',
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= LABEL =================

  Widget _labelSection(
    String text, {
    IconData? icon,
    Color color = _blue,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: color,
            size: 21,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ================= PERTANYAAN =================

  Widget kartuPertanyaan() {
    final audioTersedia = soal.audioPertanyaanUrl != null &&
        soal.audioPertanyaanUrl!.trim().isNotEmpty;

    return _sectionCard(
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
                  color: const Color(0xFFFFF0D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  soal.kodeKuis,
                  style: const TextStyle(
                    color: Color(0xFFB66B00),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'SOAL ${nomorSoal + 1} / ${widget.daftarKuis.length}',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _labelSection(
            'PERTANYAAN',
            icon: Icons.help_rounded,
          ),
          const SizedBox(height: 10),
          Text(
            soal.pertanyaan,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          if (audioTersedia) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _AudioButton(
                label: isPlayingAudio
                    ? 'PUTAR ULANG PERTANYAAN'
                    : 'DENGARKAN PERTANYAAN',
                onPressed: () => putarAudio(
                  soal.audioPertanyaanUrl,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= GAMBAR SOAL =================

  Widget gambarSoal() {
    final gambar = soal.gambarUrls
        .where((url) => url.trim().isNotEmpty)
        .toList();

    if (gambar.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      borderColor: _orange,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelSection(
            'GAMBAR PERTANYAAN',
            icon: Icons.image_rounded,
            color: const Color(0xFFB66B00),
          ),
          const SizedBox(height: 12),
          ...gambar.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 100,
                    maxHeight: 260,
                  ),
                  color: const Color(0xFFF5F8FC),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _blue,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const SizedBox(
                        height: 130,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: 38,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PILIHAN JAWABAN =================

  Widget pilihanJawaban({
    required String kode,
    required String teks,
    required String? audio,
  }) {
    final dipilih = jawabanSiswa[soal.id] == kode;
    final audioTersedia = audio != null && audio.trim().isNotEmpty;

    return AnimatedScale(
      scale: dipilih ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: dipilih
              ? const Color(0xFFEAF2FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: dipilih
                ? _blue
                : const Color(0xFFDCE6F0),
            width: dipilih ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: isSubmitting
                ? null
                : () => pilihJawaban(kode),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Container(
                    height: 43,
                    width: 43,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dipilih
                          ? _blue
                          : const Color(0xFFEAF4FC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dipilih
                            ? Colors.white
                            : _lightBlue,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      kode,
                      style: TextStyle(
                        color: dipilih ? Colors.white : _blue,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      teks,
                      style: TextStyle(
                        color: const Color(0xFF263238),
                        fontSize: 15,
                        fontWeight: dipilih
                            ? FontWeight.w800
                            : FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (audioTersedia)
                    IconButton(
                      tooltip: 'Putar audio pilihan $kode',
                      onPressed: isSubmitting
                          ? null
                          : () => putarAudio(audio),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: _blue,
                        size: 25,
                      ),
                    ),
                  if (dipilih)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                      size: 25,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget kartuPilihanJawaban() {
    return _sectionCard(
      borderColor: _orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelSection(
            'PILIHAN JAWABAN',
            icon: Icons.checklist_rounded,
            color: const Color(0xFFB66B00),
          ),
          const SizedBox(height: 16),
          pilihanJawaban(
            kode: 'A',
            teks: soal.pilihanA,
            audio: soal.audioPilihanAUrl,
          ),
          pilihanJawaban(
            kode: 'B',
            teks: soal.pilihanB,
            audio: soal.audioPilihanBUrl,
          ),
          pilihanJawaban(
            kode: 'C',
            teks: soal.pilihanC,
            audio: soal.audioPilihanCUrl,
          ),
          pilihanJawaban(
            kode: 'D',
            teks: soal.pilihanD,
            audio: soal.audioPilihanDUrl,
          ),
        ],
      ),
    );
  }

  // ================= NOMOR SOAL =================

  Widget navigasiNomorSoal() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        widget.daftarKuis.length,
        (index) {
          final item = widget.daftarKuis[index];
          final aktif = index == nomorSoal;
          final terjawab = jawabanSiswa.containsKey(item.id);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: aktif
                  ? _blue
                  : terjawab
                      ? const Color(0xFFEAF6E4)
                      : const Color(0xFFF3F8FC),
              shape: CircleBorder(
                side: BorderSide(
                  color: aktif
                      ? Colors.white
                      : terjawab
                          ? _green
                          : const Color(0xFFB9D8F2),
                  width: aktif ? 3 : 2,
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isSubmitting
                    ? null
                    : () => pindahKeSoal(index),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: aktif
                            ? Colors.white
                            : terjawab
                                ? const Color(0xFF438C2D)
                                : _blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget kartuNavigasiSoal() {
    return _sectionCard(
      borderColor: _green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelSection(
            'NOMOR SOAL',
            icon: Icons.grid_view_rounded,
            color: const Color(0xFF438C2D),
          ),
          const SizedBox(height: 14),
          navigasiNomorSoal(),
          const SizedBox(height: 13),
          Wrap(
            spacing: 15,
            runSpacing: 8,
            children: [
              _legend(
                const Color(0xFF1E60BE),
                'Sedang dibuka',
              ),
              _legend(
                const Color(0xFF71BF4F),
                'Sudah dijawab',
              ),
              _legend(
                const Color(0xFFB9D8F2),
                'Belum dijawab',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ================= TOMBOL NAVIGASI =================

  Widget tombolNavigasi() {
    final soalTerakhir =
        nomorSoal == widget.daftarKuis.length - 1;

    return Row(
      children: [
        Expanded(
          child: _NavigationButton(
            label: 'SEBELUMNYA',
            icon: Icons.arrow_back_rounded,
            backgroundColor: _lightBlue,
            foregroundColor: Colors.white,
            outlined: true,
            onPressed: nomorSoal > 0 && !isSubmitting
                ? soalSebelumnya
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NavigationButton(
            label: soalTerakhir
                ? 'SELESAI'
                : 'SELANJUTNYA',
            icon: soalTerakhir
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
            backgroundColor: soalTerakhir ? _green : _blue,
            foregroundColor: Colors.white,
            onPressed: isSubmitting
                ? null
                : soalTerakhir
                    ? konfirmasiSelesai
                    : soalSelanjutnya,
          ),
        ),
      ],
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgroundSplash.png',
            fit: BoxFit.cover,
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
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada soal kuis tersedia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (widget.daftarKuis.isEmpty) {
      return _buildEmptyState();
    }

    return PopScope(
      canPop: !isSubmitting,
      child: Scaffold(
        backgroundColor: _cream,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/backgroundSplash.png',
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
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isLandscape =
                            constraints.maxWidth > constraints.maxHeight;

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 48 : 20,
                            vertical: 20,
                          ),
                          children: [
                            progressSoal(),
                            const SizedBox(height: 18),
                            kartuPertanyaan(),
                            const SizedBox(height: 16),
                            gambarSoal(),
                            if (soal.gambarUrls.isNotEmpty)
                              const SizedBox(height: 2),
                            kartuPilihanJawaban(),
                            const SizedBox(height: 16),
                            kartuNavigasiSoal(),
                            const SizedBox(height: 20),
                            tombolNavigasi(),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isSubmitting)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(22),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: _blue,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Mengirim jawaban...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}

// ================= TOMBOL KEMBALI =================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback? onPressed;

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

// ================= TOMBOL AUDIO =================

class _AudioButton extends StatelessWidget {
  const _AudioButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.volume_up_rounded,
        size: 19,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEAF2FF),
        foregroundColor: const Color(0xFF1E60BE),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFF1E60BE),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ================= TOMBOL NAVIGASI =================

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 19,
      ),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: outlined ? Colors.white : backgroundColor,
        foregroundColor: outlined
            ? const Color(0xFF1E60BE)
            : foregroundColor,
        disabledBackgroundColor: Colors.white54,
        disabledForegroundColor: Colors.grey,
        elevation: outlined ? 0 : 4,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: outlined ? backgroundColor : Colors.white,
            width: outlined ? 2.5 : 2,
          ),
        ),
      ),
    );
  }
}
