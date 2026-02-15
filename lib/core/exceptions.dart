// Custom Exception Classes
class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(this.message, {this.details, this.stackTrace});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

class ServerException extends AppException {
  final int? statusCode;
  
  ServerException(String message, {this.statusCode, String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

class AudioException extends AppException {
  AudioException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}
