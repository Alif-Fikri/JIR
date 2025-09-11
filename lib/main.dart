import 'dart:convert';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/bindings/initial_binding.dart';
import 'package:JIR/config.dart';
import 'package:JIR/pages/notifications/service/device_token.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

const taskName = "floodCheckTask";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final FlutterLocalNotificationsPlugin bgFlutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await bgFlutterLocalNotificationsPlugin
      .initialize(const InitializationSettings(android: android, iOS: ios));

  final notification = message.notification;
  final data = message.data;

  const androidDetails = AndroidNotificationDetails(
    'fcm_channel',
    'FCM Notifications',
    channelDescription: 'Channel for FCM',
    importance: Importance.max,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  await bgFlutterLocalNotificationsPlugin.show(
    message.hashCode,
    notification?.title ?? data['title'],
    notification?.body ?? data['body'],
    details,
    payload: jsonEncode(data),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit));

    if (task == taskName) {
      try {
        final res = await http.get(Uri.parse("$mainUrl/api/flood/data"));
        if (res.statusCode == 200) {
          final decoded = json.decode(res.body);
          final List<dynamic> jsonData = decoded["data"];

          if (jsonData.isNotEmpty) {
            final latest = jsonData.first;

            const androidDetails = AndroidNotificationDetails(
              'flood_channel',
              'Flood Alerts',
              channelDescription: 'Notifikasi banjir otomatis',
              importance: Importance.max,
              priority: Priority.high,
            );
            const iosDetails = DarwinNotificationDetails();
            const notifDetails =
                NotificationDetails(android: androidDetails, iOS: iosDetails);

            await flutterLocalNotificationsPlugin.show(
              0,
              "Update Banjir: ${latest["NAMA_PINTU_AIR"]}",
              "Status: ${latest["STATUS_SIAGA"]} • Tinggi Air: ${latest["TINGGI_AIR"]}",
              notifDetails,
            );
          }
        }
      } catch (e) {
        print("Error fetch flood data: $e");
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('notifications');
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await requestNotificationPermissionsAndInit();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "floodTaskUnique",
    taskName,
    initialDelay: const Duration(seconds: 10),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JIR App',
      theme: ThemeData(),
      initialRoute: AppRoutes.initial,
      initialBinding: InitialBinding(),
      getPages: AppRoutes.getPages,
      navigatorKey: Get.key,
    );
  }
}
