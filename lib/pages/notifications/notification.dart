import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              // Tambahkan logika untuk menghapus semua notifikasi
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          const NotificationItem(
            icon: 'assets/images/peringatan.png',
            title: 'Peringatan Potensi Banjir di Area Anda',
            message:
                'Hati-hati! Curah hujan tinggi diprediksi pada 14:00 WIB di area Anda. Waspadai genangan air dan cari jalur alternatif.',
            time: '1 hari yang lalu',
          ),
          NotificationItem(
            icon: 'assets/images/info.png',
            title: 'Peringatan Aksi Demo di Lokasi Terdekat',
            message:
                'Aksi demo besar terdeteksi di sekitar Kantor Gubernur. Hindari area tersebut untuk menghindari kemacetan dan risiko keamanan.',
            time: '1 hari yang lalu',
          ),
          NotificationItem(
            icon: 'assets/images/suhu.png',
            title: 'Prakiraan Cuaca Hari Ini',
            message:
                'Cuaca hari ini cerah dengan suhu 30°C. Pastikan Anda tetap terhidrasi jika beraktivitas di luar ruangan.',
            time: '1 hari yang lalu',
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String icon; // Path ke gambar
  final String title;
  final String message;
  final String time;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar kustom sebagai ikon
          Image.asset(
            icon, // Path gambar
            width: 40,
            height: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (value) {
              // Tambahkan logika untuk checkbox
            },
          ),
        ],
      ),
    );
  }
}
