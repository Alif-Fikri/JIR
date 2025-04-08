import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'dart:math';
import 'package:JIR/helper/voicefrequency.dart';
import 'package:JIR/services/chat_service/chat_api_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with TickerProviderStateMixin {
  bool _isMicTapped = false;
  bool _isChatVisible = true;
  late AnimationController _controllerA;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late stt.SpeechToText _speech;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _simulateInitialMessages();
    _controllerA = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controllerA.dispose();
    super.dispose();
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
        _isChatVisible = false;
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
      _isChatVisible = true;
      if (_recognizedText.isNotEmpty) {
        _messages.add({"text": _recognizedText, "isSender": true});
        _recognizedText = '';
      }
    });
    scrollToBottom();
  }

  Future<void> _sendMessages(String message) async {
    if (message.isEmpty) return;

    try {
      final response = await ChatService.getChatResponse(message);
      setState(() {
        _messages.add({"text": response, "isSender": false});
      });
      scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "Maaf, terjadi kesalahan. Silakan coba lagi.",
          "isSender": false
        });
      });
      scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add({"text": userMessage, "isSender": true});
        _controller.clear();
      });
      _sendMessages(userMessage);
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          if (_isChatVisible)
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.1),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _chatBubble(
                    text: _messages[index]["text"] ?? "",
                    isSender: _messages[index]["isSender"] ?? false,
                  );
                },
              ),
            ),
          Positioned(
            bottom: 0, // Fix to bottom
            left: 0,
            right: 0,
            child: _inputSection(screenWidth),
          ),
          if (_isMicTapped)
            Center(
              child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _controllerA,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: VoiceFrequencyPainter(
                              _controllerA.value * 2 * pi,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      child: Container(
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
                          radius: 50,
                          child: IconButton(
                            icon: Icon(
                              _isMicTapped ? Icons.mic : Icons.mic_none,
                              color: Colors.red,
                              size: 50,
                            ),
                            onPressed:
                                _isMicTapped ? _stopListening : _startListening,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Text(
                        'Mendengarkan...',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ])),
            )
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
                    borderSide: const BorderSide(
                      color: Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0x14000000),
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xffEAEFF3),
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
}
