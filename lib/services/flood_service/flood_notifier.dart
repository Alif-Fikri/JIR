import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:JIR/services/flood_service/flood_api_service.dart';
import 'package:flutter/foundation.dart';

const String kFloodSnapshotKey = 'flood_last_snapshot';
final FlutterLocalNotificationsPlugin localNotif = FlutterLocalNotificationsPlugin();

class FloodNotifier {
  static Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await localNotif.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  static Future<void> checkNow() async {
    try {
      final FloodService service = FloodService();
      final List<Map<String, dynamic>> remoteList = await service.fetchFloodData();

      if (remoteList.isEmpty) {
        debugPrint('FloodNotifier: remoteList kosong');
        return;
      }

      final box = Hive.box('notifications'); 
      final String? snapshotJson = box.get(kFloodSnapshotKey) as String?;
      Map<String, dynamic> lastSnapshot = {};
      if (snapshotJson != null && snapshotJson.isNotEmpty) {
        try {
          lastSnapshot = json.decode(snapshotJson) as Map<String, dynamic>;
        } catch (_) {
          lastSnapshot = {};
        }
      }

      Map<String, Map<String, dynamic>> currentMap = {};
      for (final item in remoteList) {
        final key = _makeKey(item);
        currentMap[key] = item;
      }

      final List<_DetectResult> detectResults = [];

      for (final entry in currentMap.entries) {
        final key = entry.key;
        final item = entry.value;
        final prev = lastSnapshot[key];

        if (prev == null) {
          detectResults.add(_DetectResult(key: key, item: item, type: _ChangeType.newItem));
        } else {
          final prevHeight = (prev['TINGGI_AIR'] ?? prev['TINGGI_AIR_SEBELUMNYA'] ?? '').toString();
          final currHeight = (item['TINGGI_AIR'] ?? item['TINGGI_AIR_SEBELUMNYA'] ?? '').toString();
          final prevStatus = (prev['STATUS_SIAGA'] ?? '').toString();
          final currStatus = (item['STATUS_SIAGA'] ?? '').toString();
          final prevTanggal = (prev['TANGGAL'] ?? '').toString();
          final currTanggal = (item['TANGGAL'] ?? '').toString();

          if (prevHeight != currHeight || prevStatus != currStatus || prevTanggal != currTanggal) {
            detectResults.add(_DetectResult(key: key, item: item, type: _ChangeType.updated));
          }
        }
      }

      for (final r in detectResults) {
        final title = r.type == _ChangeType.newItem ? 'Banjir baru: ${_displayName(r.item)}' : 'Update banjir: ${_displayName(r.item)}';
        final body = _buildBody(r.item, changeType: r.type == _ChangeType.newItem ? 'Baru' : 'Update');
        await _showLocalNotification(title: title, body: body);   
        await _saveToNotificationsBox(r.item, r.type);
      }

      final Map<String, dynamic> toSave = {};
      currentMap.forEach((k, v) => toSave[k] = v);
      await box.put(kFloodSnapshotKey, json.encode(toSave));
      debugPrint('FloodNotifier: selesai. changes=${detectResults.length}');
    } catch (e, st) {
      debugPrint('FloodNotifier.checkNow error: $e\n$st');
    }
  }

  static Future<void> _showLocalNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'flood_channel_id',
      'Flood Alerts',
      channelDescription: 'Channel untuk notifikasi banjir',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final platform = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await localNotif.show(id, title, body, platform, payload: json.encode({'type': 'flood'}));
  }

  static Future<void> _saveToNotificationsBox(Map<String, dynamic> item, _ChangeType type) async {
    final box = Hive.box('notifications');
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch ~/ 1000;
    final timeStr = DateFormat('dd MMM yyyy HH:mm').format(now);
    final title = (type == _ChangeType.newItem ? 'Banjir baru: ' : 'Update banjir: ') + (_displayName(item));
    final body = _buildBody(item, changeType: type == _ChangeType.newItem ? 'Baru' : 'Update');
    final icon = 'assets/images/peringatan.png';
    final itemToSave = {
      'id': id,
      'icon': icon,
      'title': title,
      'message': body,
      'time': timeStr,
      'isChecked': false,
      'raw': item,
    };
    await box.put(id.toString(), itemToSave);
  }

  static String _makeKey(Map<String, dynamic> item) {
    final name = (item['NAMA_PINTU_AIR'] ?? item['LOKASI'] ?? '').toString();
    final lat = item['LATITUDE']?.toString() ?? '';
    final lon = item['LONGITUDE']?.toString() ?? '';
    return '$name|$lat|$lon';
  }

  static String _displayName(Map<String, dynamic> item) {
    return (item['NAMA_PINTU_AIR'] ?? item['LOKASI'] ?? 'Lokasi tidak dikenal').toString();
  }

  static String _buildBody(Map<String, dynamic> item, {String changeType = 'Update'}) {
    final level = item['STATUS_SIAGA'] ?? item['TINGGI_AIR'] ?? '';
    final tanggal = item['TANGGAL'] ?? '';
    return '$changeType • ${level.toString()} • ${tanggal.toString()}';
  }
}

enum _ChangeType { newItem, updated }

class _DetectResult {
  final String key;
  final Map<String, dynamic> item;
  final _ChangeType type;
  _DetectResult({required this.key, required this.item, required this.type});
}
