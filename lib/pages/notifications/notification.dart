import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [
    NotificationModel(
      id: 1,
      icon: 'assets/images/peringatan.png',
      title: 'Peringatan Potensi Banjir di Area Anda',
      message:
          'Hati-hati! Curah hujan tinggi diprediksi pada 14:00 WIB di area Anda. Waspadai genangan air dan cari jalur alternatif.',
      time: '1 hari yang lalu',
    ),
    NotificationModel(
      id: 2,
      icon: 'assets/images/info.png',
      title: 'Peringatan Aksi Demo di Lokasi Terdekat',
      message:
          'Aksi demo besar terdeteksi di sekitar Kantor Gubernur. Hindari area tersebut untuk menghindari kemacetan dan risiko keamanan.',
      time: '1 hari yang lalu',
    ),
    NotificationModel(
      id: 3,
      icon: 'assets/images/suhu.png',
      title: 'Perkiraan Cuaca Hari Ini',
      message:
          'Cuaca hari ini cerah dengan suhu 30°C. Pastikan Anda tetap terhidrasi jika beraktivitas di luar ruangan.',
      time: '1 hari yang lalu',
    ),
  ];

  void _deleteSelected() {
    setState(() {
      notifications.removeWhere((notification) => notification.isChecked);
    });
  }

  void _toggleCheck(int id, bool value) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      notifications[index] = notifications[index].copyWith(isChecked: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed:
                notifications.any((n) => n.isChecked) ? _deleteSelected : null,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: const Color(0xff51669D),
            height: 2.0,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            notification: notification,
            onChecked: (value) => _toggleCheck(notification.id, value),
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

  NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isChecked = false,
  });

  NotificationModel copyWith({
    bool? isChecked,
  }) {
    return NotificationModel(
      id: id,
      icon: icon,
      title: title,
      message: message,
      time: time,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
