import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  bool _isMicTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xff45557B)),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(32.0),
                  children: [
                    _chatBubble(
                      text:
                          "Hallo Zee, aku Suki asisten anda untuk memantau banjir dan kerumunan",
                      isSender: false,
                    ),
                    _chatBubble(
                      text: "Ingin tahu kondisi di area tertentu?",
                      isSender: false,
                    ),
                    _chatBubble(
                      text: "Update kondisi dijalan xxxxxx",
                      isSender: true,
                    )
                  ],
                ),
              ),
              _inputSection(),
            ],
          ),
          if (_isMicTapped) _buildMicOverlay(),
        ],
      ),
    );
  }

  Widget _chatBubble({required String text, required bool isSender}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSender ? Color(0xffE45835) : Color(0xff45557B),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _inputSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ketik pesan anda...",
                hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: Color(0xffEAEFF3),
            radius: 24,
            child: IconButton(
              icon: Icon(Icons.mic, color: Colors.red),
              onPressed: () {
                setState(() {
                  _isMicTapped = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicOverlay() {
    return OpenContainer(
      openBuilder: (context, _) {
        return Scaffold(
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Icon(Icons.mic, size: 100, color: Colors.white),
              ),
            ),
          ),
        );
      },
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      onClosed: (_) {
        setState(() {
          _isMicTapped = false;
        });
      },
      closedBuilder: (context, openContainer) => Container(),
    );
  }
}
