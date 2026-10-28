import 'package:flutter/material.dart';

import 'auth/auth_page.dart';
import 'siswa/quis/quis.dart';

// import 'siswa/splash.dart';
// import 'siswa/selectContent.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AuthPage());
  }
}
