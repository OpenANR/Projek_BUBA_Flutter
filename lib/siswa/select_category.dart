// ignore_for_file: unused_field

import 'dart:math' as math;

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

  static const _classALessons = [
    _Lesson(title: 'MENGENAL\nHURUF', emoji: '🔠', color: Color(0xFFF00078)),
    _Lesson(title: 'MENGENAL\nANGKA', emoji: '🔢', color: Color(0xFF169B24)),
    _Lesson(title: 'MENGENAL\nWARNA', emoji: '🎨', color: Color(0xFF20399D)),
    _Lesson(title: 'MENGENAL\nBENTUK', emoji: '🔺', color: Color(0xFFFFC400)),
    _Lesson(title: 'MENGENAL\nHEWAN', emoji: '🐕', color: Color(0xFF159C6C)),
    _Lesson(
      title: 'MENGENAL\nANGGOTA TUBUH',
      emoji: '🧑🏽‍🦱',
      color: Color(0xFF7100A5),
    ),
    _Lesson(title: 'KEBERSIHAN\nDIRI', emoji: '🛁', color: Color(0xFFEF6400)),
    _Lesson(title: 'MENGENAL\nTUMBUHAN', emoji: '🪴', color: Color(0xFFC90008)),
  ];

  static const _classBLessons = [
    _Lesson(title: 'MEMBACA', emoji: '🔠', color: Color(0xFFF00078)),
    _Lesson(title: 'BERHITUNG', emoji: '🔢', color: Color(0xFF169B24)),
    _Lesson(title: 'CAMPUR\nWARNA', emoji: '🎨', color: Color(0xFF20399D)),
    _Lesson(title: 'BENTUK & POLA', emoji: '🔺', color: Color(0xFFFFC400)),
    _Lesson(title: 'HABITAT\nHEWAN', emoji: '🐕', color: Color(0xFF159C6C)),
    _Lesson(
      title: 'TUBUH &\nKESEHATAN',
      emoji: '🧑🏽‍🦱',
      color: Color(0xFF7100A5),
    ),
    _Lesson(title: 'KEBERSIHAN\nDIRI', emoji: '🛁', color: Color(0xFFEF6400)),
    _Lesson(title: 'BAGIAN\nTUMBUHAN', emoji: '🪴', color: Color(0xFFC90008)),
  ];

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
    KelasModel? selected;
    for (final kelas in classes) {
      final name = kelas.namaKelas.trim().toLowerCase();
      if (name == requested || name.endsWith(requested)) {
        selected = kelas;
        break;
      }
    }
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: PlaygroundBackgroundPainter()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: const Color(0xFFFFA500),
                      shape: const CircleBorder(
                        side: BorderSide(color: Colors.white, width: 4),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 54,
                          height: 54,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2865CC),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                    child: Text(
                      'MATERI KELAS ${widget.className}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FutureBuilder<List<KategoriModel>>(
                    future: _kategoriFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (snapshot.hasError) {
                        return _CategoryMessage(
                          message: snapshot.error.toString(),
                          onRetry: _reloadKategori,
                        );
                      }

                      final categories = snapshot.data ?? const [];
                      if (categories.isEmpty) {
                        return const _CategoryMessage(
                          message: 'Belum ada kategori untuk kelas ini.',
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 26,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.32,
                            ),
                        itemBuilder: (context, index) {
                          return _LessonCard(
                            lesson: _Lesson.fromCategory(categories[index], index),
                            onTap: () => widget.onCategorySelected?.call(
                              categories[index],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lesson {
  const _Lesson({
    required this.title,
    required this.emoji,
    required this.color,
    this.kategoriId = 0,
  });

  factory _Lesson.fromCategory(KategoriModel kategori, int index) {
    const colors = [
      Color(0xFFF00078),
      Color(0xFF169B24),
      Color(0xFF20399D),
      Color(0xFFFFC400),
      Color(0xFF159C6C),
      Color(0xFF7100A5),
      Color(0xFFEF6400),
      Color(0xFFC90008),
    ];
    const emojis = ['🔤', '🔢', '🎨', '🔷', '🐕', '🧑', '🧼', '🌴'];

    return _Lesson(
      kategoriId: kategori.id,
      title: kategori.namaKategori.toUpperCase(),
      emoji: emojis[index % emojis.length],
      color: colors[index % colors.length],
    );
  }

  final String title;
  final String emoji;
  final Color color;
  final int kategoriId;
}

class _CategoryMessage extends StatelessWidget {
  const _CategoryMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, this.onTap});

  final _Lesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: lesson.color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(lesson.emoji, style: const TextStyle(fontSize: 25)),
          ],
        ),
        ),
      ),
    );
  }
}

