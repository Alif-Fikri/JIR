import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Box box;

  @override
  void initState() {
    super.initState();
    if (!Hive.isBoxOpen('notifications')) {
      Hive.openBox('notifications').then((b) {
        setState(() { box = b; });
      });
    } else {
      box = Hive.box('notifications');
    }
  }

  Future<void> _saveList(List list) async {
    await box.put('list', list);
  }

  void _deleteSelected(List<Map> currentList) async {
    final filtered = currentList.where((m) => m['isChecked'] != true).toList();
    await _saveList(filtered);
  }

  void _toggleCheckItem(List<Map> currentList, int id, bool value) async {
    final idx = currentList.indexWhere((m) => m['id'] == id);
    if (idx != -1) {
      currentList[idx]['isChecked'] = value;
      await _saveList(currentList);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('notifications')) {
      return const Center(child: CircularProgressIndicator());
    }
    final box = Hive.box('notifications');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifikasi', style: GoogleFonts.inter(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder(
            valueListenable: box.listenable(keys: ['list']),
            builder: (context, _, __) {
              final list = List<Map>.from(box.get('list', defaultValue: []));
              final anyChecked = list.any((m) => m['isChecked'] == true);
              return IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: anyChecked ? () => _deleteSelected(list) : null,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: const Color(0xff51669D), height: 2.0),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['list']),
        builder: (context, _, __) {
          final list = List<Map>.from(box.get('list', defaultValue: []));
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final m = Map<String, dynamic>.from(list[index]);
              final notification = NotificationModel.fromMap(m);
              return NotificationItem(
                notification: notification,
                onChecked: (value) => _toggleCheckItem(list, notification.id, value),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final ValueChanged<bool> onChecked;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff435482).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Image.asset(
                notification.icon,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 40.0),
              Checkbox(
                value: notification.isChecked,
                activeColor: const Color(0xff435482),
                onChanged: (value) => onChecked(value ?? false),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationModel {
  final int id;
  final String icon;
  final String title;
  final String message;
  final String time;
  final bool isChecked;
  final Map<String, dynamic>? raw;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isChecked = false,
    this.raw,
  });

  NotificationModel copyWith({bool? isChecked}) {
    return NotificationModel(
      id: id,
      icon: icon,
      title: title,
      message: message,
      time: time,
      isChecked: isChecked ?? this.isChecked,
      raw: raw,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'message': message,
      'time': time,
      'isChecked': isChecked,
      'raw': raw ?? {},
    };
  }

  factory NotificationModel.fromMap(Map m) {
    return NotificationModel(
      id: m['id'] is int ? m['id'] : int.tryParse(m['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
      icon: (m['icon'] as String?) ?? 'assets/images/jir_logo3.png',
      title: (m['title'] as String?) ?? '',
      message: (m['message'] as String?) ?? '',
      time: (m['time'] as String?) ?? '',
      isChecked: m['isChecked'] == true,
      raw: m['raw'] is Map ? Map<String, dynamic>.from(m['raw']) : {},
    );
  }
}
