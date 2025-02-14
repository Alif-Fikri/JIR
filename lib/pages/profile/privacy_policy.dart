import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff45557B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            _buildTitle("Kebijakan Privasi JIR"),
            const SizedBox(height: 15),
            _buildUpdate("Terakhir diperbarui: 12 Januari 2025"),
            const SizedBox(height: 20),
            _buildParagraph(
              "Selamat datang di aplikasi JIR. Kami menghormati privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, mengungkapkan, dan melindungi informasi Anda saat menggunakan aplikasi JIR.",
            ),
            const SizedBox(height: 20),
            _buildTitle("1. INFORMASI YANG KAMI KUMPULKAN"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Kami dapat mengumpulkan informasi berikut untuk menyediakan layanan yang lebih baik:\n"
              "• Informasi Pribadi. Nama, email, nomor telepon, dan informasi lainnya yang Anda berikan secara langsung.\n"
              "• Data Lokasi. Untuk memantau dan memberikan informasi terkait banjir, kerumunan, dan kebakaran secara akurat, aplikasi JIR dapat mengakses lokasi Anda.\n"
              "• Informasi Perangkat. Tipe perangkat, sistem operasi, dan data teknis lainnya.\n"
              "• Data Penggunaan. Informasi tentang bagaimana Anda menggunakan aplikasi, seperti fitur yang sering digunakan.",
            ),
            const SizedBox(height: 20),
            _buildSubtitle("2. PENGGUNAAN INFORMASI"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Kami tidak akan menjual atau membagikan informasi pribadi Anda kepada pihak ketiga. Kami menggunakan informasi yang dikumpulkan untuk:\n"
              "• Menyediakan layanan pemantauan banjir, kerumunan, dan kebakaran.\n"
              "• Memproses dan menindaklanjuti laporan yang Anda kirimkan.\n"
              "• Meningkatkan pengalaman pengguna dengan pengembangan fitur yang lebih baik.\n"
              "• Mematuhi ketentuan hukum yang berlaku.",
            ),
            const SizedBox(height: 20),
            _buildSubtitle("3. KEAMANAN DATA"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Kami menerapkan langkah-langkah keamanan yang sesuai untuk melindungi data Anda dari akses tidak sah, perubahan, atau pengungkapan yang tidak diizinkan. Anda memiliki hak untuk:\n"
              "• Mengakses, memperbarui, atau menghapus data pribadi Anda.\n"
              "• Menonaktifkan akses lokasi kapan saja melalui pengaturan perangkat Anda.\n"
              "• Menarik persetujuan penggunaan data kapan saja.",
            ),
            const SizedBox(height: 20),
            _buildTitle("4. Hubungi Kami"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Jika Anda memiliki pertanyaan atau permintaan terkait kebijakan privasi ini, silakan hubungi kami di:\n"
              "Email: aduanjaki@gmail.com\n"
              "Telepon: 11111222\n"
              "Alamat: Mercu Buana",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdate(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        color: Colors.black,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.5,
          color: Colors.black,
          fontWeight: FontWeight.w300),
      textAlign: TextAlign.justify,
    );
  }
}
