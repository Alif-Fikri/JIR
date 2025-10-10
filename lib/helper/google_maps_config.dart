import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsConfig {
  static String get apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get androidPackageName =>
      dotenv.env['GOOGLE_ANDROID_PACKAGE'] ?? '';

  static String get androidCertificateSha1 =>
      dotenv.env['GOOGLE_ANDROID_CERT_SHA1'] ?? '';

  static String get iosBundleIdentifier =>
      dotenv.env['GOOGLE_IOS_BUNDLE_ID'] ?? '';

  static bool isValid() => apiKey.isNotEmpty;
}
