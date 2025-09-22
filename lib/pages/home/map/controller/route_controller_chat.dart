import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:JIR/helper/voicefrequency.dart';
import 'package:JIR/services/chat_service/chat_api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:JIR/pages/home/map/view/map_monitoring.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
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
    _flutterTts.stop();
    try {
      _speech.stop();
    } catch (_) {}
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
        _recognizedText = '';
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    } else {
      Get.snackbar('Microphone', 'Microphone tidak tersedia');
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isMicTapped = false;
      _isChatVisible = true;
    });

    final text = _recognizedText.trim();
    _recognizedText = '';
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"text": text, "isSender": true});
      });
      scrollToBottom();
      await _sendMessages(text);
    } else {
      scrollToBottom();
    }
  }

  Future<void> _sendMessages(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
          {"text": "sedang mengetik...", "isSender": false, "isTyping": true});
    });
    scrollToBottom();

    dynamic resp;
    try {
      resp = await ChatService.getChatResponse(message);
    } catch (e) {
      resp = null;
    }

    final typingIdx = _messages.indexWhere((m) => m['isTyping'] == true);
    if (typingIdx != -1) {
      setState(() {
        _messages.removeAt(typingIdx);
      });
    }

    final Map<String, dynamic>? routeData = _extractRouteData(resp);
    final String botText = _formatBotTextFromResponse(resp, routeData);

    if (routeData != null) {
      final messageEntry = {
        "text": botText,
        "isSender": false,
        "route": routeData,
      };
      setState(() {
        _messages.add(messageEntry);
      });
    } else {
      setState(() {
        _messages.add({"text": botText, "isSender": false});
      });
    }

    scrollToBottom();

    try {
      await _flutterTts.speak(botText);
    } catch (e) {
    }
  }

  String _formatBotTextFromResponse(dynamic resp, Map<String, dynamic>? routeData) {
    if (resp == null) return 'Maaf, server tidak merespon.';

    try {
      if (resp is Map<String, dynamic>) {
        if (resp.containsKey('data') && resp['data'] is Map) {
          final d = resp['data'] as Map;
          if (d['message'] != null) return d['message'].toString();
          if (d['respons'] != null && d['respons'] is Map && d['respons']['message'] != null) {
            return d['respons']['message'].toString();
          }
        }
        if (resp.containsKey('response')) {
          final r = resp['response'];
          if (r is String && r.isNotEmpty) return r;
          if (r is Map && r['message'] != null) return r['message'].toString();
        }
        if (resp.containsKey('reply')) return resp['reply'].toString();

        if (routeData != null) {
          String startName = _extractPlaceName(routeData['start']);
          String endName = _extractPlaceName(routeData['end']);
          if (startName.isNotEmpty && endName.isNotEmpty) {
            return 'Rute dari $startName ke $endName berhasil dibuat';
          }
          if (routeData['data_message'] != null) {
            return routeData['data_message'].toString();
          }
          if (resp['data'] is Map && (resp['data']['message'] ?? resp['data']['msg']) != null) {
            return (resp['data']['message'] ?? resp['data']['msg']).toString();
          }
          return 'Rute berhasil dibuat. Ketuk preview untuk membuka peta';
        }

        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) return '${singleLine.substring(0, 180)}...';
        return singleLine;
      } else {
        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) return '${singleLine.substring(0, 180)}...';
        return singleLine;
      }
    } catch (e) {
      return 'Balasan diterima. Ketuk preview untuk melihat rute jika tersedia.';
    }
  }

  String _extractPlaceName(dynamic node) {
    try {
      if (node == null) return '';
      if (node is Map) {
        if (node['place'] != null) return node['place'].toString();
        if (node['name'] != null) return node['name'].toString();
        if (node['display_name'] != null) return node['display_name'].toString();
        if (node['label'] != null) return node['label'].toString();
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic>? _extractRouteData(dynamic resp) {
    if (resp is Map<String, dynamic>) {
      if (resp.containsKey('start') && resp.containsKey('end')) {
        return resp;
      }
      if (resp.containsKey('route')) {
        return resp;
      }
      if (resp.containsKey('data') && resp['data'] is Map) {
        final d = resp['data'] as Map;
        if (d.containsKey('start') && d.containsKey('end')) {
          return Map<String, dynamic>.from(d);
        }
        if (d.containsKey('route')) return Map<String, dynamic>.from(d);
      }
    }
    return null;
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll_controller_has_clients()) {
        _scroll_controller_animateToEnd();
      }
    });
  }

  bool _scroll_controller_has_clients() => _scrollController.hasClients;
  double _scroll_controller_max() => _scrollController.position.maxScrollExtent;
  void _scroll_controller_animateToEnd() {
    _scrollController.animateTo(
      _scroll_controller_max(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({"text": text, "isSender": true});
      _controller.clear();
    });
    scrollToBottom();
    _sendMessages(text);
  }

  Future<void> _openRouteInMap(Map<String, dynamic> routeData) async {
    try {
      if (Get.isRegistered<RouteController>()) {
        final rc = Get.find<RouteController>();
        try {
          await (rc as dynamic).setRouteFromMap(routeData);
        } catch (_) {
          try {
            await (rc as dynamic).loadRouteFromChat(routeData);
          } catch (_) {}
        }
      }
    } catch (e) {
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => MapMonitoring());
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
                controller: _scroll_controller(),
                padding: const EdgeInsets.all(20.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return _chatBubble(
                    message: m,
                  );
                },
              ),
            ),
          Positioned(
            bottom: 0,
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
                              _controllerA.value * 2 * 3.141592653589793,
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

  ScrollController _scroll_controller() => _scrollController;

  Widget _chatBubble({required Map<String, dynamic> message}) {
    final String text = (message['text'] ?? '').toString();
    final bool isSender = (message['isSender'] == true);
    final Map<String, dynamic>? route = message['route'] is Map<String, dynamic>
        ? message['route'] as Map<String, dynamic>
        : null;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xffE45835) : const Color(0xff45557B),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (route != null) const SizedBox(height: 10),
            if (route != null)
              GestureDetector(
                onTap: () => _openRouteInMap(route),
                child: Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _buildSmallMapPreview(route),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMapPreview(Map<String, dynamic> route) {
    final List<LatLng> points = [];

    try {
      if (route.containsKey('start') && route['start'] != null) {
        final s = route['start'];
        if (s is Map && s['coords'] is List && s['coords'].length >= 2) {
          final lat = double.tryParse(s['coords'][0].toString()) ?? 0.0;
          final lon = double.tryParse(s['coords'][1].toString()) ?? 0.0;
          points.add(LatLng(lat, lon));
        }
      }
      if (route.containsKey('waypoints') && route['waypoints'] is List) {
        for (final wp in List.from(route['waypoints'])) {
          if (wp is List && wp.length >= 2) {
            final lat = double.tryParse(wp[0].toString()) ?? 0.0;
            final lon = double.tryParse(wp[1].toString()) ?? 0.0;
            points.add(LatLng(lat, lon));
          } else if (wp is Map &&
              wp['coords'] is List &&
              wp['coords'].length >= 2) {
            final lat = double.tryParse(wp['coords'][0].toString()) ?? 0.0;
            final lon = double.tryParse(wp['coords'][1].toString()) ?? 0.0;
            points.add(LatLng(lat, lon));
          }
        }
      }
      if (route.containsKey('end') && route['end'] != null) {
        final e = route['end'];
        if (e is Map && e['coords'] is List && e['coords'].length >= 2) {
          final lat = double.tryParse(e['coords'][0].toString()) ?? 0.0;
          final lon = double.tryParse(e['coords'][1].toString()) ?? 0.0;
          points.add(LatLng(lat, lon));
        }
      }
      if (points.isEmpty &&
          route.containsKey('route') &&
          route['route'] is List) {
        for (final r in List.from(route['route'])) {
          if (r is List && r.length >= 2) {
            final lat = double.tryParse(r[0].toString()) ?? 0.0;
            final lon = double.tryParse(r[1].toString()) ?? 0.0;
            points.add(LatLng(lat, lon));
          }
        }
      }
    } catch (e) {
    }

    if (points.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
            child: Text('Preview tidak tersedia',
                style: GoogleFonts.inter(color: Colors.black54))),
      );
    }

    final center = points[(points.length / 2).floor()];

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: points, strokeWidth: 4.0, color: Colors.orange),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: points.first,
              width: 10,
              height: 10,
             child:const Icon(Icons.location_on,
                  color: Colors.green, size: 18),
            ),
            if (points.length > 1)
              Marker(
                point: points.last,
                width: 10,
                height: 10,
                child:
                    const Icon(Icons.flag, color: Colors.red, size: 18),
              ),
          ],
        ),
      ],
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
                    offset: const Offset(0, 4),
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
