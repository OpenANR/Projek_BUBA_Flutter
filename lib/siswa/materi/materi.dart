import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/materi_model.dart';

class MateriPage extends StatefulWidget {
  final MateriModel materi;

  const MateriPage({
    super.key,
    required this.materi,
  });

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const Color _blue = Color(0xFF1E60BE);
  static const Color _lightBlue = Color(0xFF5EBEF3);
  static const Color _green = Color(0xFF71BF4F);
  static const Color _orange = Color(0xFFFAA63A);
  static const Color _cream = Color(0xFFFFF8EE);

  bool isPlayingAudio = false;

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

  // ============================================================
  // AUDIO
  // ============================================================

  Future<void> putarAudio() async {
    final audio = widget.materi.audio;

    if (audio == null || audio.trim().isEmpty) {
      tampilkanPesan('Audio materi belum tersedia.');
      return;
    }

    try {
      await _audioPlayer.stop();

      if (!mounted) return;

      setState(() {
        isPlayingAudio = true;
      });

      final url = _getAudioUrl(audio);

      debugPrint('Memutar audio materi: $url');

      await _audioPlayer.play(
        UrlSource(
          url,
          mimeType: 'audio/mpeg',
        ),
      );
    } catch (e) {
      debugPrint('ERROR AUDIO: $e');

      if (!mounted) return;

      setState(() {
        isPlayingAudio = false;
      });

      tampilkanPesan(
        'Audio tidak dapat diputar. Periksa URL audio.',
      );
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
    } catch (_) {}
  }

  String _getAudioUrl(String audio) {
    if (audio.startsWith('http://') ||
        audio.startsWith('https://')) {
      return audio;
    }

    return 'http://127.0.0.1:8000/storage/$audio';
  }

  String _getImageUrl(String gambar) {
    if (gambar.startsWith('http://') ||
        gambar.startsWith('https://')) {
      return gambar;
    }

    return 'http://127.0.0.1:8000/storage/$gambar';
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              onPressed: () async {
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
                  'MATERI',
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

  // ============================================================
  // SECTION CARD
  // ============================================================

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

  // ============================================================
  // IDENTITAS MATERI
  // ============================================================

  Widget kartuIdentitasMateri() {
    return _sectionCard(
      borderColor: _blue,
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
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.materi.kodeMateri,
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: _green,
                  size: 25,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: _blue,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'MATERI PEMBELAJARAN',
                style: TextStyle(
                  color: _blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            widget.materi.namaMateri,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GAMBAR MATERI
  // ============================================================

  Widget gambarMateri() {
    final gambar = widget.materi.gambar;

    if (gambar == null || gambar.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final url = _getImageUrl(gambar);

    debugPrint('URL GAMBAR MATERI: $url');

    return _sectionCard(
      borderColor: _orange,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.image_rounded,
                color: Color(0xFFB66B00),
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'GAMBAR MATERI',
                style: TextStyle(
                  color: Color(0xFFB66B00),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 150,
                maxHeight: 350,
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
                    height: 200,
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
                  debugPrint(
                    'ERROR GAMBAR MATERI: $error',
                  );

                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 45,
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
        ],
      ),
    );
  }

  // ============================================================
  // ISI MATERI
  // ============================================================

  Widget isiMateri() {
    return _sectionCard(
      borderColor: _green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: _green,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'ISI MATERI',
                style: TextStyle(
                  color: Color(0xFF438C2D),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            widget.materi.isiMateri,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AUDIO MATERI
  // ============================================================

  Widget audioMateri() {
    final audio = widget.materi.audio;

    if (audio == null || audio.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      borderColor: _lightBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                color: _blue,
                size: 23,
              ),
              SizedBox(width: 8),
              Text(
                'AUDIO MATERI',
                style: TextStyle(
                  color: _blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: putarAudio,

              icon: Icon(
                isPlayingAudio
                    ? Icons.stop_circle_rounded
                    : Icons.play_circle_fill_rounded,
                size: 28,
              ),

              label: Text(
                isPlayingAudio
                    ? 'HENTIKAN AUDIO'
                    : 'DENGARKAN MATERI',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPlayingAudio ? _orange : _blue,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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

  // ============================================================
  // INFORMASI TAMBAHAN
  // ============================================================

  Widget informasiMateri() {
    return _sectionCard(
      borderColor: const Color(0xFFAB70D6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E9FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFAB70D6),
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Text(
              'Pelajari materi dengan baik dan jangan lupa '
              'untuk mencoba latihan setelah selesai belajar!',
              style: TextStyle(
                color: Color(0xFF5F6368),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) async {
        if (!didPop) {
          await hentikanAudio();

          if (mounted) {
            Navigator.maybePop(context);
          }
        }
      },

      child: Scaffold(
        backgroundColor: _cream,

        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/backgroundSplash.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
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
                      builder: (
                        context,
                        constraints,
                      ) {
                        final isLandscape =
                            constraints.maxWidth >
                                constraints.maxHeight;

                        return ListView(
                          physics:
                              const BouncingScrollPhysics(),

                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isLandscape ? 48 : 20,
                            vertical: 20,
                          ),

                          children: [
                            kartuIdentitasMateri(),

                            const SizedBox(height: 18),

                            gambarMateri(),

                            if (widget.materi.gambar !=
                                    null &&
                                widget.materi.gambar!
                                    .trim()
                                    .isNotEmpty)
                              const SizedBox(height: 2),

                            isiMateri(),

                            const SizedBox(height: 16),

                            audioMateri(),

                            const SizedBox(height: 16),

                            informasiMateri(),

                            const SizedBox(height: 25),

                            // TOMBOL KEMBALI
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await hentikanAudio();

                                  if (!mounted) return;

                                  Navigator.maybePop(
                                    context,
                                  );
                                },

                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 22,
                                ),

                                label: const Text(
                                  'KEMBALI KE DAFTAR MATERI',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _lightBlue,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 3,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 15,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            18),
                                    side:
                                        const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        );
                      },
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

// ================================================================
// TOMBOL KEMBALI
// ================================================================

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

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