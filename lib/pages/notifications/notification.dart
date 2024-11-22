import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Menghilangkan shadow default AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.inter(
            fontSize: 20,
            color: const Color(0xff435482),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              // Tambahkan logika untuk menghapus semua notifikasi
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0), // Ketebalan garis
          child: Container(
            color: const Color(0xff51669D),
            height: 2.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationItem(
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
            title: 'Perkiraan Cuaca Hari Ini',
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
  final String icon;
  final String title;
  final String message;
  final String time;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
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
          // Bagian Icon dan Checkbox
          Column(
            children: [
              Image.asset(
                icon,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 40.0),
              Checkbox(
                value: true,
                activeColor: const Color(0xff435482),
                onChanged: (value) {
                  // Tambahkan logika untuk checkbox
                },
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Bagian Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Notifikasi
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // Pesan Notifikasi
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                // Spasi tambahan untuk memastikan waktu tetap di bawah
                const SizedBox(height: 12),

                // Waktu Notifikasi
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
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
