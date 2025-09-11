import 'dart:convert';
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

  Future<void> init() async {
    if (!Hive.isBoxOpen('authBox')) {
      await Hive.initFlutter();
      await Hive.openBox('authBox');
    }
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }

    final messaging = FirebaseMessaging.instance;
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings();
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: android, iOS: ios),
    );

    final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      final box = Hive.box('authBox');
      final saved = box.get('fcm_token');
      if (token != null && token != saved) {
        box.put('fcm_token', token);
        await _registerTokenToServer(token);
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
      messaging.onTokenRefresh.listen((t) async {
        box.put('fcm_token', t);
        await _registerTokenToServer(t);
      });

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        await _saveToHiveFromRemoteMessage(initial);
      }
    }
  }

  Future<void> _registerTokenToServer(String token) async {
    try {
      final uri = Uri.parse("$mainUrl/api/notification/device/register");
      await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token, 'platform': 'android'}));
    } catch (_) {}
  }

  Future<void> _handleForegroundMessage(RemoteMessage msg) async {
    final n = msg.notification;
    final data = msg.data;
    final androidDetails = AndroidNotificationDetails(
      'fcm_channel', 'FCM Notifications',
      channelDescription: 'FCM', importance: Importance.max, priority: Priority.high);
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      n?.title ?? data['title'] ?? 'Notifikasi',
      n?.body ?? data['body'] ?? '',
      details,
      payload: jsonEncode(data),
    );

    await _saveToHiveFromRemoteMessage(msg);
  }

  Future<void> _handleOpenedMessage(RemoteMessage msg) async {
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
}
