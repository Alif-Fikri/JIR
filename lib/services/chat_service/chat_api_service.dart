// chat_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String Url = 'http://localhost:8000';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Future<String> getChatResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$Url/get_response'),
        headers: headers,
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] as String;
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}