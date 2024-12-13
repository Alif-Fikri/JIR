import 'package:flutter/material.dart';

class ChatbotOpeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.blueGrey, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Blue decorative circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Hallo\nAku Suki",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(height: 10),
                          Image.asset(
                            'assets/images/chatbot.png', // Replace with the path to your chatbot image
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Subtitle text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Asisten anda untuk mendeteksi banjir dan kerumunan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Start New Chat button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to chatbot screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Start New Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Microphone button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton(
                onPressed: () {
                  // Handle microphone input
                },
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.mic,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
