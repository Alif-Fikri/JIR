import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isNotificationPageEnabled = true;

  void toggleNotificationPage() {
    setState(() {
      isNotificationPageEnabled = !isNotificationPageEnabled;
    });
  }

  Widget NotificationPageCard(
      IconData icon, String title, String message, String timeAgo) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    message,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeAgo,
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add back navigation
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
                isNotificationPageEnabled ? Icons.toggle_on : Icons.toggle_off,
                color: isNotificationPageEnabled ? Colors.orange : Colors.grey),
            onPressed: toggleNotificationPage,
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          NotificationPageCard(
            Icons.warning,
            'Peringatan Potensi Banjir di Area Anda',
            'Hati-hati! Curah hujan tinggi diprediksi pada 14:00 WIB di area Anda. Waspadai genangan air dan cari jalur alternatif.',
            '1 hari yang lalu',
          ),
          NotificationPageCard(
            Icons.warning,
            'Peringatan Aksi Demo di Lokasi Terdekat',
            'Aksi demo besar terdeteksi di sekitar Kantor Gubernur. Hindari area tersebut untuk menghindari kemacetan dan risiko keamanan.',
            '1 hari yang lalu',
          ),
          NotificationPageCard(
            Icons.info,
            'Nikmati Udara Segar di Taman Hijau',
            'Cuaca cerah hari ini. Kunjungi Taman Kota di dekat Anda untuk berolahraga atau bersantai.',
            '1 hari yang lalu',
          ),
          NotificationPageCard(
            Icons.thermostat,
            'Prakiraan Cuaca Hari Ini',
            'Cuaca hari ini cerah dengan suhu 30°C. Pastikan Anda tetap terhidrasi jika beraktivitas di luar ruangan.',
            '1 hari yang lalu',
          ),
        ],
      ),
    );
  }
}
