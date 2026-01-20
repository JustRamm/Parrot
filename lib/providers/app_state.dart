import 'package:flutter/material.dart';

class AppState {
  static final ValueNotifier<double> gestureSensitivity = ValueNotifier(0.5);
  static final ValueNotifier<double> volumeIntensity = ValueNotifier(0.8);
  static final ValueNotifier<bool> identityMode = ValueNotifier(true);
  
  static final ValueNotifier<double> voiceCreationProgress = ValueNotifier(0.0);
  static final ValueNotifier<bool> isVoiceGenerated = ValueNotifier(false);
  static final ValueNotifier<bool> isRecording = ValueNotifier(false);
  static final ValueNotifier<String> translatedText = ValueNotifier("Gesture detected: Hello! How are you?");
  static final ValueNotifier<double> emotionIntensity = ValueNotifier(0.2);
  
  // Voice Cloning State
  static final ValueNotifier<List<dynamic>?> voiceEmbedding = ValueNotifier(null);
  static final ValueNotifier<String?> currentVoiceId = ValueNotifier(null);
}
