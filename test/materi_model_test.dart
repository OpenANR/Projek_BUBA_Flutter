import 'package:flutter_test/flutter_test.dart';
import 'package:projek_buba/models/materi_model.dart';

void main() {
  group('MateriModel Tests', () {
    test('Parse response dari listMateri Laravel', () {
      final json = {
        'id': 1,
        'kode_materi': 'MTR-A1B2',
        'nama_materi': 'Mengenal Huruf A',
        'gambar_url': 'http://127.0.0.1:8000/storage/materi/huruf_a.png',
      };

      final materi = MateriModel.fromJson(
        json,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(materi.id, 1);
      expect(materi.kodeMateri, 'MTR-A1B2');
      expect(materi.namaMateri, 'Mengenal Huruf A');
      expect(materi.isiMateri, '');
      expect(
        materi.gambarUrl,
        'http://192.168.1.14:8000/storage/materi/huruf_a.png',
      );
      expect(materi.audioUrl, isNull);
      expect(materi.kategoriId, isNull);
      expect(materi.kelasId, isNull);
    });

    test('Parse response dari showMateri (detail) Laravel', () {
      final json = {
        'id': 5,
        'kode_materi': 'MTR-X9Y8',
        'nama_materi': 'Huruf Vokal',
        'isi_materi': 'Huruf vokal terdiri dari A, I, U, E, dan O.',
        'gambar_url': 'http://localhost:8000/storage/materi/vokal.png',
        'audio_url': 'http://localhost:8000/storage/audio/vokal.mp3',
      };

      final materi = MateriModel.fromJson(
        json,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(materi.id, 5);
      expect(materi.kodeMateri, 'MTR-X9Y8');
      expect(materi.namaMateri, 'Huruf Vokal');
      expect(
        materi.isiMateri,
        'Huruf vokal terdiri dari A, I, U, E, dan O.',
      );
      expect(
        materi.gambarUrl,
        'http://192.168.1.14:8000/storage/materi/vokal.png',
      );
      expect(
        materi.audioUrl,
        'http://192.168.1.14:8000/storage/audio/vokal.mp3',
      );
    });

    test('Normalize relative storage URL', () {
      final json = {
        'id': 10,
        'kode_materi': 'MTR-001',
        'nama_materi': 'Angka 1',
        'isi_materi': 'Ini angka 1',
        'gambar': 'materi/angka1.png',
        'audio': 'audio/angka1.mp3',
      };

      final materi = MateriModel.fromJson(
        json,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(
        materi.gambarUrl,
        'http://192.168.1.14:8000/storage/materi/angka1.png',
      );
      expect(
        materi.audioUrl,
        'http://192.168.1.14:8000/storage/audio/angka1.mp3',
      );
    });
  });
}
