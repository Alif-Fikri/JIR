import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;
  Box<dynamic>? _box;
  ValueListenable? _listen;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    _box = Hive.box('notifications');
    _loadFromBox();

    _listen = _box!.listenable(keys: ['list']);
    (_listen as ValueListenable).addListener(_onBoxChanged);
    debugPrint(
        '[NotificationController] initialized; items=${notifications.length}');
  }

  void _onBoxChanged() {
    _loadFromBox();
    debugPrint(
        '[NotificationController] box changed; items=${notifications.length}');
  }

  void _loadFromBox() {
    try {
      final raw = _box!.get('list', defaultValue: []);
      final list = List.from(raw);
      final mapped = list.map<Map<String, dynamic>>((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        if (e is String) {
          try {
            return Map<String, dynamic>.from(e.isNotEmpty ? {} : {});
          } catch (_) {
            return <String, dynamic>{};
          }
        }
        return Map<String, dynamic>.from({});
      }).toList();
      notifications.assignAll(mapped);
    } catch (e, st) {
      debugPrint('[NotificationController] load error: $e\n$st');
      notifications.clear();
    }
  }

  List<Map<String, dynamic>> get warnings {
    return notifications.where((n) {
      final t = (n['type'] ?? '').toString().toLowerCase();
      final title = (n['title'] ?? '').toString().toLowerCase();
      final msg = (n['message'] ?? '').toString().toLowerCase();
      if (t.isNotEmpty) {
        return t.contains('flood') ||
            t.contains('warning') ||
            t.contains('alert') ||
            t.contains('peringatan');
      }

      return title.contains('banjir') ||
          title.contains('peringatan') ||
          msg.contains('banjir') ||
          msg.contains('peringatan');
    }).toList();
  }

  void dumpBox() {
    debugPrint(
        '[NotificationController] hive list: ${_box?.get('list', defaultValue: [])}');
  }

  @override
  void onClose() {
    try {
      (_listen as ValueListenable).removeListener(_onBoxChanged);
    } catch (_) {}
    super.onClose();
  }
}
