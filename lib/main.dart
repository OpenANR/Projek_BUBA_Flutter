import 'package:flutter/material.dart';
import 'siswa/materi/materi.dart'; // Menghubungkan file materi.dart

void main() {
  runApp(const BubaApp());
}

class BubaApp extends StatelessWidget {
  const BubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MateriPage(), // Membuka halaman materi
    );
  }
}