import 'package:flutter/material.dart';
import 'auth/auth_page.dart';

void main() {
  runApp(const BubaApp());
}

class BubaApp extends StatelessWidget {
  const BubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AuthPage());
  }
}