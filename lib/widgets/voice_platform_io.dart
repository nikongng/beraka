import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechResult {
  final String recognizedWords;
  final bool finalResult;

  SpeechResult(this.recognizedWords, this.finalResult);
}

class SpeechRecognizerImpl {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    final available = await _speech.initialize(
      onStatus: (status) {
        _isListening = status == 'listening';
        onStatus?.call(status);
      },
      onError: (error) {
        onError?.call(error.errorMsg ?? 'Erreur de reconnaissance vocale');
      },
    );
    return available;
  }

  Future<void> listen({
    required void Function(SpeechResult result) onResult,
    required Duration listenFor,
    required Duration pauseFor,
    bool partialResults = true,
  }) async {
    await _speech.listen(
      onResult: (result) => onResult(SpeechResult(result.recognizedWords, result.finalResult)),
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: partialResults,
    );
  }

  Future<void> stop() async {
    await _speech.stop();
    _isListening = false;
  }
}

class TextToSpeechImpl {
  final FlutterTts _tts = FlutterTts();
  bool _available = false;

  bool get isAvailable => _available;

  Future<void> init() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_available || text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (!_available) return;
    await _tts.stop();
  }
}
