import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8000/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);
        return {'success': true, 'message': 'Login successful'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
      } else {
        return {'success': false, 'message': 'Server error. Please try again'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Signup successful'};
      } else {
        return {'success': false, 'message': 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Unable to connect to the server'};
    }
  }

  Future<void> _saveToken(String token) async {
    var box = await Hive.openBox('authBox');
    await box.put('token', token);
  }
}
