import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

class ChatService {
  static const String chatUrl = mainUrl;
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json'
  };

  static Future<Map<String, dynamic>> getChatResponse(String message) async {
    try {
      final uri = Uri.parse('$chatUrl/predict/api/chatbot');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(defaultHeaders);
      request.fields['input_type'] = 'text';
      request.fields['text'] = message;

      final streamed =
          await request.send().timeout(const Duration(seconds: 50));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'response': decoded.toString()};
      } else {
        return {
          'response': 'Terjadi kesalahan (${response.statusCode})',
          'error': response.body
        };
      }
    } catch (e) {
      return {
        'response': 'Gagal menghubungi server: $e',
        'error': e.toString()
      };
    }
  }
}
