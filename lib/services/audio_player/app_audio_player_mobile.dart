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
      await _player.play(UrlSource(url));
    } catch (_) {
      _isPlaying = false;
      rethrow;
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
