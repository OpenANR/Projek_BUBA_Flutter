import 'package:flutter/material.dart';

import '../auth/auth_page.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import 'selectContent.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  // Dialog Tentang BUBA (sesuai tampilan web)
  void _showAboutDialog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 32 : 16,
            vertical: 20,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: screenSize.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Konten Dialog
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge Header "TENTANG BUBA"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E60BE),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.info_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'TENTANG BUBA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Pill Slogan
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            '🌈  Belajar • Bermain • Berkembang  ⭐',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kotak Sambutan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFBAE6FD),
                              width: 1.2,
                            ),
                          ),
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Halo Teman Belajar! 👋 Selamat datang di ',
                                ),
                                const TextSpan(
                                  text: 'BUBA!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E60BE),
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' Media pembelajaran interaktif yang dirancang khusus untuk anak-anak dengan nuansa ceria, visual menyenangkan, dan penuh semangat!',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4 Fitur Unggulan (Grid 2x2 atau Wrap Responsif)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 480;

                            final card1 = _buildFeatureCard(
                              iconEmoji: '📚',
                              title: 'Materi Menyenangkan',
                              description:
                                  'Belajar membaca, berhitung, mengenal hewan, sains, dan dunia sekitar melalui gambar penuh warna!',
                              titleColor: const Color(0xFF15803D),
                              borderColor: const Color(0xFF86EFAC),
                              bgColor: const Color(0xFFF0FDF4),
                              iconBgColor: const Color(0xFFDCFCE7),
                            );

                            final card2 = _buildFeatureCard(
                              iconEmoji: '🎮',
                              title: 'Kuis & Bintang Prestasi',
                              description:
                                  'Bermain kuis seru berhadiah bintang untuk mengasah pemahaman dengan penuh rasa percaya diri!',
                              titleColor: const Color(0xFFC2410C),
                              borderColor: const Color(0xFFFDBA74),
                              bgColor: const Color(0xFFFFF7ED),
                              iconBgColor: const Color(0xFFFFEDD5),
                            );

                            final card3 = _buildFeatureCard(
                              iconEmoji: '🏫',
                              title: 'Tingkatan Belajar',
                              description:
                                  'Materi dan kuis disesuaikan berdasarkan kelas dan tahapan tumbuh kembang ananda.',
                              titleColor: const Color(0xFFBE123C),
                              borderColor: const Color(0xFFFCA5A5),
                              bgColor: const Color(0xFFFFF1F2),
                              iconBgColor: const Color(0xFFFFE4E6),
                            );

                            final card4 = _buildFeatureCard(
                              iconEmoji: '🚀',
                              title: 'Langkah Kecil, Impian Besar',
                              description:
                                  'Setiap langkah belajar hari ini adalah jembatan menuju mimpi besar di masa depan!',
                              titleColor: const Color(0xFF0369A1),
                              borderColor: const Color(0xFF7DD3FC),
                              bgColor: const Color(0xFFF0F9FF),
                              iconBgColor: const Color(0xFFE0F2FE),
                            );

                            if (isWide) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: card1),
                                      const SizedBox(width: 10),
                                      Expanded(child: card2),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: card3),
                                      const SizedBox(width: 10),
                                      Expanded(child: card4),
                                    ],
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                card1,
                                const SizedBox(height: 10),
                                card2,
                                const SizedBox(height: 10),
                                card3,
                                const SizedBox(height: 10),
                                card4,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Kotak Langkah Mudah Memulai
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('💡 ', style: TextStyle(fontSize: 14)),
                                  Text(
                                    'LANGKAH MUDAH MEMULAI:',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF334155),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildStepRow(
                                number: '1',
                                numberColor: const Color(0xFF38BDF8),
                                text: const TextSpan(
                                  children: [
                                    TextSpan(text: 'Klik tombol besar '),
                                    TextSpan(
                                      text: '"MULAI"',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E60BE),
                                      ),
                                    ),
                                    TextSpan(text: ' di halaman utama.'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStepRow(
                                number: '2',
                                numberColor: const Color(0xFF4ADE80),
                                text: const TextSpan(
                                  children: [
                                    TextSpan(text: 'Pilih menu '),
                                    TextSpan(
                                      text: 'Materi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                    TextSpan(text: ' untuk belajar atau '),
                                    TextSpan(
                                      text: 'Kuis',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' untuk bermain tantangan.',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildStepRow(
                                number: '3',
                                numberColor: const Color(0xFFF472B6),
                                text: const TextSpan(
                                  children: [
                                    TextSpan(text: 'Pilih '),
                                    TextSpan(
                                      text: 'Kelas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' dan kategori favoritmu, lalu nikmati petualangan belajarmu!',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Footer Copyright
                        const Text(
                          'BUBA E-Learning Application',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),

                        Text(
                         '© ${DateTime.now().year} NAJATIF. All rights reserved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tombol Aksi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5EBEF3),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SelectContent(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ayo Mulai Belajar! 🚀',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE2E8F0),
                                foregroundColor: const Color(0xFF475569),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Tutup',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tombol Close (X) di Pojok Kanan Atas
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF5350),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Kartu Fitur di Dialog Tentang
  Widget _buildFeatureCard({
    required String iconEmoji,
    required String title,
    required String description,
    required Color titleColor,
    required Color borderColor,
    required Color bgColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(iconEmoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Baris Langkah pada Dialog Tentang
  Widget _buildStepRow({
    required String number,
    required Color numberColor,
    required TextSpan text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: numberColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF334155),
                height: 1.35,
              ),
              children: text.children,
            ),
          ),
        ),
      ],
    );
  }

  // Dialog Profil Siswa (sesuai tampilan web)
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: FutureBuilder<UserModel?>(
                    future: AuthServices.getUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1E60BE),
                            ),
                          ),
                        );
                      }

                      final user = snapshot.data;
                      final namaLengkap =
                          (user?.name != null && user!.name.trim().isNotEmpty)
                              ? user.name
                              : 'Juve Loiso Novelino';
                      final kelasRaw = user?.nama_kelas;
                      final kelasSiswa = (kelasRaw != null &&
                              kelasRaw.isNotEmpty &&
                              kelasRaw != 'Belum Diatur')
                          ? kelasRaw
                          : 'A';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge Header "PROFIL SISWA"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E60BE),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'PROFIL SISWA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Avatar Siswa dengan Badge Bintang
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE0F2FE),
                                      Color(0xFFBAE6FD),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF7DD3FC),
                                    width: 3.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.account_circle_rounded,
                                    size: 68,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Label Nama Lengkap
                          const Text(
                            'NAMA LENGKAP',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Pill Nama Lengkap
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '👨‍🎓 ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Flexible(
                                  child: Text(
                                    namaLengkap,
                                    style: const TextStyle(
                                      color: Color(0xFF1E60BE),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Label Kelas
                          const Text(
                            'KELAS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Pill Kelas
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFECDD3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏫 ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  kelasSiswa,
                                  style: const TextStyle(
                                    color: Color(0xFFE11D48),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Tutup & Logout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5EBEF3),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Tutup',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await AuthServices.logout();

                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const AuthPage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Tombol Close (X) di Pojok Kanan Atas
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF5350),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tombol Bulat Header (Konsisten dengan tombol kembali di selectContent.dart)
  Widget _buildCircleHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
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
          // 1. Gambar Background Sesuai Web (assets/images/backgroundSplash.png)
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

          // 2. Konten Utama
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Tombol Info di kiri & Tombol Profil di kanan
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Info (Kiri)
                      _buildCircleHeaderButton(
                        context,
                        icon: Icons.info_outline_rounded,
                        showBadge: true,
                        onTap: () => _showAboutDialog(context),
                      ),

                      // Tombol Profil Siswa (Kanan)
                      _buildCircleHeaderButton(
                        context,
                        icon: Icons.person_outline_rounded,
                        showBadge: false,
                        onTap: () => _showProfileDialog(context),
                      ),
                    ],
                  ),
                ),

                // Area Tengah: Logo BUBA & Tombol MULAI
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo BUBA
                            Image.asset(
                              'assets/images/logoBuba.png',
                              width: isLandscape
                                  ? (screenSize.width * 0.36).clamp(240.0, 420.0)
                                  : (screenSize.width * 0.75).clamp(220.0, 360.0),
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 28),

                            // Tombol MULAI interaktif dengan animasi bounce
                            _StartPlayButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SelectContent(),
                                  ),
                                );
                              },
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
        ],
      ),
    );
  }
}

// Widget Tombol "MULAI" dengan Efek Animasi Bounce
class _StartPlayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _StartPlayButton({required this.onTap});

  @override
  State<_StartPlayButton> createState() => _StartPlayButtonState();
}

class _StartPlayButtonState extends State<_StartPlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5EBEF3),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 4.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(36),
            splashColor: Colors.white.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 44, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MULAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
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
