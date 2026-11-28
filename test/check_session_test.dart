import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_buba/pages/checkSession.dart';
import 'package:projek_buba/siswa/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'opens SplashPage from local verification status without network',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'token': 'test-token',
        'email_verified': true,
        'user_data': jsonEncode({
          'id': 7,
          'kode_user': 'SISWA-7',
          'name': 'Siswa Uji',
          'email': 'siswa@example.com',
          'password': '',
          'jenis_kelamin': '',
          'role': 'siswa',
          'kelas_id': 1,
          'nama_kelas': 'A',
        }),
      });

      await tester.pumpWidget(const MaterialApp(home: CheckSession()));
      await tester.pumpAndSettle();

      expect(find.byType(SplashPage), findsOneWidget);
    },
  );
}
