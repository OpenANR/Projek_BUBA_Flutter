import 'package:flutter/material.dart';
import 'package:projek_buba/auth/auth_page.dart';
import 'package:projek_buba/auth/email_verification_page.dart';
import 'package:projek_buba/services/auth_services.dart';
import 'package:projek_buba/siswa/splash.dart';

class CheckSession extends StatefulWidget {
  const CheckSession({super.key});

  @override
  State<CheckSession> createState() => _CheckSessionState();
}

class _CheckSessionState extends State<CheckSession> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthServices.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _goToAuth();
      return;
    }

    // Gunakan status verifikasi yang tersimpan agar aplikasi bisa dibuka
    // tanpa internet. Pemeriksaan ke server hanya dilakukan jika status
    // lokal belum diketahui atau masih belum terverifikasi.
    final localStatus = await AuthServices.getLocalVerificationStatus();

    if (!mounted) return;

    if (localStatus == true) {
      _goToSplash();
      return;
    }

    final remoteStatus = await AuthServices.checkVerificationStatus();

    if (!mounted) return;

    if (remoteStatus == true) {
      _goToSplash();
      return;
    }

    final user = await AuthServices.getUser();

    if (!mounted) return;

    if (remoteStatus == false) {
      // Email belum diverifikasi, atau sesi sudah tidak valid.
      if (user != null) {
        _goToVerification(user.email);
      } else {
        _goToAuth();
      }
      return;
    }

    // remoteStatus == null berarti server tidak dapat dihubungi (offline).
    if (localStatus == false && user != null) {
      _goToVerification(user.email);
    } else if (user != null) {
      _goToSplash();
    } else {
      _goToAuth();
    }
  }

  void _goToSplash() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashPage()),
    );
  }

  void _goToVerification(String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmailVerificationPage(email: email),
      ),
    );
  }

  void _goToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
