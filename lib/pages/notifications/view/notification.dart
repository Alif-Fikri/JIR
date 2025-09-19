import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Box box;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen('notifications')) {
      await Hive.openBox('notifications');
    }
    box = Hive.box('notifications');
    setState(() {
      _ready = true;
    });
  }

  Future<void> _saveList(List list) async {
    await box.put('list', list);
  }

  Future<void> _deleteItem(List<Map> currentList, int id) async {
    final idx = currentList.indexWhere((m) => m['id'] == id);
    if (idx == -1) return;
    final removed = currentList.removeAt(idx);
    await _saveList(currentList);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifikasi dihapus'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            currentList.insert(idx, removed);
            await _saveList(currentList);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final box = Hive.box('notifications');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifikasi',
            style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: const Color(0xff51669D), height: 2.0),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(keys: ['list']),
        builder: (context, _, __) {
          final rawList = List<Map>.from(box.get('list', defaultValue: []));
          if (rawList.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rawList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = Map<String, dynamic>.from(rawList[index]);
              final notification = NotificationModel.fromMap(m);
              return Dismissible(
                key: ValueKey(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteItem(rawList, notification.id),
                child: NotificationItem(
                  notification: notification,
                ),
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

  const NotificationItem({
    super.key,
    required this.notification,
  });

  String _friendlyTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {}
    try {
      final ms = int.parse(raw);
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {}
    return raw;
  }

  String _resolveIconAsset() {
    final provided = (notification.icon).trim();
    if (provided.isNotEmpty) return provided;
    final Map<String, dynamic>? raw = notification.raw;
    final typ = (raw != null && raw['type'] != null)
        ? raw['type'].toString().toLowerCase()
        : '';
    if (typ.contains('flood') ||
        typ.contains('banjir') ||
        typ.contains('peringatan')) {
      return 'assets/images/peringatan.png';
    }
    if (typ.contains('weather') ||
        typ.contains('cuaca') ||
        typ.contains('suhu')) {
      return 'assets/images/suhu.png';
    }
    if (typ.contains('report') || typ.contains('laporan')) {
      return 'assets/images/laporan.png';
    }
    return 'assets/images/ic_launcher.png';
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _friendlyTime(notification.time);
    final iconAsset = _resolveIconAsset();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 72, 12),
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
                const SizedBox(height: 8),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: _buildIconWidget(iconAsset),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 8,
            child: Text(
              timeStr,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWidget(String asset) {
    if (asset.startsWith('http')) {
      return Image.network(asset, width: 40, height: 40, fit: BoxFit.contain);
    }
    return Image.asset(asset, width: 40, height: 40, fit: BoxFit.contain);
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
    final idVal = m['id'];
    final idComputed = idVal is int
        ? idVal
        : (int.tryParse(idVal.toString()) ??
            DateTime.now().millisecondsSinceEpoch);
    final timeVal = (m['time'] as String?) ?? '';
    return NotificationModel(
      id: idComputed,
      icon: (m['icon'] as String?) ?? '',
      title: (m['title'] as String?) ?? '',
      message: (m['message'] as String?) ?? '',
      time: timeVal,
      isChecked: m['isChecked'] == true,
      raw: m['raw'] is Map ? Map<String, dynamic>.from(m['raw']) : null,
    );
  }
}
