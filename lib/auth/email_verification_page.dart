import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_services.dart';
import '../siswa/splash.dart';
import 'auth_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _timer;
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto polling setiap 3 detik untuk mengecek status verifikasi di background
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkStatus(isAuto: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _checkStatus({bool isAuto = false}) async {
    if (!mounted || _isChecking) return;

    if (!isAuto) {
      setState(() => _isChecking = true);
    }

    final isVerified = await AuthServices.checkVerificationStatus();

    if (!mounted) return;

    if (!isAuto) {
      setState(() => _isChecking = false);
    }

    if (isVerified) {
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Email berhasil diverifikasi 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashPage()),
      );
    } else if (!isAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email belum diverifikasi. Silakan klik tombol konfirmasi di email/Mailtrap Anda terlebih dahulu.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    final message = await AuthServices.resendVerificationEmail();

    if (!mounted) return;
    setState(() => _isResending = false);

    _startCooldown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Email verifikasi berhasil dikirim ulang.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _handleLogout() async {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    await AuthServices.logout();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'BUBA | Verifikasi Akun',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'by : Najatif_2026',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logoBuba.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon Email Unread
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 2.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 48,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Periksa Email Anda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),

                // Card info email
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Pesan konfirmasi sedang dikirimkan ke:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Silakan buka Mailtrap atau kotak masuk email Anda, lalu klik tautan verifikasi. Setelah itu, aplikasi akan otomatis melanjutkan ke halaman siswa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Indikator auto-check
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Menunggu konfirmasi email secara otomatis...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Cek Manual
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : () => _checkStatus(isAuto: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'SAYA SUDAH VERIFIKASI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Kirim Ulang
                TextButton(
                  onPressed: (_resendCooldown > 0 || _isResending) ? null : _handleResend,
                  child: _isResending
                      ? const Text('Mengirim ulang...')
                      : Text(
                          _resendCooldown > 0
                              ? 'Kirim ulang email dalam ($_resendCooldown s)'
                              : 'Belum menerima email? Kirim Ulang',
                          style: TextStyle(
                            color: _resendCooldown > 0 ? Colors.grey : Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 10),

                // Tombol Logout / Kembali
                OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.grey),
                  label: const Text(
                    'Kembali ke Halaman Login',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
