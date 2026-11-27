import 'dart:async';

import 'app_audio_player_stub.dart'
    if (dart.library.js_interop) 'app_audio_player_web.dart'
    if (dart.library.io) 'app_audio_player_mobile.dart';

abstract class AppAudioPlayer {
  factory AppAudioPlayer() => createAudioPlayer();

  bool get isPlaying;
  Stream<void> get onPlayerComplete;

  Future<void> play(String url);
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
