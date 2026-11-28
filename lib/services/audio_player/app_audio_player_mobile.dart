import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'app_audio_player.dart';

AppAudioPlayer createAudioPlayer() => MobileAudioPlayer();

class MobileAudioPlayer implements AppAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  MobileAudioPlayer() {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  @override
  Future<void> play(String url) async {
    await _player.stop();
    _isPlaying = true;
    try {
      // Media hasil cache offline berupa path file lokal, bukan URL.
      final source = _isLocalPath(url)
          ? DeviceFileSource(_localFilePath(url))
          : UrlSource(url);
      await _player.play(source);
    } catch (_) {
      _isPlaying = false;
      rethrow;
    }
  }

  bool _isLocalPath(String value) {
    final path = value.trim();
    if (path.isEmpty) return false;
    if (path.startsWith('file://')) return true;
    if (RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path)) return true;

    const localRoots = [
      '/data/',
      '/storage/emulated/',
      '/var/mobile/',
      '/private/var/',
      '/home/',
      '/Users/',
      '/tmp/',
    ];

    return localRoots.any(path.startsWith);
  }

  String _localFilePath(String value) {
    if (!value.startsWith('file://')) return value;

    try {
      return Uri.parse(value).toFilePath();
    } catch (_) {
      return value;
    }
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    _isPlaying = false;
    await _player.stop();
    await _player.dispose();
  }
}
