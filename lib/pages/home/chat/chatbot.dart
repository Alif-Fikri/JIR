import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcitys/pages/home/chat/chatbot_text.dart';

class ChatbotOpeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Color(0xff45557B), size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            // Content
            Expanded(
              child: Stack(
                children: [
                  // Single Image Asset
                  Center(
                    child: Image.asset(
                      'assets/images/bg1.png',
                      width: 300,
                      height: 300,
                    ),
                  ),
                  Column(
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
                              color: Color(0xff2A3342),
                            ),
                          ),
                          SizedBox(height: 10),
                          Image.asset(
                            'assets/images/suki.png',
                            width: 150.0,
                            height: 150.0,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Subtitle text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Asisten anda untuk \nmendeteksi banjir \ndan kerumunan",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Color(0xff2A3342),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Start New Chat button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatBotPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff45557B),
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
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: () {
                  // Handle microphone input
                },
                backgroundColor: Color(0xffEAEFF3),
                child: Icon(
                  Icons.mic,
                  size: 30,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
