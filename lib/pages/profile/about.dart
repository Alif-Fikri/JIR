import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tentang Kami'),
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
            _buildImageHeader(),
            const SizedBox(height: 20),
            _buildTitle("Tentang JIR"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Aplikasi JIR adalah platform inovatif yang dikembangkan untuk membantu masyarakat dalam pemantauan bencana dan kondisi lingkungan sekitar. JIR hadir dengan tujuan utama untuk meningkatkan kesadaran dan respons terhadap ancaman banjir, kerumunan berlebih, dan kebakaran melalui sistem pemantauan real-time.\n"
              "Dengan menggabungkan teknologi canggih seperti analisis data, pemantauan CCTV publik, dan laporan berbasis pengguna, JIR bertujuan untuk menyediakan informasi yang cepat dan akurat bagi warga, petugas keamanan, serta pemerintah daerah.",
            ),
            const SizedBox(height: 20),
            _buildTitle("Visi & Misi"),
            const SizedBox(height: 15),
            _buildParagraph(
              "Visi kami adalah menjadi platform pemantauan lingkungan yang andal dan berbasis teknologi guna menciptakan komunitas yang lebih aman dan tanggap terhadap bencana.",
            ),
            const SizedBox(height: 10),
            _buildSubtitle("Misi kami:"),
            _buildParagraph(
              "• Menyediakan informasi terkini mengenai potensi bencana dan kondisi lingkungan.\n"
              "• Membantu masyarakat dalam melaporkan kejadian penting seperti banjir dan kebakaran.\n"
              "• Memanfaatkan teknologi pemantauan untuk meningkatkan keselamatan publik.\n"
              "• Berkolaborasi dengan pemerintah dan lembaga terkait dalam pengelolaan bencana.",
            ),
            const SizedBox(height: 20),
            _buildParagraph(
              "Kami terus berinovasi dan mengembangkan fitur-fitur baru agar aplikasi JIR dapat memberikan manfaat yang lebih besar bagi penggunanya. Dengan menggunakan aplikasi ini, Anda turut serta dalam membangun sistem tanggap darurat yang lebih baik untuk masyarakat.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/afternoon.png'),
          fit: BoxFit.cover,
        ),
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
