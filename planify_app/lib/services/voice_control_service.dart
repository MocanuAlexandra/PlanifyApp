import 'package:speech_to_text/speech_to_text.dart';

class VoiceControlService {
  //! Default language is device language
  static final _speech = SpeechToText();
  static bool isAvailable = false;

  static Future<bool> toggleRecording({
    required Function(String text) onResult,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    if (isAvailable) {
      _speech.listen(
        onResult: (value) => onResult(value.recognizedWords),
      );
    }

    return isAvailable;
  }

  static stopRecording() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  static Future<void> initialize() async {
    isAvailable = await _speech.initialize(
        finalTimeout: const Duration(seconds: 60), debugLogging: true);
  }
}
