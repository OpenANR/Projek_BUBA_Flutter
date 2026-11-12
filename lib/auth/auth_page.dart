import 'package:flutter/material.dart';

import '../services/auth_services.dart';
import '../siswa/splash.dart';
import 'email_verification_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordObsecured = true;
  bool _isLoading = false;
  final AuthServices _authServices = AuthServices();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authServices.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (result.isEmailVerified) {
        // Jika email sudah terverifikasi, langsung ke halaman Siswa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashPage()),
        );
      } else {
        // Jika belum terverifikasi, arahkan ke Halaman Verifikasi Email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationPage(email: _emailController.text.trim()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Login gagal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Welcome to BUBA'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              SizedBox(height: 20),

              Center(child: Image.asset('assets/images/logoBuba.png')),

              SizedBox(height: 10),

              Text(
                'Masuk ke akun',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silahkan login sebelum melanjutkan',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'juvePCX@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong !';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordObsecured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '*****',
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObsecured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObsecured = !_isPasswordObsecured;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password wajib diisi !';
                  }
                  if (value.length < 8) {
                    return 'Password minimal 8 karakter!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'BUBA E-Learning Application',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Center(
                child: Text(
                  '© ${DateTime.now().year} NAJATIF. All rights reserved.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
