import '../core/constants.dart';
import '../core/exceptions.dart';

class Validators {
  // Text validation
  static String? validateText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return ErrorMessages.emptyText;
    }
    
    if (text.length > AppConstants.maxTextLength) {
      return 'Text is too long. Maximum ${AppConstants.maxTextLength} characters allowed.';
    }
    
    if (text.length < AppConstants.minTextLength) {
      return 'Text is too short. Minimum ${AppConstants.minTextLength} character required.';
    }
    
    return null;
  }
  
  // File validation
  static ValidationException? validateAudioFile(String? filePath, int? fileSizeBytes) {
    if (filePath == null || filePath.isEmpty) {
      return ValidationException('No file selected');
    }
    
    // Check file extension
    final extension = filePath.toLowerCase().split('.').last;
    if (!['wav', 'mp3', 'm4a', 'aac'].contains(extension)) {
      return ValidationException(ErrorMessages.invalidFileFormat);
    }
    
    // Check file size
    if (fileSizeBytes != null) {
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      if (fileSizeMB > AppConstants.maxAudioFileSizeMB) {
        return ValidationException(ErrorMessages.fileTooLarge);
      }
    }
    
    return null;
  }
  
  // Voice embedding validation
  static bool isValidEmbedding(List<dynamic>? embedding) {
    if (embedding == null || embedding.isEmpty) {
      return false;
    }
    
    // Check if all elements are numbers
    return embedding.every((e) => e is num);
  }
  
  // Sanitize text input
  static String sanitizeText(String text) {
    // Remove control characters and trim
    return text.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
  }
}
