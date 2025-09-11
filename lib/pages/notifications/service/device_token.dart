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

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );

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
      final data = msg.data ?? {};

      const androidDetails = AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        channelDescription: 'Channel for FCM',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const notifDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await flutterLocalNotificationsPlugin.show(
        msg.hashCode,
        notification?.title ?? data['title'] ?? 'Notifikasi',
        notification?.body ?? data['body'] ?? '',
        notifDetails,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
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

