import 'package:flutter/material.dart';

import '../models/kelas_model.dart';
import '../services/kelas_service.dart';

class SelectClass extends StatefulWidget {
  const SelectClass({super.key, this.onClassSelected});

  final ValueChanged<KelasModel>? onClassSelected;

  @override
  State<SelectClass> createState() => _SelectClassState();
}

class _SelectClassState extends State<SelectClass> {
  final KelasService _kelasService = KelasService();
  late Future<List<KelasModel>> _kelasFuture;
  KelasModel? _selectedClass;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() {
    _selectedClass = null;
    _kelasFuture = _kelasService.getKelasSiswa();
  }

  void _retry() {
    setState(_loadClasses);
  }

  void _selectClass(KelasModel kelas) {
    setState(() => _selectedClass = kelas);

    final onClassSelected = widget.onClassSelected;
    if (onClassSelected != null) {
      onClassSelected(kelas);
    } else {
      Navigator.pop<KelasModel>(context, kelas);
    }
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
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(color: Color(0xFF5CB8E4));
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
                        child: _BackButton(
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ),
                      Container(
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
                          'PILIH KELAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<KelasModel>>(
                    future: _kelasFuture,
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
                          onAction: _retry,
                        );
                      }

                      final kelasList = snapshot.data ?? const <KelasModel>[];
                      if (kelasList.isEmpty) {
                        return const _MessageState(
                          icon: Icons.school_outlined,
                          message: 'Akun ini belum terdaftar pada kelas.',
                        );
                      }

                      final cardWidth = isLandscape ? 200.0 : 260.0;
                      final cardHeight = isLandscape ? 220.0 : 160.0;

                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: isLandscape
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (
                                      var index = 0;
                                      index < kelasList.length;
                                      index++
                                    ) ...[
                                      if (index > 0) const SizedBox(width: 24),
                                      _ClassCard(
                                        kelas: kelasList[index],
                                        selected:
                                            _selectedClass?.id ==
                                            kelasList[index].id,
                                        width: cardWidth,
                                        height: cardHeight,
                                        isLandscape: true,
                                        onTap: () =>
                                            _selectClass(kelasList[index]),
                                      ),
                                    ],
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (
                                      var index = 0;
                                      index < kelasList.length;
                                      index++
                                    ) ...[
                                      if (index > 0) const SizedBox(height: 20),
                                      _ClassCard(
                                        kelas: kelasList[index],
                                        selected:
                                            _selectedClass?.id ==
                                            kelasList[index].id,
                                        width: cardWidth,
                                        height: cardHeight,
                                        isLandscape: false,
                                        onTap: () =>
                                            _selectClass(kelasList[index]),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      );
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

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.kelas,
    required this.selected,
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.onTap,
  });

  final KelasModel kelas;
  final bool selected;
  final double width;
  final double height;
  final bool isLandscape;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ClassCardInteraction(
      width: width,
      height: height,
      isLandscape: isLandscape,
      kelas: kelas,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _ClassCardInteraction extends StatefulWidget {
  const _ClassCardInteraction({
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.kelas,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool isLandscape;
  final KelasModel kelas;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ClassCardInteraction> createState() => _ClassCardInteractionState();
}

class _ClassCardInteractionState extends State<_ClassCardInteraction> {
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
          color: widget.selected
              ? const Color(0xFF4A9A35)
              : const Color(0xFF71BF4F),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.selected ? const Color(0xFF1E60BE) : Colors.white,
            width: widget.selected ? 5 : 4.5,
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
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: widget.isLandscape
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Center(
                            child: Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'KELAS ${widget.kelas.namaKelas}'.toUpperCase(),
                          textAlign: TextAlign.center,
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
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 65,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'KELAS ${widget.kelas.namaKelas}'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Icon(
                          widget.selected
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_ios_rounded,
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
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
