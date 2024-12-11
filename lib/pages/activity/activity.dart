import 'package:flutter/material.dart';

class AktivitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aktivitas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Laporan Saya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Jumlah laporan yang dilaporkan oleh pengguna sebanyak',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '0',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      'Jumlah Laporan',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Status Laporan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusIcon(Icons.hourglass_empty, 'Menunggu', Colors.blue),
                _buildStatusIcon(Icons.timelapse, 'Diproses', Colors.orange),
                _buildStatusIcon(Icons.people, 'Koordinasi', Colors.purple),
                _buildStatusIcon(Icons.check_circle, 'Selesai', Colors.green),
                _buildStatusIcon(Icons.cancel, 'Ditolak', Colors.red),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Ringkasan Laporan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Aktivitas'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 28, color: color),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLaporanItem(IconData icon, String title, String description, String timeAgo) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          timeAgo,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
