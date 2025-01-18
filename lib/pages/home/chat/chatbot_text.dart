import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  bool _isMicTapped = false;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Hallo Zee, aku Suki asisten anda untuk memantau banjir dan kerumunan",
      "isSender": false
    },
    {"text": "Ingin tahu kondisi di area tertentu?", "isSender": false},
    {"text": "Update kondisi dijalan xxxxxx", "isSender": true},
  ];

  late stt.SpeechToText _speech;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _simulateInitialMessages();
  }

  void _simulateInitialMessages() async {
    final List<Map<String, dynamic>> initialMessages = [
      {
        "text":
            "Hallo Zee, aku Suki asisten anda untuk memantau banjir dan kerumunan",
        "isSender": false
      },
      {"text": "Ingin tahu kondisi di area tertentu?", "isSender": false},
    ];

    for (final message in initialMessages) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _messages.add(message);
      });
    }
  }
  void _startListening() async {
  bool available = await _speech.initialize(
    onStatus: (status) => print('Status: $status'),
    onError: (error) => print('Error: $error'),
  );

  if (available) {
    setState(() {
      _isMicTapped = true;
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );
  }
}

void _stopListening() {
  _speech.stop();
  setState(() {
    _isMicTapped = false;
    if (_recognizedText.isNotEmpty) {
      _messages.add({"text": _recognizedText, "isSender": true});
      _recognizedText = '';
    }
  });
}


  Future<void> _fetchGeminiData(String query) async {
    const String apiUrl = 'https://api.gemini.com/v1/location';
    const String apiKey = 'AIzaSyAQsq3vyPq0KBY2VNK64_z050HC-g1GhgQ';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"query": query}),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        setState(() {
          _messages.add({"text": data, "isSender": false});
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _messages.add(
              {"text": "Error: ${response.reasonPhrase}", "isSender": false});
        });
      }
    } catch (e) {
      print('Exception caught: $e');
      setState(() {
        _messages.add({"text": "Failed to fetch data: $e", "isSender": false});
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add({"text": userMessage, "isSender": true});
        _controller.clear();
      });
      _fetchGeminiData(userMessage);
    }
  }

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
            top: 150,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _chatBubble(
                      text: _messages[index]["text"],
                      isSender: _messages[index]["isSender"],
                    );
                  },
                ),
              ),
              _inputSection(screenWidth),
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
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xffE45835) : const Color(0xff45557B),
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

  Widget _inputSection(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffEAEFF3),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.04,
                  color: const Color(0xFF435482),
                ),
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF435482),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: const Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: const Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: const Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Color(0xffEAEFF3),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xffE45835)),
                    onPressed: _sendMessage,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: const Color(0xffEAEFF3),
    border: Border.all(
      color: const Color(0x14000000),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: CircleAvatar(
    backgroundColor: Colors.transparent,
    radius: 24,
    child: IconButton(
      icon: Icon(
        _isMicTapped ? Icons.mic : Icons.mic_none,
        color: Colors.red,
      ),
      onPressed: _isMicTapped ? _stopListening : _startListening,
    ),
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
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(50.0),
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
