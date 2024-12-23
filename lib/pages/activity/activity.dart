import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aktivitas',
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan Saya',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 296.0,
                height: 210.0,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xffEAEFF3),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: Column(
                  children: [
                    Text(
                      'Jumlah laporan yang dilaporkan oleh pengguna sebanyak',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '0',
                      style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Text(
                      'Jumlah Laporan',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status Laporan',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusIcon(
                    Icons.hourglass_empty, 'Menunggu', Colors.blue),
                _buildStatusIcon(Icons.timelapse, 'Diproses', Colors.orange),
                _buildStatusIcon(Icons.people, 'Koordinasi', Colors.purple),
                _buildStatusIcon(Icons.check_circle, 'Selesai', Colors.green),
                _buildStatusIcon(Icons.cancel, 'Ditolak', Colors.red),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              child: Image.asset('assets/images/line2.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ringkasan Laporan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildLaporanItem(
                    Icons.watch_later,
                    'Laporan Sampah di jalan',
                    'Laporan mengenai tumpukan sampah di jalan utama menunggu proses.',
                    '1 hari yang lalu',
                  ),
                  _buildLaporanItem(
                    Icons.timelapse,
                    'Banjir di Kecamatan X',
                    'Laporan banjir di Kecamatan X sedang dalam tahap penanganan oleh tim lapangan.',
                    '1 hari yang lalu',
                  ),
                  _buildLaporanItem(
                    Icons.group,
                    'Jalan Rusak di desa Y',
                    'Koordinasi sedang dilakukan untuk perbaikan jalan rusak di Desa Y.',
                    '1 hari yang lalu',
                  ),
                  _buildLaporanItem(
                    Icons.check_circle,
                    'Pohon Tumbang di Area Z',
                    'Laporan pohon tumbang di area Z telah berhasil ditangani.',
                    '1 hari yang lalu',
                  ),
                  _buildLaporanItem(
                    Icons.cancel,
                    'Keluhan Drainase Tersumbat',
                    'Laporan ditolak karena informasi kurang lengkap.',
                    '1 hari yang lalu',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28.5,
          backgroundColor: const Color(0xffEAEFF3),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xff304153)),
        ),
      ],
    );
  }

  Widget _buildLaporanItem(
      IconData icon, String title, String description, String timeAgo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xff435482).withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        titleTextStyle: GoogleFonts.inter(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        trailing: Text(
          timeAgo,
          style: GoogleFonts.inter(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
