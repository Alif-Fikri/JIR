import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

class ChatService {
  static const String chatUrl = mainUrl;
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Future<String> getChatResponseText(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$chatUrl/api/chat/get_response'),
            headers: headers,
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('route')) {
          return "Rute tersedia, buka peta untuk melihat jalur.";
        }
        return responseData['response']?.toString() ?? responseData.toString();
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<Map<String, dynamic>> getChatResponse(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$chatUrl/api/chat/get_response'),
            headers: headers,
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('route')) {
          return responseData;
        }
        return {
          'response':
              responseData['response']?.toString() ?? responseData.toString()
        };
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      return {'response': 'Error connecting to server: $e'};
    }
  }
}
