import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await Hive.openBox('notifications');
  await saveRemoteMessageToHive(message);
}

Future<void> saveRemoteMessageToHive(RemoteMessage message) async {
  try {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    final box = Hive.box('notifications');
    final now = DateTime.now();
    final item = {
      'id': now.millisecondsSinceEpoch,
      'icon': message.data['icon'] ?? 'assets/images/ic_launcher.png',
      'title':
          message.notification?.title ?? message.data['title'] ?? 'Notifikasi',
      'message': message.notification?.body ?? message.data['body'] ?? '',
      'time': now.toIso8601String(),
      'type': message.data['type'] ?? message.data['category'] ?? 'general',
      'raw': message.data,
      'isChecked': false,
    };
    final List current = List.from(box.get('list', defaultValue: []));
    current.insert(0, item);
    await box.put('list', current);
  } catch (e, st) {
    debugPrint('saveRemoteMessageToHive error: $e\n$st');
  }
}

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    await _localNotif.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {},
    );

    NotificationSettings settings =
        await _fm.requestPermission(alert: true, badge: true, sound: true);
    print('User permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('onMessage: ${message.notification?.title}');
      await _showLocalNotification(message);
      await _saveMessageToHive(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('onMessageOpenedApp: ${message.data}');
      await _saveMessageToHive(message);
    });

    String? token = await _fm.getToken();
    print('FCM token: $token');
    if (token != null) await saveTokenToFirestore(token);

    _fm.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(newToken);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null && (message.data['title'] == null)) return;

    final title = n?.title ?? message.data['title'];
    final body = n?.body ?? message.data['body'];

    const androidDetails = AndroidNotificationDetails(
      'flood_channel',
      'Flood & Weather Alerts',
      channelDescription: 'Notifikasi peringatan banjir dan cuaca',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final platform =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotif.show(id, title, body, platform,
        payload: message.data.toString());
  }

  Future<void> _saveMessageToHive(RemoteMessage message) async {
    try {
      await saveRemoteMessageToHive(message);
    } catch (e) {
      print('gagal simpan message ke hive: $e');
    }
  }

  Future<void> saveTokenToFirestore(String token) async {
    try {
      Position? pos;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (_) {
        pos = null;
      }

      final deviceDoc = _firestore.collection('devices').doc(token);
      final data = {
        'fcmToken': token,
        'lastSeen': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      };
      if (pos != null) {
        data['location'] = {'lat': pos.latitude, 'lon': pos.longitude};
      }
      await deviceDoc.set(data, SetOptions(merge: true));
    } catch (e) {
      print('saveTokenToFirestore error: $e');
    }
  }

  Future<void> deleteToken(String token) async {
    await _firestore.collection('devices').doc(token).delete();
  }
}
