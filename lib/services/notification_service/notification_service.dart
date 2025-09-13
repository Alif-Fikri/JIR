import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/home/report/controller/report_controller.dart';
import 'package:JIR/pages/home/report/widget/report_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  NotificationService._private();
  static final NotificationService I = NotificationService._private();

  bool _pendingProcessorActive = false;

  Future<void> init() async {
    await _ensureHiveBoxes();
    await _initLocalNotifications();
    await _initFcmHandlers();
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
          } catch (e) {
            print('parse payload error: $e');
          }
        }
      },
    );
  }

  Future<void> _initFcmHandlers() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      final box = Hive.box('authBox');
      final saved = box.get('fcm_token');
      if (token != null && saved != token) {
        box.put('fcm_token', token);
        await _registerTokenToServer(token);
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) async {
        if (msg.data.isNotEmpty) {
          await _handleNotificationClick(msg.data);
        }
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null && initial.data.isNotEmpty) {
        await _handleNotificationClick(initial.data);
      }

      messaging.onTokenRefresh.listen((t) async {
        box.put('fcm_token', t);
        await _registerTokenToServer(t);
      });
    } else {
    }
  }

  Future<void> _registerTokenToServer(String token) async {
    try {
      final uri = Uri.parse("$mainUrl/api/notification/device/register");
      await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token, 'platform': 'android'}));
    } catch (e) {
      print('register token error: $e');
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

    await flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      n?.title ?? data['title'] ?? 'Notifikasi',
      n?.body ?? data['body'] ?? '',
      details,
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );

    await _saveToHiveFromRemoteMessage(msg);
  }

  Future<void> _saveToHiveFromRemoteMessage(RemoteMessage msg) async {
    final n = msg.notification;
    final data = msg.data;
    final box = Hive.box('notifications');
    final now = DateTime.now();
    final item = {
      'id': now.millisecondsSinceEpoch,
      'icon': data['icon'] ?? 'assets/images/ic_launcher.png',
      'title': n?.title ?? data['title'] ?? 'Notifikasi',
      'message': n?.body ?? data['body'] ?? jsonEncode(data),
      'time': now.toIso8601String(),
      'isChecked': false,
      'raw': data,
    };
    final list = List.from(box.get('list', defaultValue: []));
    list.insert(0, item);
    await box.put('list', list);
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
          Get.to(() => ReportDetailPage(report: rpt));
        });
      } else {
        Get.snackbar('Info', 'Laporan diperbarui tetapi tidak ditemukan lokal');
      }
    } catch (e, st) {
      print('handleNotificationClick error: $e\n$st');
    }
  }
}
