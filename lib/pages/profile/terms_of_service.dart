import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Layanan'),
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
            _buildTitle("Syarat dan Ketentuan Layanan Penggunaan JIR"),
            const SizedBox(height: 15),
            _buildUpdate("Terakhir diperbarui: 12 Januari 2025"),
            const SizedBox(height: 20),
            _buildParagraph(
              "Dengan menggunakan aplikasi JIR, Anda setuju untuk mematuhi syarat dan ketentuan berikut:",
            ),
            const SizedBox(height: 20),
            _buildTitle("1. PENGGUNAAN LAYANAN"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Kami dapat mengumpulkan informasi berikut untuk menyediakan layanan yang lebih baik:\n"
              "• Aplikasi JIR hanya boleh digunakan untuk tujuan pemantauan banjir, kerumunan, dan kebakaran.\n"
              "• Pengguna dilarang menyalahgunakan layanan untuk tujuan yang melanggar hukum atau mengganggu keamanan publik.",
            ),
            const SizedBox(height: 20),
            _buildSubtitle("2. HAK DAN KEWAJIBAN PENGGUNA"),
            const SizedBox(height: 15),
            _buildParagraph(
              "• Pengguna bertanggung jawab atas kebenaran data yang diberikan.\n"
              "• Pengguna wajib menjaga kerahasiaan akun dan kata sandi mereka.\n"
              "• Pengguna dilarang mengunggah konten yang melanggar hukum atau hak pihak ketiga.",
            ),
            const SizedBox(height: 20),
            _buildSubtitle("3. BATASAN TANGGUNG JAWAB"),
            const SizedBox(height: 15),
            _buildParagraph(
              "• Aplikasi JIR tidak bertanggung jawab atas kesalahan data atau keterlambatan informasi dari pihak ketiga.\n"
              "• Kami tidak bertanggung jawab atas kehilangan atau kerusakan yang diakibatkan oleh penggunaan aplikasi ini.",
            ),
            const SizedBox(height: 20),
            _buildTitle("4. PENGHENTIAN LAYANAN"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Kami berhak menghentikan akses pengguna yang melanggar kebijakan ini tanpa pemberitahuan sebelumnya.",
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
