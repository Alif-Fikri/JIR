import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:JIR/config.dart';

class AuthService {
  final String authUrl = '$mainUrl/api/auth';

  void _logError(String where, Object e, [StackTrace? st]) {
    developer.log('AuthService error in $where: $e',
        stackTrace: st, name: 'AuthService');
  }

  String _messageFromResponse(int statusCode, Map<String, dynamic>? body) {
    final detail =
        body != null ? (body['detail'] ?? body['message'] ?? '') : '';

    if (statusCode == 200 || statusCode == 201) {
      return 'Berhasil';
    }

    switch (statusCode) {
      case 400:
        if (detail
                .toString()
                .toLowerCase()
                .contains('email already registered') ||
            detail.toString().toLowerCase().contains('email sudah terdaftar')) {
          return 'Email sudah terdaftar.';
        }
        return 'Permintaan tidak valid. Periksa kembali input Anda.';
      case 401:
      case 403:
        return 'Email atau kata sandi salah.';
      case 404:
        return 'Data tidak ditemukan.';
      case 409:
        return 'Terjadi konflik data.';
      case 500:
      default:
        if (detail != null && detail.toString().isNotEmpty) {
          return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Email dan kata sandi tidak boleh kosong.'
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
        final token = data['access_token'];
        if (token != null) {
          await _saveToken(token.toString());
          return {'success': true, 'message': 'Login berhasil.'};
        } else {
          _logError('login', 'access_token missing', StackTrace.current);
          return {'success': false, 'message': 'Respons server tidak lengkap.'};
        }
      } else {
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'message': _messageFromResponse(response.statusCode, body)
        };
      }
    } on SocketException catch (e, st) {
      _logError('login', e, st);
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } on FormatException catch (e, st) {
      _logError('login', e, st);
      return {'success': false, 'message': 'Respons server tidak valid.'};
    } catch (e, st) {
      _logError('login', e, st);
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Semua kolom harus diisi.'};
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
        return {'success': true, 'message': 'Pendaftaran berhasil.'};
      } else {
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        final msg = _messageFromResponse(response.statusCode, body);
        return {'success': false, 'message': msg};
      }
    } on SocketException catch (e, st) {
      _logError('signup', e, st);
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e, st) {
      _logError('signup', e, st);
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
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
        return {'success': true, 'message': 'Akun berhasil dihapus.'};
      } else {
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'message': _messageFromResponse(response.statusCode, body)
        };
      }
    } on SocketException catch (e, st) {
      _logError('deleteAccount', e, st);
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e, st) {
      _logError('deleteAccount', e, st);
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    final url = Uri.parse('$authUrl/change-password');
    final token = await _getToken();

    if (token == null) {
      return {'success': false, 'message': 'Anda belum masuk.'};
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
        return {'success': true, 'message': 'Kata sandi berhasil diubah.'};
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': 'Kata sandi lama tidak sesuai.'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Tidak terautentikasi.'};
      } else {
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'message': _messageFromResponse(response.statusCode, body)
        };
      }
    } on SocketException catch (e, st) {
      _logError('changePassword', e, st);
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e, st) {
      _logError('changePassword', e, st);
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
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
        return {'success': true, 'message': 'Berhasil keluar.'};
      } else {
        return {'success': false, 'message': 'Gagal melakukan logout.'};
      }
    } catch (e, st) {
      _logError('logout', e, st);
      await _clearToken();
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
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
      _logError('fetchProfile', 'status ${resp.statusCode} - ${resp.body}');
      throw Exception('Gagal mengambil profil (${resp.statusCode})');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    if (email.isEmpty) {
      return {'success': false, 'message': 'Email tidak boleh kosong.'};
    }
    final url = Uri.parse('$authUrl/forgot-password');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final success = body['success'] == true;
          final message =
              (body['message'] as String?) ?? 'Permintaan diproses.';
          final resetToken = body['reset_token'] as String?;
          return {
            'success': success,
            'message': message,
            'reset_token': resetToken
          };
        } catch (_) {
          return {
            'success': true,
            'message': 'Permintaan diproses. Periksa email Anda.',
            'reset_token': null
          };
        }
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Email tidak terdaftar.'};
      } else if (response.statusCode == 400) {
        String msg = 'Permintaan tidak valid.';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['detail'] != null)
            msg = body['detail'].toString();
        } catch (_) {}
        return {'success': false, 'message': msg};
      } else {
        return {
          'success': false,
          'message': 'Terjadi kesalahan server. Silakan coba lagi nanti.'
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan memakan waktu terlalu lama. Coba lagi.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String token, String newPassword) async {
    if (email.isEmpty || token.isEmpty || newPassword.isEmpty) {
      return {'success': false, 'message': 'Permintaan tidak valid.'};
    }
    final url = Uri.parse('$authUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Kata sandi berhasil diubah.'};
      } else {
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'message': _messageFromResponse(response.statusCode, body)
        };
      }
    } on SocketException catch (e, st) {
      _logError('resetPassword', e, st);
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e, st) {
      _logError('resetPassword', e, st);
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.'
      };
    }
  }

  Future<void> _saveToken(String token) async {
    var box = await Hive.openBox('authBox');
    await box.put('token', token);
  }

  Future<void> persistToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;
    await _saveToken(trimmed);
  }

  Future<String?> _getToken() async {
    var box = await Hive.openBox('authBox');
    return box.get('token');
  }

  Future<void> _clearToken() async {
    var box = await Hive.openBox('authBox');
    await box.delete('token');
    await box.close();
  }
}
