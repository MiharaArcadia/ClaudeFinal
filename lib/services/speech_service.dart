import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;

  bool get isListening => _listening;
  bool get isAvailable => _available;

  Future<bool> initialize() async {
    _available = await _speech.initialize(
      onError: (e) => _listening = false,
    );
    return _available;
  }

  Future<void> startListening({
    required void Function(String words) onResult,
    required void Function(String words) onFinalResult,
    String language = 'de',
  }) async {
    if (!_available) await initialize();
    if (!_available) return;

    final localeId = language == 'de' ? 'de_DE' : 'en_US';
    _listening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          _listening = false;
          onFinalResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        // Dictation mode is far more tolerant of soft/continuous speech than
        // the default confirmation mode (which cuts off quiet input quickly).
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: false,
      ),
    );
  }

  Future<void> stopListening() async {
    _listening = false;
    await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
  }
}
