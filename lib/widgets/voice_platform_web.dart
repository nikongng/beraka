class SpeechResult {
  final String recognizedWords;
  final bool finalResult;

  SpeechResult(this.recognizedWords, this.finalResult);
}

class SpeechRecognizerImpl {
  bool get isListening => false;

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    onStatus?.call('unsupported');
    return false;
  }

  Future<void> listen({
    required void Function(SpeechResult result) onResult,
    required Duration listenFor,
    required Duration pauseFor,
    bool partialResults = true,
  }) async {
    // Le microphone n'est pas pris en charge sur le Web via cette implémentation.
  }

  Future<void> stop() async {}
}

class TextToSpeechImpl {
  bool get isAvailable => false;

  Future<void> init() async {}

  Future<void> speak(String text) async {}

  Future<void> stop() async {}
}
