import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _tts = FlutterTts();

  final FlutterTts _tts;

  Future<void> speakWord(String word, {required String languageCode}) async {
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.08);
    await _tts.speak(word);
  }

  Future<void> stop() {
    return _tts.stop();
  }
}
