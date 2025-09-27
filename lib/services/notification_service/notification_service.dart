import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';
import 'package:JIR/services/notification_service/tts_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  NotificationService._private();
  static final NotificationService I = NotificationService._private();

  bool _pendingProcessorActive = false;

  Future<void> init() async {
    await _ensureHiveBoxes();
    await _initLocalNotifications();
    await TtsService.I.init();
    await _initFcmHandlers();
    await _retryPendingRegistration();
    await _processPendingWhenControllerReady();
  }

  Future<void> _ensureHiveBoxes() async {
    if (!Hive.isBoxOpen('authBox')) {
      await Hive.initFlutter();
      await Hive.openBox('authBox');
    }
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
  }

  Future<void> _initLocalNotifications() async {
    final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (NotificationResponse resp) async {
        final payload = resp.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(payload);
            await _handleNotificationClick(data);
          } catch (e) {}
        }
      },
    );
  }

  Future<void> _initFcmHandlers() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!(settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional)) {
      debugPrint('FCM permission not granted: ${settings.authorizationStatus}');
      return;
    }

    try {
      try {
        final apns = await messaging.getAPNSToken();
        debugPrint('APNs token: $apns');
      } catch (_) {}

      await _attemptGetAndRegisterFcmToken(messaging);
    } catch (e, st) {
      debugPrint('Error while getting FCM token: $e\n$st');
    }

    messaging.onTokenRefresh.listen((t) async {
      await _handleFetchedFcmToken(t);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) async {
      if (msg.data.isNotEmpty) await _handleNotificationClick(msg.data);
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null && initial.data.isNotEmpty) {
      await _handleNotificationClick(initial.data);
    }
  }

  Future<void> _attemptGetAndRegisterFcmToken(
    FirebaseMessaging messaging, {
    int retries = 6,
    int delayMs = 2000,
  }) async {
    String? token;
    for (var i = 0; i < retries; i++) {
      try {
        token = await messaging.getToken();
      } catch (_) {
        token = null;
      }
      debugPrint('[NotificationService] getToken attempt ${i + 1}: $token');
      if (token != null && token.isNotEmpty) {
        await _handleFetchedFcmToken(token);
        return;
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    debugPrint('[NotificationService] FCM token not available after retries');
  }

  Future<void> _handleFetchedFcmToken(String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('FCM token is null/empty');
      return;
    }
    final box = Hive.box('authBox');
    final saved = box.get('fcm_token');
    if (saved != token) {
      box.put('fcm_token', token);
      await _registerTokenToServer(token);
    }
  }

  Future<void> _registerTokenToServer(String token) async {
    try {
      final platformStr = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : 'other';
      final uri = Uri.parse("$mainUrl/api/notification/device/register");
      debugPrint('[NotificationService] registering token to server: $uri');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token, 'platform': platformStr}));

      debugPrint(
          '[NotificationService] register token response: ${res.statusCode} ${res.body}');

      final box = Hive.box('authBox');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        box.put('fcm_registered', true);
        if (box.get('pending_fcm_token') != null) {
          box.delete('pending_fcm_token');
        }
      } else {
        box.put('pending_fcm_token', token);
        debugPrint(
            '[NotificationService] token registration failed (non-2xx), saved as pending');
      }
    } catch (e, st) {
      debugPrint('[NotificationService] register token error: $e\n$st');
      try {
        final box = Hive.box('authBox');
        box.put('pending_fcm_token', token);
      } catch (_) {}
    }
  }

  Future<void> _retryPendingRegistration() async {
    try {
      final box = Hive.box('authBox');
      final pending = box.get('pending_fcm_token');
      if (pending != null && pending is String && pending.isNotEmpty) {
        debugPrint(
            '[NotificationService] retrying pending FCM token registration');
        await _registerTokenToServer(pending);
      }
    } catch (e, st) {
      debugPrint(
          '[NotificationService] retry pending registration error: $e\n$st');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    final n = msg.notification;
    final data = msg.data;

    final androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'FCM',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final title = n?.title ?? data['title'] ?? 'Notifikasi';
    final body = n?.body ?? data['body'] ?? '';

    await flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      title,
      body,
      details,
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );

    await TtsService.I.speak('$title. $body');

    await _saveToHiveFromRemoteMessage(msg);
  }

  Future<void> _saveToHiveFromRemoteMessage(RemoteMessage msg) async {
    final n = msg.notification;
    final data = msg.data;
    final box = Hive.box('notifications');
    final now = DateTime.now();

    String type =
        (data['type'] ?? data['category'] ?? '').toString().toLowerCase();
    String icon = (data['icon'] ?? '').toString().trim();

    if (icon.isEmpty) {
      if (type.contains('flood') ||
          type.contains('banjir') ||
          type.contains('peringatan') ||
          (n?.title?.toLowerCase().contains('banjir') ?? false)) {
        icon = 'assets/images/peringatan.png';
      } else if (type.contains('weather') ||
          type.contains('cuaca') ||
          type.contains('suhu')) {
        icon = 'assets/images/suhu.png';
      } else if (type.contains('report') || type.contains('laporan')) {
        icon = 'assets/images/laporan.png';
      } else {
        icon = 'assets/images/ic_launcher.png';
      }
    }

    final id = now.millisecondsSinceEpoch;
    final timeStr = now.toIso8601String();
    final title = n?.title ?? data['title'] ?? 'Notifikasi';
    final body = n?.body ?? data['body'] ?? '';

    final item = {
      'id': id,
      'icon': icon,
      'title': title,
      'message': body,
      'time': timeStr,
      'type': type,
      'isChecked': false,
      'raw': data,
    };

    final List current = List.from(box.get('list', defaultValue: []));
    current.insert(0, item);
    await box.put('list', current);
  }

  Future<void> _storePendingNotification(Map<String, dynamic> data) async {
    final box = Hive.box('notifications');
    await box.put('pending_notification', data);
    unawaited(_processPendingWhenControllerReady());
  }

  Future<Map<String, dynamic>?> _popPendingNotification() async {
    final box = Hive.box('notifications');
    final raw = box.get('pending_notification');
    if (raw == null) return null;
    await box.delete('pending_notification');
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  Future<void> _processPendingWhenControllerReady({
    int maxAttempts = 50,
    int delayMs = 200,
  }) async {
    if (_pendingProcessorActive) return;
    _pendingProcessorActive = true;
    try {
      int attempts = 0;
      while (attempts < maxAttempts) {
        if (Get.isRegistered<ReportController>()) {
          final pending = await _popPendingNotification();
          if (pending != null) {
            await _handleNotificationClick(pending);
          }
          break;
        }
        await Future.delayed(Duration(milliseconds: delayMs));
        attempts++;
      }
    } finally {
      _pendingProcessorActive = false;
    }
  }

  Future<bool> _waitForReportController({int maxTimeoutMs = 3000}) async {
    final step = 100;
    var waited = 0;
    while (!Get.isRegistered<ReportController>() && waited < maxTimeoutMs) {
      await Future.delayed(Duration(milliseconds: step));
      waited += step;
    }
    return Get.isRegistered<ReportController>();
  }

  Future<void> _handleNotificationClick(Map<String, dynamic> data) async {
    try {
      final ready = await _waitForReportController(maxTimeoutMs: 3000);
      if (!ready) {
        await _storePendingNotification(data);
        return;
      }

      final reportIdStr = data['report_id'] ?? data['reportId'] ?? data['id'];
      if (reportIdStr == null) return;
      final id = int.tryParse(reportIdStr.toString());
      if (id == null) return;

      final ctrl = Get.find<ReportController>();
      await ctrl.refreshReportFromServer(id);

      final idx =
          ctrl.reports.indexWhere((r) => r['id'].toString() == id.toString());
      if (idx != -1) {
        final rpt = ctrl.reports[idx];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(AppRoutes.reportdetail, arguments: rpt);
        });
      } else {
        Get.snackbar('Info', 'Laporan diperbarui tetapi tidak ditemukan lokal');
      }
    } catch (e) {}
  }
}
