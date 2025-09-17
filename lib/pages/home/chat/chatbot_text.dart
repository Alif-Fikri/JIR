import 'package:flutter/gestures.dart';
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
  final Set<int> _previewVisible = {}; 

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

    print('DEBUG chat response: $resp');

    final typingIdx = _messages.indexWhere((m) => m['isTyping'] == true);
    if (typingIdx != -1) {
      setState(() {
        _messages.removeAt(typingIdx);
      });
    }

    final Map<String, dynamic>? routeData = _extractRouteData(resp);

    String botText;
    if (routeData != null) {
      final startName = _extractPlaceName(routeData['start']);
      final endName = _extractPlaceName(routeData['end']);
      if (startName.isNotEmpty && endName.isNotEmpty) {
        botText = 'Rute dari $startName ke $endName berhasil dibuat. Detail';
      } else {
        botText = 'Rute berhasil dibuat. Detail';
      }
      final messageEntry = {
        "text": botText,
        "isSender": false,
        "route": routeData,
      };
      setState(() {
        _messages.add(messageEntry);
      });
    } else {
      botText = _formatBotTextFromResponse(resp, null);
      setState(() {
        _messages.add({"text": botText, "isSender": false});
      });
    }

    scrollToBottom();

    try {
      await _flutterTts.speak(botText);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  String _formatBotTextFromResponse(
      dynamic resp, Map<String, dynamic>? routeData) {
    if (resp == null) return 'Maaf, server tidak merespon.';

    try {
      if (resp is Map<String, dynamic>) {
        if (resp.containsKey('data') && resp['data'] is Map) {
          final d = resp['data'] as Map;
          if (d['message'] != null) return d['message'].toString();
          if (d['respons'] != null &&
              d['respons'] is Map &&
              d['respons']['message'] != null) {
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
            return 'Rute dari $startName ke $endName berhasil dibuat. Detail';
          }
          return 'Rute berhasil dibuat. Detail';
        }

        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) {
          return singleLine.substring(0, 180) + '...';
        }
        return singleLine;
      } else {
        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) {
          return singleLine.substring(0, 180) + '...';
        }
        return singleLine;
      }
    } catch (e) {
      return 'Balasan diterima. Detail';
    }
  }

  String _extractPlaceName(dynamic node) {
    try {
      if (node == null) return '';
      if (node is Map) {
        if (node['place'] != null) return node['place'].toString();
        if (node['name'] != null) return node['name'].toString();
        if (node['display_name'] != null) {
          return node['display_name'].toString();
        }
        if (node['label'] != null) return node['label'].toString();
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic>? _extractRouteData(dynamic resp) {
    try {
      if (resp is Map<String, dynamic>) {
        if (resp.containsKey('start') && resp.containsKey('end')) return resp;
        if (resp.containsKey('route')) return resp;

        final candidates = <dynamic>[];
        if (resp.containsKey('data')) candidates.add(resp['data']);
        if (resp.containsKey('respons')) candidates.add(resp['respons']);
        if (resp.containsKey('response')) candidates.add(resp['response']);

        for (final c in candidates) {
          if (c is Map<String, dynamic>) {
            if (c.containsKey('start') && c.containsKey('end')) {
              return Map<String, dynamic>.from(c);
            }
            if (c.containsKey('route')) return Map<String, dynamic>.from(c);
            if (c.containsKey('respons') && c['respons'] is Map) {
              final rr = c['respons'] as Map;
              if (rr.containsKey('start') && rr.containsKey('end')) {
                return Map<String, dynamic>.from(rr as Map<String, dynamic>);
              }
              if (rr.containsKey('route')) {
                return Map<String, dynamic>.from(rr as Map<String, dynamic>);
              }
            }
          }
        }
      }
    } catch (e) {
      print('extractRouteData error: $e');
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
            final start = _extractCoords(routeData, 'start');
            final end = _extractCoords(routeData, 'end');
            if (start != null && end != null) {
              rc.updateLocations(start, end);
            } else if (routeData.containsKey('route') &&
                routeData['route'] is List) {
              final routeList = routeData['route'] as List;
              if (routeList.isNotEmpty) {
                final first = routeList.first;
                final last = routeList.last;
                final sLat = double.tryParse(first[0].toString()) ??
                    double.tryParse(first[1].toString());
                final sLon = double.tryParse(first[1].toString());
                final eLat = double.tryParse(last[0].toString()) ??
                    double.tryParse(last[1].toString());
                final eLon = double.tryParse(last[1].toString());
                if (sLat != null &&
                    sLon != null &&
                    eLat != null &&
                    eLon != null) {
                  rc.updateLocations(LatLng(sLat, sLon), LatLng(eLat, eLon));
                }
              }
            }
          } catch (e) {
            print('fallback set route error: $e');
          }
        }
      }
    } catch (e) {
      print('set route to controller failed: $e');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => MapMonitoring());
    });
  }

  LatLng? _extractCoords(Map<String, dynamic> routeData, String key) {
    try {
      if (!routeData.containsKey(key)) return null;
      final node = routeData[key];
      if (node is Map && node['coords'] is List && node['coords'].length >= 2) {
        final lat = double.tryParse(node['coords'][0].toString()) ?? 0.0;
        final lon = double.tryParse(node['coords'][1].toString()) ?? 0.0;
        return LatLng(lat, lon);
      }
      return null;
    } catch (_) {
      return null;
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
                    index: index,
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

  Widget _chatBubble(
      {required Map<String, dynamic> message, required int index}) {
    final String rawText = (message['text'] ?? '').toString();
    final bool isSender = (message['isSender'] == true);
    final Map<String, dynamic>? route = message['route'] is Map<String, dynamic>
        ? message['route'] as Map<String, dynamic>
        : null;

    final textColor = Colors.white;

    Widget buildTextWithDetail() {
      if (route == null) {
        return Text(
          rawText,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      }
      final displayText = rawText.replaceAll('Detail', '').trim();
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: displayText + (displayText.isNotEmpty ? ' ' : ''),
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: 'Detail',
              style: GoogleFonts.inter(
                color: Colors.orangeAccent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    if (_previewVisible.contains(index)) {
                      _previewVisible.remove(index);
                    } else {
                      _previewVisible.add(index);
                    }
                  });
                },
            ),
          ],
        ),
      );
    }

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
            buildTextWithDetail(),
            if (route != null && _previewVisible.contains(index))
              const SizedBox(height: 10),
            if (route != null && _previewVisible.contains(index))
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

    num? toNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    void addFromList(List list) {
      if (list.length < 2) return;
      final a = toNum(list[0]);
      final b = toNum(list[1]);
      if (a == null || b == null) return;
      if (a.abs() <= 90 && b.abs() <= 180) {
        points.add(LatLng(a.toDouble(), b.toDouble())); 
      } else if (b.abs() <= 90 && a.abs() <= 180) {
        points.add(LatLng(b.toDouble(), a.toDouble()));
      } else {
        points.add(LatLng(a.toDouble(), b.toDouble())); 
      }
    }

    try {
      if (route.containsKey('start') && route['start'] != null) {
        final s = route['start'];
        if (s is Map && s['coords'] is List) {
          addFromList(List.from(s['coords']));
        } else if (s is List) addFromList(List.from(s));
      }

      if (route.containsKey('waypoints') && route['waypoints'] is List) {
        for (final wp in List.from(route['waypoints'])) {
          if (wp is List) {
            addFromList(wp);
          } else if (wp is Map && wp['coords'] is List)
            addFromList(List.from(wp['coords']));
        }
      }

      if (route.containsKey('end') && route['end'] != null) {
        final e = route['end'];
        if (e is Map && e['coords'] is List) {
          addFromList(List.from(e['coords']));
        } else if (e is List) addFromList(List.from(e));
      }

      if (points.isEmpty &&
          route.containsKey('route') &&
          route['route'] is List) {
        for (final r in List.from(route['route'])) {
          if (r is List) addFromList(r);
        }
      }
    } catch (e) {
      print('preview parse error: $e');
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
      options: MapOptions(initialCenter: center, initialZoom: 13.0),
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
              child:
                  const Icon(Icons.location_on, color: Colors.green, size: 18),
            ),
            if (points.length > 1)
              Marker(
                point: points.last,
                width: 10,
                height: 10,
                child: const Icon(Icons.flag, color: Colors.red, size: 18),
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
