import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'app_audio_player.dart';

AppAudioPlayer createAudioPlayer() => WebAudioPlayer();

class WebAudioPlayer implements AppAudioPlayer {
  web.HTMLAudioElement? _element;
  final _completeController = StreamController<void>.broadcast();
  StreamSubscription? _endedSubscription;
  StreamSubscription? _errorSubscription;
  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;

  @override
  Future<void> play(String url) async {
    await stop();

    final audio = web.HTMLAudioElement();
    _element = audio;
    audio.preload = 'auto';
    audio.src = url;

    _isPlaying = true;

    _endedSubscription = audio.onEnded.listen((_) {
      _isPlaying = false;
      _completeController.add(null);
    });

    _errorSubscription = audio.onError.listen((_) {
      _isPlaying = false;
    });

    try {
      await audio.play().toDart;
    } catch (e) {
      _isPlaying = false;
      throw Exception('Gagal memutar audio: $e');
    }
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _element?.pause();
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    await _endedSubscription?.cancel();
    _endedSubscription = null;
    await _errorSubscription?.cancel();
    _errorSubscription = null;

    if (_element != null) {
      _element!.pause();
      _element!.currentTime = 0;
      _element!.src = '';
      _element!.remove();
      _element = null;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _completeController.close();
  }
}
