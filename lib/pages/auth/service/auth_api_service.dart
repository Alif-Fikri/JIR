import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:JIR/config.dart';

class AuthService {
  final String authUrl = '$mainUrl/api/auth';

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Email and password cannot be empty'
      };
    }

    final url = Uri.parse('$authUrl/login');

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
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['detail'] ?? 'Invalid request'
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid email or password'};
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode})'
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No Internet connection'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }

    final url = Uri.parse('$authUrl/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Signup successful'};
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['detail'] ?? 'Signup failed'};
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode})'
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'No Internet connection'};
    } on FormatException {
      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    final url = Uri.parse('$authUrl/delete-account');
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
    final url = Uri.parse('$authUrl/change-password');
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

  Future<Map<String, dynamic>> logout() async {
    final token = await _getToken();
    final url = Uri.parse('$authUrl/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _clearToken();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {
          'success': false,
          'message': 'Server logout failed (${response.statusCode})'
        };
      }
    } catch (e) {
      await _clearToken();
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('$authUrl/me');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch profile (${resp.statusCode})');
    }
  }

  Future<void> _saveToken(String token) async {
    var box = await Hive.openBox('authBox');
    await box.put('token', token);
    print('Token saved: $token');
  }

  Future<String?> _getToken() async {
    var box = await Hive.openBox('authBox');
    return box.get('token');
  }

  Future<void> _clearToken() async {
    var box = await Hive.openBox('authBox');
    await box.delete('token');
    await box.close();
    print('Token cleared');
  }
}
