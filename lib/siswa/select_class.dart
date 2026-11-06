import 'package:flutter/material.dart';
import 'package:buba_projek/siswa/select_category.dart';

class SelectClassPage extends StatelessWidget {
  const SelectClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: PlaygroundBackgroundPainter()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardHeight = (constraints.maxWidth * 0.27)
                    .clamp(64.0, 140.0)
                    .toDouble();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _BackButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                              const Expanded(
                                child: Center(
                                  child: _TitlePill(label: 'PILIH KELAS'),
                                ),
                              ),
                              const SizedBox(width: 54),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _ClassCard(
                                label: 'A',
                                onTap: () => _openClass(context, 'A'),
                                height: cardHeight,
                              ),
                              const SizedBox(width: 12),
                              _ClassCard(
                                label: 'B',
                                onTap: () => _openClass(context, 'B'),
                                height: cardHeight,
                              ),
                            ],
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openClass(BuildContext context, String className) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SelectCategoryPage(className: className),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFA500),
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 3),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2865CC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.label,
    required this.onTap,
    required this.height,
  });

  final String label;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: const Color(0xFF344FAD),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
