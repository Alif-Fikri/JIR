import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NavigationForegroundBridge {
  const NavigationForegroundBridge._();

  static const MethodChannel _channel = MethodChannel('jir/navigation/service');

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static Future<void> start({
    required String title,
    required String subtitle,
    required String distance,
    required String duration,
    required String instruction,
  }) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('startNavigation', {
        'title': title,
        'subtitle': subtitle,
        'distance': distance,
        'duration': duration,
        'instruction': instruction,
      });
    } catch (err, stackTrace) {
      debugPrint('NavigationForegroundBridge.start error: $err');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> update({
    required String title,
    required String subtitle,
    required String distance,
    required String duration,
    required String instruction,
  }) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('updateNavigation', {
        'title': title,
        'subtitle': subtitle,
        'distance': distance,
        'duration': duration,
        'instruction': instruction,
      });
    } catch (err, stackTrace) {
      debugPrint('NavigationForegroundBridge.update error: $err');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> stop() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('stopNavigation');
    } catch (err, stackTrace) {
      debugPrint('NavigationForegroundBridge.stop error: $err');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
