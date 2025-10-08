import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:JIR/config.dart';

class GoogleSignInResult {
  const GoogleSignInResult._({
    required this.success,
    this.data,
    this.message,
    this.cancelled = false,
  });

  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final bool cancelled;

  factory GoogleSignInResult.success(Map<String, dynamic> data) =>
      GoogleSignInResult._(success: true, data: data);

  factory GoogleSignInResult.cancelled() =>
      const GoogleSignInResult._(success: false, cancelled: true);

  factory GoogleSignInResult.failure(String message) =>
      GoogleSignInResult._(success: false, message: message);
}

class GoogleAuthService {
  GoogleAuthService()
      : _googleSignIn = GoogleSignIn(
          scopes: const ['email'],
          serverClientId: googleAndroidServerClientId,
          clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
              ? googleIosClientId
              : null,
        ),
        _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  Future<GoogleSignInResult> signInWithGoogle() async {
    if (kIsWeb) {
      return GoogleSignInResult.failure(
        'Login Google di web belum dikonfigurasi.',
      );
    }

    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (_) {
      // Ignore signOut failures; continue with fresh sign-in attempt.
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return GoogleSignInResult.cancelled();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential? userCredential;
      try {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        return GoogleSignInResult.failure(
          _mapFirebaseAuthException(e),
        );
      }

      final String? idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return GoogleSignInResult.failure(
          'Token Google tidak tersedia. Silakan coba lagi.',
        );
      }

      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      final Uri googleLoginUrl = Uri.parse('$mainUrl/api/auth/google/login');

      final response = await http
          .post(
            googleLoginUrl,
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode({
              "id_token": idToken,
              if (firebaseIdToken != null) "firebase_token": firebaseIdToken,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final payload = jsonDecode(response.body);
        if (payload is Map<String, dynamic>) {
          return GoogleSignInResult.success(payload);
        }
        return GoogleSignInResult.failure(
          'Format respons server tidak dikenal.',
        );
      }

      String message =
          'Gagal mengotentikasi dengan Google (kode ${response.statusCode}).';
      if (response.statusCode == 404) {
        message =
            'Endpoint Google login tidak ditemukan (404). Pastikan backend memiliki rute ${googleLoginUrl.path}.';
      }
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic>) {
          final serverMessage = errorBody['message']?.toString();
          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          }
        }
      } catch (_) {
        // ignore parsing errors, fall back to default message
      }
      return GoogleSignInResult.failure(message);
    } on PlatformException catch (e, stackTrace) {
      final normalizedCode = e.code.toLowerCase();
      if (normalizedCode == 'sign_in_canceled') {
        return GoogleSignInResult.cancelled();
      }

      if (kDebugMode) {
        debugPrint(
          'Google sign-in PlatformException: code=${e.code}, message=${e.message}',
        );
        debugPrint(stackTrace.toString());
      }

      return GoogleSignInResult.failure(
        _mapPlatformExceptionMessage(e),
      );
    } on TimeoutException {
      return GoogleSignInResult.failure(
        'Permintaan ke server terlalu lama. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      return GoogleSignInResult.failure(
        'Terjadi kesalahan saat login dengan Google: ${e.toString()}',
      );
    }
  }

  String _mapPlatformExceptionMessage(PlatformException exception) {
    final code = exception.code;
    final normalizedCode = code.toLowerCase();
    final suffix = code.isNotEmpty ? ' (kode: $code)' : '';

    if (normalizedCode == 'network_error') {
      return 'Login Google gagal karena perangkat tidak dapat terhubung ke Google. Periksa koneksi internet Anda$suffix.';
    }

    if (normalizedCode == 'sign_in_failed' || normalizedCode == '12500') {
      return 'Login Google gagal$suffix. Pastikan konfigurasi Google Sign-In (SHA-1/SHA-256, client ID, dan google-services.json) sudah sesuai dengan aplikasi ini.';
    }

    if (normalizedCode == 'sign_in_required') {
      return 'Login Google membutuhkan akun Google aktif pada perangkat$suffix.';
    }

    final detail = exception.message?.trim() ?? '';
    final detailSuffix = detail.isNotEmpty ? ' Detail: $detail' : '';
    return 'Login Google gagal$suffix.$detailSuffix';
  }

  String _mapFirebaseAuthException(FirebaseAuthException exception) {
    final code = exception.code;
    final suffix = code.isNotEmpty ? ' (kode: $code)' : '';

    switch (code) {
      case 'network-request-failed':
        return 'Firebase tidak dapat terhubung ke server$suffix. Periksa koneksi internet Anda.';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terhubung dengan metode login lain$suffix. Silakan masuk menggunakan kredensial yang sama.';
      case 'invalid-credential':
      case 'user-disabled':
      case 'user-not-found':
        return 'Kredensial Google tidak valid atau akun dinonaktifkan$suffix.';
      default:
        final message = exception.message?.trim();
        final detailSuffix =
            message != null && message.isNotEmpty ? ' Detail: $message' : '';
        return 'Login Google via Firebase gagal$suffix.$detailSuffix';
    }
  }
}
