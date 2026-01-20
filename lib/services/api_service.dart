
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for Windows/iOS simulator
  // Since user is on Windows, localhost is fine for Windows build.
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> cloneVoice(String filePath) async {
    var uri = Uri.parse('$baseUrl/clone_voice');
    var request = http.MultipartRequest('POST', uri);
    
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      filePath,
      contentType: MediaType('audio', 'wav'), // Adjust if supporting others
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to clone voice: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<List<int>> synthesizeSpeech(String text, List<dynamic> embedding) async {
    var uri = Uri.parse('$baseUrl/synthesize');
    
    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'embedding': embedding,
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
         // Try to parse error message
         try {
           final errorBody = json.decode(response.body);
           print("Synthesis Error: ${errorBody['error']}");
         } catch (_) {
           print("Synthesis Error: ${response.body}");
         }
        throw Exception('Failed to synthesize speech: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
