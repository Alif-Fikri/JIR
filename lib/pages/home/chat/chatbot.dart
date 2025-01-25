import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/chat/chatbot_text.dart';

class ChatbotOpeningPage extends StatelessWidget {
  const ChatbotOpeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/close_icon.png',
            width: 17,
            height: 17,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 700,
                  maxHeight: 350,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg1.png'),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "Hallo\nAku Suki",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2A3342),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/suki.png',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  Text(
                    "Asisten anda untuk \nmendeteksi banjir \ndan kerumunan",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: const Color(0xff2A3342),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatBotPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff45557B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Start New Chat",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: const Color(0xffEAEFF3),
                    child: Icon(
                      Icons.mic,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
