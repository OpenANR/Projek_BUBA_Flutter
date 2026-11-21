import 'package:flutter_test/flutter_test.dart';
import 'package:projek_buba/models/kuis_model.dart';
import 'package:projek_buba/models/materi_model.dart';

void main() {
  group('KuisModel Tests', () {
    test('Parse audio and images with JSON array in KuisModel', () {
      final map = {
        'id': 1,
        'kode_kuis': 'KUIS-001',
        'pertanyaan': 'Apa hewan ini?',
        'gambar': '["kuis/hewan1.png", "kuis/hewan2.png"]',
        'audio_pertanyaan': '["kuis/audio/tanya1.mp3"]',
        'pilihan_a': 'Kucing',
        'pilihan_b': 'Anjing',
        'pilihan_c': 'Kelinci',
        'pilihan_d': 'Burung',
        'audio_pilihan_a': 'kuis/audio/a.mp3',
      };

      final kuis = KuisModel.fromMap(
        map,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(kuis.gambarUrls.length, 2);
      expect(
        kuis.gambarUrls[0],
        'http://192.168.1.14:8000/storage/kuis/hewan1.png',
      );
      expect(
        kuis.gambarUrls[1],
        'http://192.168.1.14:8000/storage/kuis/hewan2.png',
      );
      expect(
        kuis.audioPertanyaanUrl,
        'http://192.168.1.14:8000/storage/kuis/audio/tanya1.mp3',
      );
      expect(
        kuis.audioPilihanAUrl,
        'http://192.168.1.14:8000/storage/kuis/audio/a.mp3',
      );
    });
  });
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

    test('Normalize JSON array format for image and audio', () {
      final json = {
        'id': 11,
        'kode_materi': 'MTR-L9MR',
        'nama_materi': 'Test',
        'isi_materi': 'Isi materi',
        'gambar': '["materi/test.png"]',
        'audio': '["audio/test.mp3"]',
      };

      final materi = MateriModel.fromJson(
        json,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(
        materi.gambarUrl,
        'http://192.168.1.14:8000/storage/materi/test.png',
      );
      expect(
        materi.audioUrl,
        'http://192.168.1.14:8000/storage/audio/test.mp3',
      );
    });

    test('Normalize List format for image and audio', () {
      final json = {
        'id': 12,
        'kode_materi': 'MTR-L9MR2',
        'nama_materi': 'Test List',
        'gambar': ['materi/test1.png', 'materi/test2.png'],
        'audio': ['audio/penjelasan.mp3'],
      };

      final materi = MateriModel.fromJson(
        json,
        baseUrl: 'http://192.168.1.14:8000/api',
      );

      expect(materi.gambarUrls.length, 2);
      expect(
        materi.gambarUrl,
        'http://192.168.1.14:8000/storage/materi/test1.png',
      );
      expect(
        materi.audioUrl,
        'http://192.168.1.14:8000/storage/audio/penjelasan.mp3',
      );
    });
  });
}
