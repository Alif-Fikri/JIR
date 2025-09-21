import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:JIR/config.dart';
import 'package:http/http.dart' as http;

const String floodTaskName = "floodCheckTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(callbackHandler);
}

@pragma('vm:entry-point')
Future<bool> callbackHandler(
    String task, Map<String, dynamic>? inputData) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final ios = DarwinInitializationSettings();
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(android: android, iOS: ios),
  );

  if (task == floodTaskName) {
    try {
      final res = await http.get(Uri.parse("$mainUrl/api/flood/data"));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> jsonData = decoded["data"] ?? [];
        if (jsonData.isNotEmpty) {
          final latest = jsonData.first;
          final androidDetails = AndroidNotificationDetails(
            'flood_channel',
            'Flood Alerts',
            channelDescription: 'Notifikasi banjir otomatis',
            importance: Importance.max,
            priority: Priority.high,
          );
          final iosDetails = DarwinNotificationDetails();
          final notifDetails =
              NotificationDetails(android: androidDetails, iOS: iosDetails);

          final title =
              "Update Banjir: ${latest["NAMA_PINTU_AIR"] ?? 'Lokasi'}";
          final body =
              "Status: ${latest["STATUS_SIAGA"] ?? '-'} • Tinggi Air: ${latest["TINGGI_AIR"] ?? '-'}";

          await flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title,
            body,
            notifDetails,
          );
        }
      }
    } catch (e) {
      print('Workmanager flood task error: $e');
    }
  }

  return Future.value(true);
}