class PlaygroundBackgroundPainter extends CustomPainter {
  const PlaygroundBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF07517A), Color(0xFF1685A4), Color(0xFF82D5A5)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.25);
    _drawCloud(canvas, cloud, Offset(-5, size.height * 0.2), 52);
    _drawCloud(canvas, cloud, Offset(size.width + 4, size.height * 0.32), 38);
    _drawCloud(
      canvas,
      cloud,
      Offset(size.width * 0.12, size.height * 0.46),
      28,
    );

    final sunCenter = Offset(size.width * 0.86, size.height * 0.14);
    final sunPaint = Paint()..color = const Color(0xFFFFD12E);
    canvas.drawCircle(sunCenter, 37, sunPaint);
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD12E)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var ray = 0; ray < 8; ray++) {
      final angle = ray * 3.141592653589793 / 4;
      final start =
          sunCenter + Offset(42 * math.cos(angle), 42 * math.sin(angle));
      final end =
          sunCenter + Offset(55 * math.cos(angle), 55 * math.sin(angle));
      canvas.drawLine(start, end, rayPaint);
    }
    final facePaint = Paint()
      ..color = const Color(0xFF704B20)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(sunCenter + const Offset(-12, -5), 2, facePaint);
    canvas.drawCircle(sunCenter + const Offset(12, -5), 2, facePaint);
    canvas.drawArc(
      Rect.fromCenter(
        center: sunCenter + const Offset(0, 5),
        width: 15,
        height: 10,
      ),
      0.2,
      2.7,
      false,
      facePaint,
    );

    final farHill = Paint()..color = const Color(0xFF59B774);
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.24,
        size.height * 0.59,
        size.width,
        size.height * 0.42,
      ),
      farHill,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.62,
        size.width,
        size.height * 0.35,
      ),
      Paint()..color = const Color(0xFF3D9C55),
    );

    final foregroundHill = Paint()..color = const Color(0xFF187542);
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.45,
        size.height * 0.73,
        size.width * 1.1,
        size.height * 0.45,
      ),
      foregroundHill,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.54,
        size.height * 0.74,
        size.width,
        size.height * 0.39,
      ),
      Paint()..color = const Color(0xFF238949),
    );

    final path = Path()
      ..moveTo(size.width * 0.38, size.height)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.88,
        size.width * 0.68,
        size.height * 0.85,
        size.width * 0.59,
        size.height * 0.75,
      )
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.66,
        size.width * 0.73,
        size.height * 0.63,
        size.width * 0.78,
        size.height * 0.58,
      )
      ..lineTo(size.width * 0.88, size.height * 0.58)
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.7,
        size.width * 0.65,
        size.height * 0.72,
        size.width * 0.72,
        size.height * 0.81,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.9,
        size.width * 0.58,
        size.height * 0.92,
        size.width * 0.56,
        size.height,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFC9A85D));

    _drawTree(canvas, Offset(size.width * 0.05, size.height * 0.7), 1);
    _drawTree(canvas, Offset(size.width * 0.91, size.height * 0.77), 0.72);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas
      ..drawCircle(center, radius * 0.65, paint)
      ..drawCircle(
        center + Offset(radius * 0.58, -radius * 0.22),
        radius * 0.83,
        paint,
      )
      ..drawCircle(
        center + Offset(radius * 1.15, radius * 0.03),
        radius * 0.59,
        paint,
      );
  }

  void _drawTree(Canvas canvas, Offset base, double scale) {
    final trunk = Paint()..color = const Color(0xFF704225);
    final leaves = Paint()..color = const Color(0xFF278344);
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 5 * scale, base.dy, 10 * scale, 100 * scale),
      trunk,
    );
    canvas
      ..drawCircle(base + Offset(0, -26 * scale), 34 * scale, leaves)
      ..drawCircle(base + Offset(-20 * scale, -9 * scale), 25 * scale, leaves)
      ..drawCircle(base + Offset(21 * scale, -7 * scale), 24 * scale, leaves);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
