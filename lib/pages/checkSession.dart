import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    _CheckLoginStatus();
  }

  Future<void> _CheckLoginStatus() async {
    final token = await AuthServices.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final isVerified = await AuthServices.checkVerificationStatus();
      final user = await AuthServices.getUser();

      if (!mounted) return;

      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashPage()),
        );
      } else if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(email: user.email),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
