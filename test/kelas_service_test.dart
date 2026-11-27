import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:projek_buba/services/kelas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'token': 'test-token',
      'user_data': jsonEncode({
        'id': 7,
        'kode_user': 'SISWA-7',
        'name': 'Siswa',
        'email': 'siswa@example.com',
        'password': '',
        'jenis_kelamin': '',
        'role': 'siswa',
        'kelas_id': 0,
        'nama_kelas': '',
      }),
    });
  });

  test('uses the saved class list when the API is offline', () async {
    final service = KelasService(
      client: _TestClient((request) async {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'success': true,
                'kelas': [
                  {'id': 3, 'nama_kelas': 'A'},
                ],
              }),
            ),
          ),
          200,
        );
      }),
    );

    final onlineClasses = await service.getKelasSiswa();
    expect(onlineClasses.map((kelas) => (kelas.id, kelas.namaKelas)).toList(), [
      (3, 'A'),
    ]);

    final offlineService = KelasService(
      client: _TestClient((request) async {
        throw http.ClientException('No connection', request.url);
      }),
    );

    final offlineClasses = await offlineService.getKelasSiswa();
    expect(
      offlineClasses.map((kelas) => (kelas.id, kelas.namaKelas)).toList(),
      [(3, 'A')],
    );
  });

  test('reports connection failure when no class cache exists', () async {
    final service = KelasService(
      client: _TestClient((request) async {
        throw http.ClientException('No connection', request.url);
      }),
    );

    await expectLater(
      service.getKelasSiswa(),
      throwsA(
        isA<KelasServiceException>().having(
          (error) => error.message,
          'message',
          'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan.',
        ),
      ),
    );
  });
}

class _TestClient extends http.BaseClient {
  _TestClient(this._send);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _send;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _send(request);
}
