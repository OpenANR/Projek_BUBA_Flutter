import 'package:flutter/material.dart';

import '../models/kelas_model.dart';
import 'selectClass.dart';
import 'selectCategory.dart';
import 'quis/quisList.dart';

class SelectContent extends StatelessWidget {
  const SelectContent({super.key});

  Future<KelasModel?> _pilihKelas(BuildContext context) {
    return Navigator.push<KelasModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectClass(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildBackButton(context),
                      ),
                      _buildHeaderTitle(),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: isLandscape
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: _buildCards(
                                context,
                                isLandscape: true,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: _buildCards(
                                context,
                                isLandscape: false,
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

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5EBEF3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 36,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E60BE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'PILIH KONTEN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  List<Widget> _buildCards(
    BuildContext context, {
    required bool isLandscape,
  }) {
    final double cardWidth = isLandscape ? 200 : 260;
    final double cardHeight = isLandscape ? 220 : 160;

    return [
      _ContentMenuCard(
        title: 'MATERI',
        color: const Color(0xFF71BF4F),
        assetImage: 'assets/images/ic_materi.png',
        fallbackIcon: Icons.menu_book_rounded,
        width: cardWidth,
        height: cardHeight,
        isLandscape: isLandscape,
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => SelectClass(
                onClassSelected: (kelas) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SelectCategoryPage(
                        className: kelas.namaKelas,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),

      SizedBox(
        width: isLandscape ? 24 : 0,
        height: isLandscape ? 0 : 20,
      ),

      _ContentMenuCard(
        title: 'KUIS',
        color: const Color(0xFF3A84FA),
        assetImage: 'assets/images/ic_kuis.png',
        fallbackIcon: Icons.edit_rounded,
        width: cardWidth,
        height: cardHeight,
        isLandscape: isLandscape,
        onTap: () async {
          final kelas = await _pilihKelas(context);
          if (!context.mounted || kelas == null) return;

          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategoryPage(
                className: kelas.namaKelas,
                onCategorySelected: (kategori) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuisListPage(
                        kelasId: kelas.id,
                        kategoriId: kategori.id,
                        namaKelas: kelas.namaKelas,
                        namaKategori: kategori.namaKategori,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),

      SizedBox(
        width: isLandscape ? 24 : 0,
        height: isLandscape ? 0 : 20,
      ),

      _ContentMenuCard(
        title: 'RIWAYAT',
        color: const Color(0xFFFAA63A),
        assetImage: 'assets/images/ic_riwayat.png',
        fallbackIcon: Icons.emoji_events_rounded,
        width: cardWidth,
        height: cardHeight,
        isLandscape: isLandscape,
        onTap: () {
          _showInfoDialog(
            context,
            title: 'Riwayat Kuis',
            message:
                'Kamu bisa melihat skor dan hasil kuis sebelumnya di sini!',
          );
        },
      ),
    ];
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFF1E60BE),
            width: 3,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E60BE),
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E60BE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'OKE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentMenuCard extends StatefulWidget {
  final String title;
  final Color color;
  final String assetImage;
  final IconData fallbackIcon;
  final double width;
  final double height;
  final bool isLandscape;
  final VoidCallback onTap;

  const _ContentMenuCard({
    required this.title,
    required this.color,
    required this.assetImage,
    required this.fallbackIcon,
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.onTap,
  });

  @override
  State<_ContentMenuCard> createState() => _ContentMenuCardState();
}

class _ContentMenuCardState extends State<_ContentMenuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white,
            width: 4.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            onTapDown: (_) {
              setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
            },
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: widget.isLandscape
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: _buildIcon(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 8),
                        _buildIcon(size: 65),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({double size = 80}) {
    return Image.asset(
      widget.assetImage,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          widget.fallbackIcon,
          size: size * 0.8,
          color: Colors.white,
        );
      },
    );
  }
}
