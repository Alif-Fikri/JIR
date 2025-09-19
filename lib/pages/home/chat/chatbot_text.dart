import 'package:JIR/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:JIR/helper/voicefrequency.dart';
import 'package:JIR/services/chat_service/chat_api_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:JIR/pages/home/map/controller/flood_controller.dart';
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
  bool _loadingVisible = false;
  late AnimationController _controllerA;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, dynamic>> _messages = [];
  late stt.SpeechToText _speech;
  String _recognizedText = '';
  final Set<int> _previewVisible = {};
  Timer? _typingTimer;
  int? _typingMessageIndex;

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
    _typingTimer?.cancel();
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
    scrollToBottom();
  }

  void _showLoading({String? message}) {
    if (_loadingVisible) return;
    _loadingVisible = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF45557B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    message ?? 'Mempersiapkan peta...',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideLoading() {
    if (!_loadingVisible) return;
    _loadingVisible = false;
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (_) {}
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

    _typingTimer?.cancel();
    _typingMessageIndex = null;

    _typingTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add({"text": "", "isSender": false, "isTyping": true});
        _typingMessageIndex = _messages.length - 1;
      });
      scrollToBottom();
    });

    dynamic resp;
    try {
      resp = await ChatService.getChatResponse(message);
    } catch (e) {
      resp = null;
    }

    _typingTimer?.cancel();
    if (_typingMessageIndex != null) {
      setState(() {
        if (_typingMessageIndex! >= 0 &&
            _typingMessageIndex! < _messages.length &&
            (_messages[_typingMessageIndex!]['isTyping'] == true)) {
          _messages.removeAt(_typingMessageIndex!);
        }
        _typingMessageIndex = null;
      });
    }

    String botText;
    final Map<String, dynamic>? routeData = _extractRouteData(resp);

    if (routeData != null) {
      final startName = _extractPlaceName(routeData['start']);
      final endName = _extractPlaceName(routeData['end']);
      if (startName.isNotEmpty && endName.isNotEmpty) {
        botText = 'Rute dari $startName ke $endName berhasil dibuat.';
      } else {
        botText = 'Rute berhasil dibuat.';
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
            return 'Rute dari $startName ke $endName berhasil dibuat.';
          }
          return 'Rute berhasil dibuat.';
        }

        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) {
          return '${singleLine.substring(0, 180)}...';
        }
        return singleLine;
      } else {
        final s = resp.toString();
        final singleLine = s.replaceAll(RegExp(r'\s+'), ' ');
        if (singleLine.length > 200) {
          return '${singleLine.substring(0, 180)}...';
        }
        return singleLine;
      }
    } catch (e) {
      return 'Balasan diterima.';
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
      final RouteController rc = Get.isRegistered<RouteController>()
          ? Get.find<RouteController>()
          : Get.put(RouteController());

      final LatLng? start = _extractCoords(routeData, 'start') ??
          _extractFirstLastFromRouteList(routeData, isStart: true);
      final LatLng? end = _extractCoords(routeData, 'end') ??
          _extractFirstLastFromRouteList(routeData, isStart: false);

      if (start != null && end != null) {
        rc.userLocation(start);
        rc.destination(end);
        if (routeData['vehicle'] != null) {
          try {
            rc.selectedVehicle.value = routeData['vehicle'].toString();
          } catch (_) {}
        }
        await rc.fetchOptimizedRoute();
      } else {
        if (routeData.containsKey('route') && routeData['route'] is List) {
          final List<LatLng> pts = [];
          for (final p in List.from(routeData['route'])) {
            if (p is List && p.length >= 2) {
              final maybeLat = double.tryParse(p[0].toString());
              final maybeLon = double.tryParse(p[1].toString());
              if (maybeLat != null && (maybeLat.abs() <= 90)) {
                pts.add(LatLng(maybeLat, maybeLon ?? 0.0));
              } else if (maybeLon != null && (maybeLon.abs() <= 90)) {
                pts.add(LatLng(maybeLon, maybeLat ?? 0.0));
              }
            }
          }
          if (pts.isNotEmpty) {
            rc.userLocation(pts.first);
            rc.destination(pts.last);
            rc.routePoints.value = pts;
          }
        }
      }
    } catch (e, st) {
      print('openRouteInMap error: $e\n$st');
    }
  }

  LatLng? _extractCoords(Map<String, dynamic> routeData, String key) {
    try {
      if (!routeData.containsKey(key)) return null;
      final node = routeData[key];
      dynamic coords;
      if (node is Map && (node['coords'] is List)) {
        coords = List.from(node['coords']);
      } else if (node is List) {
        coords = List.from(node);
      } else if (node is Map && (node['lat'] != null && node['lon'] != null)) {
        final lat = double.tryParse(node['lat'].toString());
        final lon = double.tryParse(node['lon'].toString());
        if (lat != null && lon != null) return LatLng(lat, lon);
      } else {
        return null;
      }
      if (coords is List && coords.length >= 2) {
        final a = double.tryParse(coords[0].toString());
        final b = double.tryParse(coords[1].toString());
        if (a != null && b != null) {
          if (a.abs() <= 90 && b.abs() <= 180) {
            return LatLng(a, b);
          } else if (b.abs() <= 90 && a.abs() <= 180) {
            return LatLng(b, a);
          } else {
            return LatLng(a, b);
          }
        }
      }
    } catch (e) {
      print('_extractCoords error: $e');
    }
    return null;
  }

  LatLng? _extractFirstLastFromRouteList(Map<String, dynamic> routeData,
      {required bool isStart}) {
    try {
      if (!routeData.containsKey('route') || routeData['route'] is! List) {
        return null;
      }
      final List routeList = List.from(routeData['route']);
      if (routeList.isEmpty) return null;
      final candidate = isStart ? routeList.first : routeList.last;
      if (candidate is List && candidate.length >= 2) {
        final a = double.tryParse(candidate[0].toString());
        final b = double.tryParse(candidate[1].toString());
        if (a != null && b != null) {
          if (a.abs() <= 90 && b.abs() <= 180) return LatLng(a, b);
          return LatLng(b, a);
        }
      }
    } catch (e) {
      print('_extractFirstLastFromRouteList error: $e');
    }
    return null;
  }

  Future<void> _onTapOpenRoute(Map<String, dynamic> route) async {
    try {
      _showLoading(message: 'Menyiapkan rute...');
      await _openRouteInMap(route);
      if (!Get.isRegistered<FloodController>()) {
        try {
          Get.put(FloodController());
        } catch (_) {}
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _hideLoading();
      Get.toNamed(AppRoutes.peta);
    } catch (e) {
      _hideLoading();
      Get.snackbar('Gagal', 'Tidak dapat membuka peta. Silakan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.transparent,
          colorText: Colors.black);
      print('openRoute error: $e');
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
    final bool isTyping = message['isTyping'] == true;
    final Map<String, dynamic>? route = message['route'] is Map<String, dynamic>
        ? message['route'] as Map<String, dynamic>
        : null;

    final textColor = Colors.white;

    Widget buildMainText() {
      if (isTyping) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'sedang mengetik',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const AnimatedDots(),
          ],
        );
      }
      return Text(
        rawText,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
            buildMainText(),
            if (route != null) const SizedBox(height: 10),
            if (route != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _onTapOpenRoute(route),
                    child: Text(
                      'Lihat Rute',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_previewVisible.contains(index)) {
                          _previewVisible.remove(index);
                        } else {
                          _previewVisible.add(index);
                        }
                      });
                    },
                    child: Text(
                      _previewVisible.contains(index)
                          ? 'Sembunyikan'
                          : 'Preview',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            if (route != null && _previewVisible.contains(index))
              const SizedBox(height: 10),
            if (route != null && _previewVisible.contains(index))
              GestureDetector(
                onTap: () => _onTapOpenRoute(route),
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
          } else if (wp is Map && wp['coords'] is List) {
            addFromList(List.from(wp['coords']));
          }
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

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots> {
  int _count = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      setState(() {
        _count = (_count % 3) + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _count;
    return Text(
      dots,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
