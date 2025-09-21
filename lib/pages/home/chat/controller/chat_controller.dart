import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';
import 'package:JIR/services/chat_service/chat_api_service.dart';
import 'package:JIR/pages/home/map/controller/route_controller.dart';
import 'package:JIR/app/routes/app_routes.dart';

class ChatController extends GetxController with StateMixin<void> {
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isMicTapped = false.obs;
  final RxBool isChatVisible = true.obs;
  final RxBool loadingVisible = false.obs;
  final RxSet<int> previewVisible = <int>{}.obs;

  late stt.SpeechToText _speech;
  final FlutterTts _flutterTts = FlutterTts();
  String recognizedText = '';
  Timer? _typingTimer;
  int? _typingMessageIndex;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  AnimationController? visualizerController;

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
    _simulateInitialMessages();
  }

  @override
  void onClose() {
    _flutterTts.stop();
    _typingTimer?.cancel();
    try {
      _speech.stop();
    } catch (_) {}
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _simulateInitialMessages() async {
    final initialMessages = [
      {
        "text":
            "Hallo Zee, aku Suki asisten anda untuk memantau banjir dan kerumunan",
        "isSender": false
      },
      {"text": "Ingin tahu kondisi di area tertentu?", "isSender": false},
    ];
    for (final m in initialMessages) {
      await Future.delayed(const Duration(seconds: 2));
      messages.add(Map<String, dynamic>.from(m));
      scrollToBottom();
    }
  }

  void showLoading({String? message}) {
    if (loadingVisible.value) return;
    loadingVisible.value = true;
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
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white))),
                const SizedBox(width: 14),
                Flexible(
                    child: Text(message ?? 'Mempersiapkan peta...',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (!loadingVisible.value) return;
    loadingVisible.value = false;
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      } else {
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }
    } catch (_) {}
  }

  Future<void> startListening() async {
    final available =
        await _speech.initialize(onStatus: (s) {}, onError: (e) {});
    if (!available) {
      Get.snackbar('Microphone', 'Microphone tidak tersedia',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isMicTapped.value = true;
    isChatVisible.value = false;
    recognizedText = '';
    _speech.listen(onResult: (result) {
      recognizedText = result.recognizedWords;
      update();
    });
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    isMicTapped.value = false;
    isChatVisible.value = true;

    final text = recognizedText.trim();
    recognizedText = '';
    if (text.isNotEmpty) {
      messages.add({"text": text, "isSender": true});
      scrollToBottom();
      await sendMessages(text);
    } else {
      scrollToBottom();
    }
  }

  Map<String, dynamic>? _toMapIfPossible(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      try {
        return Map<String, dynamic>.from(v);
      } catch (_) {}
    }
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _searchForRouteInMap(Map<String, dynamic> m) {
    if (m.containsKey('start') && m.containsKey('end')) {
      return Map<String, dynamic>.from(m);
    }
    if (m.containsKey('route')) return Map<String, dynamic>.from(m);
    for (final key in m.keys) {
      final val = m[key];
      final maybe = _toMapIfPossible(val);
      if (maybe != null) {
        if (maybe.containsKey('start') ||
            maybe.containsKey('route') ||
            maybe.containsKey('end')) {
          return Map<String, dynamic>.from(maybe);
        }
        final deeper = _searchForRouteInMap(maybe);
        if (deeper != null) return deeper;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractRouteData(dynamic resp) {
    try {
      final root = _toMapIfPossible(resp);
      if (root != null) {
        final found = _searchForRouteInMap(root);
        if (found != null) return found;
      }
      if (resp is List) {
        for (final item in resp) {
          final m = _toMapIfPossible(item);
          if (m != null) {
            final found = _searchForRouteInMap(m);
            if (found != null) return found;
          }
        }
      }
      if (root != null) {
        for (final key in ['data', 'respons', 'response', 'result']) {
          if (root.containsKey(key)) {
            final c = _toMapIfPossible(root[key]);
            if (c != null) {
              final found = _searchForRouteInMap(c);
              if (found != null) return found;
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isFallbackText(String s) {
    final low = s.toLowerCase();
    if (low.trim().isEmpty) return true;
    if (low.contains('{') && low.contains('}')) return true;
    if (low.contains('maaf') &&
        (low.contains('tidak') ||
            low.contains('mengerti') ||
            low.contains('memahami') ||
            low.contains('paham'))) return true;
    if (low.contains('tidak mengerti') || low.contains('tidak paham'))
      return true;
    if (low.contains('sorry')) return true;
    return false;
  }

  bool _routeIsValid(Map<String, dynamic>? rt) {
    if (rt == null) return false;
    try {
      if (rt['route'] is List) {
        final list = List.from(rt['route']);
        int ok = 0;
        for (final p in list) {
          if (p is List && p.length >= 2) {
            final a = num.tryParse(p[0].toString());
            final b = num.tryParse(p[1].toString());
            if (a != null && b != null) ok++;
          } else if (p is Map && p['coords'] is List) {
            final c = List.from(p['coords']);
            if (c.length >= 2) {
              final a = num.tryParse(c[0].toString());
              final b = num.tryParse(c[1].toString());
              if (a != null && b != null) ok++;
            }
          }
          if (ok >= 1) return true;
        }
      }
      final start = rt['start'];
      final end = rt['end'];
      if (start != null && end != null) {
        num? ax, ay, bx, by;
        if (start is List && start.length >= 2) {
          ax = num.tryParse(start[0].toString());
          ay = num.tryParse(start[1].toString());
        } else if (start is Map && start['coords'] is List) {
          final c = List.from(start['coords']);
          if (c.length >= 2) {
            ax = num.tryParse(c[0].toString());
            ay = num.tryParse(c[1].toString());
          }
        }
        if (end is List && end.length >= 2) {
          bx = num.tryParse(end[0].toString());
          by = num.tryParse(end[1].toString());
        } else if (end is Map && end['coords'] is List) {
          final c = List.from(end['coords']);
          if (c.length >= 2) {
            bx = num.tryParse(c[0].toString());
            by = num.tryParse(c[1].toString());
          }
        }
        if (ax != null && ay != null && bx != null && by != null) return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> sendMessages(String message) async {
    if (message.isEmpty) return;

    _typingTimer?.cancel();
    _typingMessageIndex = null;

    _typingTimer = Timer(const Duration(milliseconds: 600), () {
      messages.add({"text": "", "isSender": false, "isTyping": true});
      _typingMessageIndex = messages.length - 1;
      scrollToBottom();
    });

    dynamic resp;
    try {
      resp = await ChatService.getChatResponse(message);
    } catch (_) {
      resp = null;
      Get.snackbar('Terjadi Kesalahan',
          'Gagal terhubung ke server. Silakan coba lagi nanti.',
          snackPosition: SnackPosition.BOTTOM);
    }

    _typingTimer?.cancel();
    if (_typingMessageIndex != null) {
      if (_typingMessageIndex! >= 0 &&
          _typingMessageIndex! < messages.length &&
          (messages[_typingMessageIndex!]['isTyping'] == true)) {
        messages.removeAt(_typingMessageIndex!);
      }
      _typingMessageIndex = null;
    }

    String botText;
    final rawRoute = _extractRouteData(resp);
    final Map<String, dynamic>? routeMap = _toMapIfPossible(rawRoute);

    if (resp is Map && resp.containsKey('error')) {
      botText = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } else if (resp is Map && resp['ok'] == true) {
      final data = resp['data'];
      botText = _extractChatTextFromData(data);
    } else {
      botText = _formatBotTextFromResponse(resp, null);
    }

    if (_isFallbackText(botText)) {
      botText = 'Maaf, saya tidak memahami permintaan Anda.';
    }

    final includeRoute = routeMap != null &&
        _routeIsValid(routeMap) &&
        !_isFallbackText(botText);

    final messageEntry = {
      "text": botText,
      "isSender": false,
      if (includeRoute) "route": routeMap
    };
    messages.add(Map<String, dynamic>.from(messageEntry));

    scrollToBottom();
    try {
      await _flutterTts.speak(botText);
    } catch (_) {}
  }

  String _extractChatTextFromData(dynamic data) {
    try {
      if (data == null) return 'Maaf, server tidak merespon.';
      if (data is String) return data;
      if (data is Map) {
        if (data['response'] != null) return data['response'].toString();
        if (data['respons'] != null) return data['respons'].toString();
        if (data['message'] != null) return data['message'].toString();
        if (data['data'] != null) return _extractChatTextFromData(data['data']);
        final s = data.toString().replaceAll(RegExp(r'\s+'), ' ');
        if (s.length > 240) return '${s.substring(0, 220)}...';
        return s;
      }
      return data.toString();
    } catch (_) {
      return 'Balasan diterima.';
    }
  }

  Future<void> openRouteInMap(Map<String, dynamic> routeData) async {
    try {
      showLoading(message: 'Membuka peta...');
      final RouteController rc = Get.isRegistered<RouteController>()
          ? Get.find<RouteController>()
          : Get.put(RouteController());
      final start = _extractCoords(routeData, 'start') ??
          _extractFirstLastFromRouteList(routeData, isStart: true);
      final end = _extractCoords(routeData, 'end') ??
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
        hideLoading();
        Get.toNamed(AppRoutes.peta);
        return;
      }

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
          hideLoading();
          Get.toNamed(AppRoutes.peta);
          return;
        }
      }

      hideLoading();
      Get.snackbar('Maaf', 'Preview rute tidak tersedia untuk pesan ini.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      hideLoading();
      Get.snackbar('Terjadi Kesalahan',
          'Gagal membuka rute. Silakan coba lagi atau periksa koneksi.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!loadingVisible.value) {
        try {
          hideLoading();
        } catch (_) {}
      }
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
    } catch (_) {
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
          if (a.abs() <= 90 && b.abs() <= 180) return LatLng(a, b);
          if (b.abs() <= 90 && a.abs() <= 180) return LatLng(b, a);
          return LatLng(a, b);
        }
      }
    } catch (_) {}
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
    } catch (_) {}
    return null;
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void togglePreview(int index) {
    if (previewVisible.contains(index)) {
      previewVisible.remove(index);
    } else {
      previewVisible.add(index);
    }
    previewVisible.refresh();
  }

  void sendFromInput() {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    messages.add({"text": text, "isSender": true});
    textController.clear();
    scrollToBottom();
    sendMessages(text);
  }
}
