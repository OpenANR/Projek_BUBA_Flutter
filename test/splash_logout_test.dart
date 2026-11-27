import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_buba/auth/auth_page.dart';
import 'package:projek_buba/siswa/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
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
      'riwayat_kuis_7': jsonEncode([]),
    });
  });

  testWidgets('tapping Logout once navigates directly to AuthPage and clears session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));
    await tester.pumpAndSettle();

    // Open profile dialog.
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('PROFIL SISWA'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Tap Logout once.
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(prefs.getString('user_data'), isNull);
    expect(prefs.getString('riwayat_kuis_7'), isNull);
  });
}
