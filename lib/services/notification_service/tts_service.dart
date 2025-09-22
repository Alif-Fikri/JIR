import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._private();
  static final TtsService I = TtsService._private();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.45); 
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      // _tts.awaitSpeakCompletion(true); // optional
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    final t = (text).trim();
    if (t.isEmpty) return;
    try {
      await _tts.speak(t);
    } catch (_) {}
  }

  Future<void> stop() async => await _tts.stop();
}