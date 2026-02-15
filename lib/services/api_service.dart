
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../core/validators.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  final http.Client _client = http.Client();

  // Clone voice with proper error handling
  Future<Map<String, dynamic>> cloneVoice(String filePath, int fileSizeBytes) async {
    // Validate file
    final validationError = Validators.validateAudioFile(filePath, fileSizeBytes);
    if (validationError != null) {
      throw validationError;
    }

    final uri = Uri.parse('$baseUrl/clone_voice');
    final request = http.MultipartRequest('POST', uri);
    
    try {
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        filePath,
        contentType: MediaType('audio', 'wav'),
      ));

      final streamedResponse = await request.send().timeout(
        AppConstants.networkTimeout,
        onTimeout: () {
          throw NetworkException(ErrorMessages.networkError);
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Validate response
        if (data['success'] != true || data['embedding'] == null) {
          throw ServerException(
            ErrorMessages.cloningError,
            details: data['error']?.toString(),
          );
        }
        
        return data;
      } else if (response.statusCode >= 500) {
        throw ServerException(
          ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      } else {
        final errorBody = _parseErrorBody(response.body);
        throw ServerException(
          errorBody ?? ErrorMessages.cloningError,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(ErrorMessages.networkError);
    } on http.ClientException {
      throw NetworkException(ErrorMessages.networkError);
    } on FormatException {
      throw ServerException('Invalid response from server');
    }
  }

  // Synthesize speech with proper error handling
  Future<List<int>> synthesizeSpeech(
    String text,
    List<dynamic>? embedding, {
    String? voiceProfile,
  }) async {
    // Validate text
    final textError = Validators.validateText(text);
    if (textError != null) {
      throw ValidationException(textError);
    }

    // Sanitize text
    final sanitizedText = Validators.sanitizeText(text);

    final uri = Uri.parse('$baseUrl/synthesize');
    
    try {
      final Map<String, dynamic> body = {
        'text': sanitizedText,
      };
      
      if (embedding != null) {
        if (!Validators.isValidEmbedding(embedding)) {
          throw ValidationException('Invalid voice embedding');
        }
        body['embedding'] = embedding;
      }
      
      if (voiceProfile != null) {
        body['voice_profile'] = voiceProfile;
      }

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(
        AppConstants.networkTimeout,
        onTimeout: () {
          throw NetworkException(ErrorMessages.networkError);
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode >= 500) {
        throw ServerException(
          ErrorMessages.serverError,
          statusCode: response.statusCode,
        );
      } else {
        final errorBody = _parseErrorBody(response.body);
        throw ServerException(
          errorBody ?? ErrorMessages.synthesisError,
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(ErrorMessages.networkError);
    } on http.ClientException {
      throw NetworkException(ErrorMessages.networkError);
    } on FormatException {
      throw ServerException('Invalid response from server');
    }
  }

  // Parse error message from response body
  String? _parseErrorBody(String body) {
    try {
      final errorData = json.decode(body);
      return errorData['error']?.toString();
    } catch (_) {
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}
