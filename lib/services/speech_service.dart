import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText;

  SpeechService({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  Future<bool> initialize({
    required Function(String status) onStatus,
    required Function(SpeechRecognitionError error) onError,
  }) async {
    return await _speechToText.initialize(
      onStatus: onStatus,
      onError: onError,
      debugLogging: kDebugMode,
    );
  }

  bool get isListening => _speechToText.isListening;

  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required String localeId,
  }) async {
    if (!_speechToText.isAvailable) {
      throw Exception('Serviço de reconhecimento de voz não disponível.');
    }

    await _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }
}
