// App Constants
class AppConstants {
  // Network
  static const String baseUrl = 'http://127.0.0.1:5000';
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;
  
  // Polling
  static const Duration videoFramePollingInterval = Duration(milliseconds: 40);
  static const Duration socketReconnectDelay = Duration(seconds: 3);
  
  // Video
  static const int jpegQuality = 50;
  static const double targetFps = 50.0;
  
  // UI
  static const double bottomNavigationClearance = 120.0;
  static const double defaultPadding = 24.0;
  static const double defaultBorderRadius = 16.0;
  
  // Voice
  static const int minVoiceSampleDurationSeconds = 3;
  static const int maxVoiceSampleDurationSeconds = 30;
  static const int maxAudioFileSizeMB = 10;
  
  // Text
  static const int maxTextLength = 500;
  static const int minTextLength = 1;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration loadingAnimationDuration = Duration(milliseconds: 500);
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Unable to connect to server. Please check your connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String voiceNotCreated = 'Please create your voice identity first.';
  static const String emptyText = 'Please enter some text to speak.';
  static const String fileTooLarge = 'File is too large. Maximum size is 10MB.';
  static const String invalidFileFormat = 'Invalid file format. Please select a WAV or MP3 file.';
  static const String cameraPermissionDenied = 'Camera permission is required to detect sign language.';
  static const String microphonePermissionDenied = 'Microphone permission is required to record your voice.';
  static const String synthesisError = 'Failed to generate speech. Please try again.';
  static const String cloningError = 'Failed to clone voice. Please try a different audio sample.';
}

// Success Messages
class SuccessMessages {
  static const String voiceCloned = 'Voice identity created successfully!';
  static const String textCopied = 'Text copied to clipboard!';
  static const String settingsSaved = 'Settings saved successfully!';
}

// Voice Profiles
class VoiceProfiles {
  static const String natural = 'Natural';
  static const String professional = 'Professional';
  static const String warm = 'Warm';
  static const String cloned = 'Cloned';
  
  static const List<String> all = [natural, professional, warm, cloned];
}
