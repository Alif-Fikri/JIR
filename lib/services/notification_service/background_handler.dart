import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

final FlutterLocalNotificationsPlugin bgFlutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final ios = DarwinInitializationSettings();
  await bgFlutterLocalNotificationsPlugin.initialize(
    InitializationSettings(android: android, iOS: ios),
  );

  final n = message.notification;
  final data = message.data;
  final androidDetails = AndroidNotificationDetails(
    'fcm_channel', 'FCM Notifications',
    channelDescription: 'FCM',
    importance: Importance.max,
    priority: Priority.high,
  );
  final iosDetails = DarwinNotificationDetails();
  final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  await bgFlutterLocalNotificationsPlugin.show(
    message.hashCode,
    n?.title ?? data['title'],
    n?.body ?? data['body'],
    details,
    payload: jsonEncode(data),
  );

  try {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    final box = await Hive.openBox('notifications');

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
    await box.close();
  } catch (_) {}
}
