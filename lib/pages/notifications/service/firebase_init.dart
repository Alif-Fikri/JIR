import 'dart:convert';

import 'package:JIR/pages/notifications/service/device_token.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initFcmAndRegister() async {
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
  String? token = await messaging.getToken();
  print('FCM token: $token');
  final box = Hive.box('authBox'); 
  final savedToken = box.get('fcm_token');
  if (token != null && token != savedToken) {
    box.put('fcm_token', token);
    await registerDeviceTokenToServer(token, 'android');
  }

  await messaging.subscribeToTopic('test-broadcast');

  FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
    print('onMessage: ${msg.notification?.title} - ${msg.notification?.body}');
    final notification = msg.notification;
    final data = msg.data;

    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for FCM',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notifDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      notification?.title ?? data['title'] ?? 'Notifikasi',
      notification?.body ?? data['body'] ?? '',
      notifDetails,
      payload: jsonEncode(data),
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
    print('onMessageOpenedApp: ${msg.data}');
    final data = msg.data;
    // Navigasi sesuai data
    // if (data['route'] == 'flood_detail') Get.toNamed('/flood', arguments: data);
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('Token refreshed: $newToken');
    box.put('fcm_token', newToken);
    await registerDeviceTokenToServer(newToken, 'android');
  });
}
