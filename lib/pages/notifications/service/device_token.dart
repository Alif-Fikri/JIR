import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<bool> registerDeviceTokenToServer(String token, String platform) async {
  try {
    final uri = Uri.parse("$mainUrl/api/notification/device/register");
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token, 'platform': platform}),
        )
        .timeout(const Duration(seconds: 10));
    return resp.statusCode == 200 || resp.statusCode == 201;
  } catch (e) {
    print('registerDeviceTokenToServer error: $e');
    return false;
  }
}

Future<void> _saveNotificationToHive({
  required String title,
  required String message,
  String? icon,
  Map<String, dynamic>? rawData,
}) async {
  try {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    final box = Hive.box('notifications');
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final Map<String, dynamic> item = {
      'id': id,
      'icon': icon ?? 'assets/images/ic_launcher.png',
      'title': title,
      'message': message,
      'time': now.toIso8601String(),
      'isChecked': false,
      'raw': rawData ?? {},
    };
    final List current = List.from(box.get('list', defaultValue: []));
    current.insert(0, item);
    await box.put('list', current);
  } catch (e) {
    print('Error saving notification to Hive: $e');
  }
}

Future<void> requestNotificationPermissionsAndInit() async {
  final messaging = FirebaseMessaging.instance;
  if (!Hive.isBoxOpen('authBox')) {
    await Hive.initFlutter();
    await Hive.openBox('authBox');
  }
  if (!Hive.isBoxOpen('notifications')) {
    await Hive.openBox('notifications');
  }
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  print('Notification permission status: ${settings.authorizationStatus}');
  final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  final iosInit = DarwinInitializationSettings();
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(android: androidInit, iOS: iosInit),
  );
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final notif = initialMessage.notification;
    final data = initialMessage.data;
    final title = notif?.title ?? data['title'] ?? 'Notifikasi';
    final body = notif?.body ?? data['body'] ?? jsonEncode(data);
    final icon = data['icon'] as String?;
    await _saveNotificationToHive(title: title, message: body, icon: icon, rawData: data);
  }
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    String? token = await messaging.getToken();
    print('FCM token: $token');
    final box = Hive.box('authBox');
    final saved = box.get('fcm_token');
    if (token != null && saved != token) {
      box.put('fcm_token', token);
      await registerDeviceTokenToServer(token, 'android');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final notification = msg.notification;
      final data = msg.data;
      final androidDetails = AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        channelDescription: 'Channel for FCM',
        importance: Importance.max,
        priority: Priority.high,
      );
      final iosDetails = DarwinNotificationDetails();
      final notifDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await flutterLocalNotificationsPlugin.show(
        msg.hashCode,
        notification?.title ?? data['title'] ?? 'Notifikasi',
        notification?.body ?? data['body'] ?? '',
        notifDetails,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
      final title = notification?.title ?? data['title'] ?? 'Notifikasi';
      final body = notification?.body ?? data['body'] ?? jsonEncode(data);
      final icon = data['icon'] as String?;
      await _saveNotificationToHive(title: title, message: body, icon: icon, rawData: data);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) async {
      final notification = msg.notification;
      final data = msg.data;
      final title = notification?.title ?? data['title'] ?? 'Notifikasi';
      final body = notification?.body ?? data['body'] ?? jsonEncode(data);
      final icon = data['icon'] as String?;
      await _saveNotificationToHive(title: title, message: body, icon: icon, rawData: data);
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final box = Hive.box('authBox');
      box.put('fcm_token', newToken);
      await registerDeviceTokenToServer(newToken, 'android');
    });
  } else {
    print('Notification permission denied or not granted');
  }
}
