import 'package:flutter/material.dart';

import '../models/kategori_model.dart';
import '../models/kelas_model.dart';
import '../services/kategori_service.dart';
import '../services/kelas_service.dart';

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({
    super.key,
    required this.className,
    this.onCategorySelected,
  });

  final String className;
  final ValueChanged<KategoriModel>? onCategorySelected;

  @override
  State<SelectCategoryPage> createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  final KategoriService _kategoriService = KategoriService();
  final KelasService _kelasService = KelasService();
  late Future<List<KategoriModel>> _kategoriFuture;

  @override
  void initState() {
    super.initState();
    _kategoriFuture = _loadKategori();
  }

  Future<List<KategoriModel>> _loadKategori() async {
    final classes = await _kelasService.getKelasSiswa();
    final requested = widget.className.trim().toLowerCase();

    if (requested.isEmpty) {
      throw const KategoriServiceException('Nama kelas tidak valid.');
    }

    KelasModel? exactMatch;
    KelasModel? partialMatch;
    for (final kelas in classes) {
      final name = kelas.namaKelas.trim().toLowerCase();
      if (name == requested) {
        exactMatch = kelas;
        break;
      }
      if (partialMatch == null && name.endsWith(requested)) {
        partialMatch = kelas;
      }
    }

    final selected = exactMatch ?? partialMatch;
    if (selected == null) {
      throw KategoriServiceException(
        'Kelas ${widget.className} tidak ditemukan dari API.',
      );
    }

    return _kategoriService.getKategori(kelasId: selected.id);
  }

  void _reloadKategori() {
    setState(() {
      _kategoriFuture = _loadKategori();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
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
              return const ColoredBox(color: Color(0xFF5CB8E4));
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                Expanded(
                  child: FutureBuilder<List<KategoriModel>>(
                    future: _kategoriFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1E60BE),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _MessageState(
                          icon: Icons.cloud_off_outlined,
                          message: snapshot.error.toString(),
                          actionLabel: 'COBA LAGI',
                          onAction: _reloadKategori,
                        );
                      }

                      final categories =
                          snapshot.data ?? const <KategoriModel>[];
                      if (categories.isEmpty) {
                        return const _MessageState(
                          icon: Icons.category_outlined,
                          message: 'Belum ada kategori untuk kelas ini.',
                        );
                      }

                      return _buildCategoryGrid(categories, isLandscape);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(onPressed: () => Navigator.maybePop(context)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'MATERI KELAS ${widget.className}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<KategoriModel> categories, bool isLandscape) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = isLandscape ? 3 : 2;
            const spacing = 20.0;
            final cardWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            final cardHeight = (cardWidth * 0.92)
                .clamp(150.0, 210.0)
                .toDouble();

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final kategori in categories)
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _CategoryCard(
                      kategori: kategori,
                      onTap: () => widget.onCategorySelected?.call(kategori),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryVisual {
  const _CategoryVisual(this.emoji, this.color);

  final String emoji;
  final Color color;
}

/// Warna dan ikon ditentukan dari nama kategori agar setiap kategori
/// mendapat tampilan yang konsisten, bukan berdasarkan urutan index.
_CategoryVisual _visualForCategory(String namaKategori) {
  final name = namaKategori.toLowerCase();

  if (name.contains('huruf') || name.contains('membaca')) {
    return const _CategoryVisual('🔤', Color(0xFF3A84FA));
  }
  if (name.contains('angka') || name.contains('berhitung')) {
    return const _CategoryVisual('🔢', Color(0xFF71BF4F));
  }
  if (name.contains('warna')) {
    return const _CategoryVisual('🎨', Color(0xFFFAA63A));
  }
  if (name.contains('bentuk') || name.contains('pola')) {
    return const _CategoryVisual('🔷', Color(0xFF1E60BE));
  }
  if (name.contains('hewan') || name.contains('habitat')) {
    return const _CategoryVisual('🐕', Color(0xFF71BF4F));
  }
  if (name.contains('tubuh') || name.contains('kesehatan')) {
    return const _CategoryVisual('🧑', Color(0xFF3A84FA));
  }
  if (name.contains('bersih') || name.contains('kebersihan')) {
    return const _CategoryVisual('🧼', Color(0xFFFAA63A));
  }
  if (name.contains('tumbuhan') || name.contains('tanaman')) {
    return const _CategoryVisual('🪴', Color(0xFF71BF4F));
  }
  return const _CategoryVisual('⭐', Color(0xFF1E60BE));
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF5EBEF3),
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 3),
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

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.kategori, required this.onTap});

  final KategoriModel kategori;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final visual = _visualForCategory(widget.kategori.namaKategori);

    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: visual.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 4.5),
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
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      visual.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.kategori.namaKategori.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF1E60BE)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E60BE),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
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
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
