import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/chat/chatbot_text.dart';

class ChatbotOpeningPage extends StatelessWidget {
  const ChatbotOpeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/close_icon.png',
            width: screenWidth * 0.04,
            height: screenHeight * 0.04,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: screenHeight * 0.20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 1.0,
                  maxHeight: screenHeight * 1.0,
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
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2A3342),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/suki.png',
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.3,
                      ),
                    ],
                  ),
                  Text(
                    "Asisten anda untuk \nmendeteksi banjir \ndan kerumunan",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * 0.05,
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
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.03,
                      ),
                    ),
                    child: Text(
                      "Start New Chat",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
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
                      size: screenWidth * 0.06,
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
