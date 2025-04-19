import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.11:8000/auth';

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
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
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

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    final url = Uri.parse('$baseUrl/delete-account');
    final token = await _getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        await _clearToken();
        return {'success': true, 'message': 'Account deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete account'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/change-password');
    final token = await _getToken();

    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': 'Old password is incorrect'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized'};
      } else {
        return {'success': false, 'message': 'Failed to change password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<void> _saveToken(String token) async {
    var box = await Hive.openBox('authBox');
    await box.put('token', token);
  }

  Future<String?> _getToken() async {
    var box = await Hive.openBox('authBox');
    return box.get('token');
  }

  Future<void> _clearToken() async {
    var box = await Hive.openBox('authBox');
    await box.delete('token');
  }
}
