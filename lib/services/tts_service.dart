import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Configure for a "guy in his 20s" feel
    // Typically: standard pitch (1.0) or slightly lower, 
    // and a natural speaking rate.
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // 0.5 is usually normal speed in flutter_tts
    await _flutterTts.setVolume(1.0);

    if (kIsWeb) {
      // On Web, we can try to find a specific male voice
      await _flutterTts.setLanguage("en-US");
    } else if (Platform.isWindows) {
      await _flutterTts.setLanguage("en-US");
    }

    _isInitialized = true;
  }

  Future<void> speak(String text, {double? pitch, double? rate}) async {
    if (!_isInitialized) await init();

    if (pitch != null) await _flutterTts.setPitch(pitch);
    if (rate != null) await _flutterTts.setSpeechRate(rate);

    // Try to find a male voice for the "guy in his 20s" vibe
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      
      // Look for a voice that matches our criteria
      var bestVoice;
      
      // Preference order: 
      // 1. Known high-quality male voices
      // 2. Any voice containing "male", "guy", "david", "james"
      // 3. Fallback to first available en-US voice
      
      for (var voice in voices) {
        final Map<dynamic, dynamic> v = voice as Map<dynamic, dynamic>;
        final String name = v['name'].toString().toLowerCase();
        final String locale = v['locale']?.toString().toLowerCase() ?? '';
        
        if (!locale.contains('en')) continue;

        if (name.contains('david') || name.contains('guy') || name.contains('james') || name.contains('male')) {
          bestVoice = v;
          break;
        }
      }

      if (bestVoice != null) {
        await _flutterTts.setVoice(Map<String, String>.from(bestVoice));
      }
    } catch (e) {
      print("TTS Voice Selection Error: $e");
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

final ttsService = TtsService();
