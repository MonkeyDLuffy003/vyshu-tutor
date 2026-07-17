import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'language_service.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttReady = false;

  Future<bool> init() async {
    _sttReady = await _speech.initialize(
      onError: (e) => print('STT error: $e'),
      onStatus: (s) => print('STT status: $s'),
    );
    return _sttReady;
  }

  /// Starts listening and streams partial/final results via [onResult].
  /// Returns false immediately if the mic/engine isn't ready.
  Future<bool> listen({
    required AppLanguage lang,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_sttReady) {
      final ok = await init();
      if (!ok) return false;
    }
    await _speech.listen(
      localeId: lang.speechLocale,
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
    return true;
  }

  Future<void> stopListening() => _speech.stop();

  bool get isListening => _speech.isListening;

  Future<void> speak(String text, AppLanguage lang) async {
    await _tts.setLanguage(lang.ttsLocale);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() => _tts.stop();
}
