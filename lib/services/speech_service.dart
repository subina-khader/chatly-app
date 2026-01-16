import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  // Initialize speech services
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    _isInitialized = await _speech.initialize();

    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    return _isInitialized;
  }

  // Start listening
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) throw Exception('Speech recognition not available');
    }

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  // Check if listening
  bool get isListening => _speech.isListening;

  // Speak text
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // Check if speaking
  Future<bool> isSpeaking() async {
    return await _tts.awaitSpeakCompletion(true);
  }
}