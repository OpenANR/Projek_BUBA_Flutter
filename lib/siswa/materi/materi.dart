import 'package:flutter/material.dart';

import '../../models/materi_model.dart';
import '../../services/audio_player/app_audio_player.dart';
import '../../services/materi_services.dart';

typedef MateriPage = MateriDetailPage;

class MateriDetailPage extends StatefulWidget {
  final String kodeMateri;
  final String namaKelas;
  final String namaKategori;
  final MateriModel? initialMateri;
  final List<MateriModel>? daftarMateri;
  final int? currentIndex;

  const MateriDetailPage({
    super.key,
    required this.kodeMateri,
    this.namaKelas = '',
    this.namaKategori = '',
    this.initialMateri,
    this.daftarMateri,
    this.currentIndex,
  });

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage> {
  final MateriServices _services = MateriServices();
  final AppAudioPlayer _audioPlayer = AppAudioPlayer();

  late String _currentKodeMateri;
  late int _currentIndex;

  MateriModel? _materi;

  bool _loading = true;
  String? _error;
  bool _isPlayingAudio = false;

  static const Color _blue = Color(0xFF1E60BE);
  static const Color _green = Color(0xFF71BF4F);
  static const Color _orange = Color(0xFFFAA63A);

  @override
  void initState() {
    super.initState();

    _currentKodeMateri = widget.kodeMateri;
    _currentIndex = widget.currentIndex ?? 0;
    _materi = widget.initialMateri;

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlayingAudio = false;
      });
    });

    _loadDetail();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    if (_currentKodeMateri.isEmpty) return;

    if (!mounted) return;

    setState(() {
      _loading =
          _materi == null ||
          (_materi?.isiMateri.isEmpty ?? true);

      _error = null;
    });

    try {
      final detail = await _services.getDetailMateri(
        _currentKodeMateri,
      );

      if (!mounted) return;

      setState(() {
        _materi = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Jika data awal dari list masih tersedia,
      // tetap tampilkan data tersebut.
      if (_materi != null &&
          _materi!.namaMateri.isNotEmpty) {
        setState(() {
          _loading = false;
        });
      } else {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleAudio() async {
    final audioUrl = _materi?.audioUrl;

    if (audioUrl == null || audioUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Audio untuk materi ini belum tersedia.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      if (_isPlayingAudio) {
        await _audioPlayer.pause();

        if (!mounted) return;

        setState(() {
          _isPlayingAudio = false;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(
          UrlSource(audioUrl),
        );

        if (!mounted) return;

        setState(() {
          _isPlayingAudio = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPlayingAudio = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat memutar audio: $e',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _pindahMateri(int newIndex) {
    if (widget.daftarMateri == null ||
        newIndex < 0 ||
        newIndex >= widget.daftarMateri!.length) {
      return;
    }

    _audioPlayer.stop();

    final targetMateri =
        widget.daftarMateri![newIndex];

    setState(() {
      _currentIndex = newIndex;
      _currentKodeMateri =
          targetMateri.kodeMateri;
      _materi = targetMateri;
      _isPlayingAudio = false;
    });

    _loadDetail();
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.maybePop(context);
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 56),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius:
                    BorderRadius.circular(30),
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
                  'DETAIL MATERI',
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
    final screenWidth =
        MediaQuery.sizeOf(context).width;

    final horizontalPadding =
        screenWidth >= 700 ? 28.0 : 16.0;

    return PopScope(
      onPopInvokedWithResult:
          (didPop, result) {
        _audioPlayer.stop();
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFFFFF8EE),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/backgroundSplash.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder:
                  (context, error, stackTrace) {
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
                    child: _loading
                        ? _buildLoading()
                        : _error != null &&
                                _materi == null
                            ? _buildError()
                            : _buildContent(
                                horizontalPadding,
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

  Widget _buildContent(
    double horizontalPadding,
  ) {
    final materi = _materi!;

    final daftar = widget.daftarMateri;

    final hasList =
        daftar != null && daftar.isNotEmpty;

    final hasPrev =
        hasList && _currentIndex > 0;

    final hasNext =
        hasList &&
        _currentIndex < daftar.length - 1;

    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        8,
        horizontalPadding,
        30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 850,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildTitleCard(materi),

              const SizedBox(height: 16),

              if (materi.audioUrl != null &&
                  materi.audioUrl!.isNotEmpty) ...[
                _buildAudioPlayerCard(),
                const SizedBox(height: 16),
              ],

              // Gambar Materi jika tersedia
              if (materi.gambarUrls.isNotEmpty) ...[
                ...materi.gambarUrls.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildImageCard(url),
                  ),
                ),
              ] else if (materi.gambarUrl != null &&
                  materi.gambarUrl!.isNotEmpty) ...[
                _buildImageCard(
                  materi.gambarUrl!,
                ),
                const SizedBox(height: 16),
              ],

              _buildTextCard(materi),

              const SizedBox(height: 24),

              if (hasList)
                _buildNavigationButtons(
                  hasPrev: hasPrev,
                  hasNext: hasNext,
                )
              else
                _buildBackButtonBottom(),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'BUBA • Belajar itu Menyenangkan! 🌟',
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
    );
  }

  Widget _buildTitleCard(
    MateriModel materi,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _green,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  materi.kodeMateri.isNotEmpty
                      ? materi.kodeMateri
                      : 'MATERI',
                  style: const TextStyle(
                    color: _green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              const Spacer(),

              if (widget.namaKelas.isNotEmpty ||
                  widget.namaKategori.isNotEmpty)
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _blue.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Text(
                      [
                        if (widget.namaKelas
                            .isNotEmpty)
                          widget.namaKelas,
                        if (widget.namaKategori
                            .isNotEmpty)
                          widget.namaKategori,
                      ].join(' • '),
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: _blue,
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            materi.namaMateri,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E3A2F),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _isPlayingAudio
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFEFF6FF),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: _isPlayingAudio
              ? _green
              : _blue,
          width: 2.5,
        ),
      ),
      child: Row(
        children: [
          Material(
            color: _isPlayingAudio
                ? _green
                : _blue,
            shape:
                const CircleBorder(),
            elevation: 3,
            child: InkWell(
              customBorder:
                  const CircleBorder(),
              onTap: _toggleAudio,
              child: const Padding(
                padding:
                    EdgeInsets.all(12),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _isPlayingAudio
                      ? 'Sedang Memutar Audio 🎶'
                      : 'Dengarkan Penjelasan 🔊',
                  style: TextStyle(
                    color: _isPlayingAudio
                        ? const Color(
                            0xFF1B5E20,
                          )
                        : const Color(
                            0xFF0D47A1,
                          ),
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _isPlayingAudio
                      ? 'Ketuk tombol untuk menjeda suara narasi'
                      : 'Ketuk tombol untuk mendengarkan materi',
                  style:
                      const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.15,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 220,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
                color: _green,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              color:
                  Colors.grey.shade100,
              alignment:
                  Alignment.center,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .image_not_supported_rounded,
                    size: 48,
                    color:
                        Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gambar tidak dapat dimuat',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextCard(
    MateriModel materi,
  ) {
    final isi =
        materi.isiMateri.trim();

    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              const Color(0xFFF0E5D8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📖',
                style:
                    TextStyle(fontSize: 22),
              ),
              SizedBox(width: 8),
              Text(
                'Isi Pembelajaran',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1E3A2F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            color:
                Color(0xFFEEEEEE),
            thickness: 1,
          ),

          const SizedBox(height: 14),

          Text(
            isi.isNotEmpty
                ? isi
                : 'Materi pembelajaran akan ditampilkan di sini.',
            style: const TextStyle(
              fontSize: 17,
              height: 1.7,
              color:
                  Color(0xFF333333),
              fontWeight:
                  FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({
    required bool hasPrev,
    required bool hasNext,
  }) {
    return Row(
      children: [
        Expanded(
          child: hasPrev
              ? ElevatedButton.icon(
                  onPressed: () =>
                      _pindahMateri(
                    _currentIndex - 1,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                  label: const Text(
                    'Sebelumnya',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        _blue,
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
                        16,
                      ),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.maybePop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.list_alt_rounded,
                  ),
                  label: const Text(
                    'Daftar Materi',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor:
                        _blue,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    side:
                        const BorderSide(
                      color: _blue,
                      width: 2,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                  ),
                ),
        ),

        if (hasNext || hasPrev)
          const SizedBox(width: 14),

        if (hasNext)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _pindahMateri(
                _currentIndex + 1,
              ),
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
              label: const Text(
                'Selanjutnya',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _green,
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
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          )
        else if (hasPrev)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.maybePop(
                  context,
                );
              },
              icon: const Icon(
                Icons.check_circle_rounded,
              ),
              label: const Text(
                'Selesai',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _orange,
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
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackButtonBottom() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _audioPlayer.stop();
          Navigator.maybePop(
            context,
          );
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
        label: const Text(
          'Kembali ke Daftar Materi',
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              _blue,
          foregroundColor:
              Colors.white,
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _green,
          ),
          SizedBox(height: 16),
          Text(
            'Sedang menyiapkan materi...',
            style: TextStyle(
              color: _blue,
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        margin:
            const EdgeInsets.all(24),
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            24,
          ),
          border: Border.all(
            color: Colors.redAccent,
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 55,
            ),

            const SizedBox(height: 12),

            const Text(
              'Gagal Membuka Materi',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ??
                  'Terjadi kesalahan.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed:
                  _loadDetail,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text('COBA LAGI'),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _blue,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
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
        customBorder:
            const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding:
              EdgeInsets.all(9),
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