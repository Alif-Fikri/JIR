import 'dart:async';
import 'package:JIR/helper/voicefrequency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final int index;
  final VoidCallback? onPreviewToggle;
  final void Function(Map<String, dynamic>)? onOpenRoute;
  final bool previewVisible;

  const ChatBubble({
    super.key,
    required this.message,
    required this.index,
    this.onPreviewToggle,
    this.onOpenRoute,
    this.previewVisible = false,
  });

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  bool _routeHasCoords(Map<String, dynamic>? rt) {
    if (rt == null) return false;
    try {
      if (rt['route'] is List) {
        final list = List.from(rt['route']);
        int ok = 0;
        for (final p in list) {
          if (p is List && p.length >= 2) {
            final a = _toNum(p[0]);
            final b = _toNum(p[1]);
            if (a != null && b != null) ok++;
          } else if (p is Map && p['coords'] is List) {
            final c = List.from(p['coords']);
            if (c.length >= 2) {
              final a = _toNum(c[0]);
              final b = _toNum(c[1]);
              if (a != null && b != null) ok++;
            }
          }
          if (ok >= 2) return true;
        }
      }
      final start = rt['start'];
      final end = rt['end'];
      if (start != null && end != null) {
        LatLng? s = _extractLatLngFromNode(start);
        LatLng? e = _extractLatLngFromNode(end);
        if (s != null && e != null) return true;
      }
    } catch (_) {}
    return false;
  }

  LatLng? _extractLatLngFromNode(dynamic node) {
    try {
      if (node is List && node.length >= 2) {
        final a = _toNum(node[0]);
        final b = _toNum(node[1]);
        if (a != null && b != null) {
          if (a.abs() <= 90 && b.abs() <= 180) {
            return LatLng(a.toDouble(), b.toDouble());
          }
          if (b.abs() <= 90 && a.abs() <= 180) {
            return LatLng(b.toDouble(), a.toDouble());
          }
          return LatLng(a.toDouble(), b.toDouble());
        }
      } else if (node is Map) {
        if (node['coords'] is List) {
          final c = List.from(node['coords']);
          if (c.length >= 2) {
            final a = _toNum(c[0]);
            final b = _toNum(c[1]);
            if (a != null && b != null) {
              if (a.abs() <= 90 && b.abs() <= 180) {
                return LatLng(a.toDouble(), b.toDouble());
              }
              if (b.abs() <= 90 && a.abs() <= 180) {
                return LatLng(b.toDouble(), a.toDouble());
              }
              return LatLng(a.toDouble(), b.toDouble());
            }
          }
        }
        if (node['lat'] != null && node['lon'] != null) {
          final a = _toNum(node['lat']);
          final b = _toNum(node['lon']);
          if (a != null && b != null) return LatLng(a.toDouble(), b.toDouble());
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
            low.contains('paham'))) {
      return true;
    }
    if (low.contains('tidak mengerti') || low.contains('tidak paham')) {
      return true;
    }
    if (low.contains('sorry')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final rawText = (message['text'] ?? '').toString();
    final isSender = (message['isSender'] == true);
    final isTyping = message['isTyping'] == true;
    final dynamic r = message['route'];
    final Map<String, dynamic>? route =
        (r is Map) ? Map<String, dynamic>.from(r) : null;

    final hasRoute = _routeHasCoords(route);
    final isFallback = _isFallbackText(rawText);
    final showButtons = !isSender && !isTyping && hasRoute && !isFallback;

    Widget buildMainText() {
      if (isTyping) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AnimatedDots(),
          ],
        );
      }
      return Text(
        rawText,
        style: GoogleFonts.inter(
          color: Colors.white,
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
            if (showButtons) const SizedBox(height: 10),
            if (showButtons)
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
                    onPressed: () {
                      if (onOpenRoute != null && route != null) {
                        onOpenRoute!(route);
                      }
                    },
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
                    onPressed: onPreviewToggle,
                    child: Text(
                      previewVisible ? 'Sembunyikan' : 'Preview',
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            if (showButtons && previewVisible) const SizedBox(height: 10),
            if (showButtons && previewVisible)
              GestureDetector(
                onTap: () {
                  if (onOpenRoute != null) onOpenRoute!(route);
                },
                child: Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24)),
                  clipBehavior: Clip.hardEdge,
                  child: SmallMapPreview(route: route!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SmallMapPreview extends StatelessWidget {
  final Map<String, dynamic> route;
  const SmallMapPreview({super.key, required this.route});

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  void _addFromList(List list, List<LatLng> points) {
    if (list.length < 2) return;
    final a = _toNum(list[0]);
    final b = _toNum(list[1]);
    if (a == null || b == null) return;
    if (a.abs() <= 90 && b.abs() <= 180) {
      points.add(LatLng(a.toDouble(), b.toDouble()));
    } else if (b.abs() <= 90 && a.abs() <= 180) {
      points.add(LatLng(b.toDouble(), a.toDouble()));
    } else {
      points.add(LatLng(a.toDouble(), b.toDouble()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> points = [];

    try {
      if (route.containsKey('start') && route['start'] != null) {
        final s = route['start'];
        if (s is Map && s['coords'] is List) {
          _addFromList(List.from(s['coords']), points);
        } else if (s is List) {
          _addFromList(List.from(s), points);
        }
      }

      if (route.containsKey('waypoints') && route['waypoints'] is List) {
        for (final wp in List.from(route['waypoints'])) {
          if (wp is List) {
            _addFromList(wp, points);
          } else if (wp is Map && wp['coords'] is List) {
            _addFromList(List.from(wp['coords']), points);
          }
        }
      }

      if (route.containsKey('end') && route['end'] != null) {
        final e = route['end'];
        if (e is Map && e['coords'] is List) {
          _addFromList(List.from(e['coords']), points);
        } else if (e is List) {
          _addFromList(List.from(e), points);
        }
      }

      if (points.isEmpty &&
          route.containsKey('route') &&
          route['route'] is List) {
        for (final r in List.from(route['route'])) {
          if (r is List) {
            _addFromList(r, points);
          } else if (r is Map && r['coords'] is List) {
            _addFromList(List.from(r['coords']), points);
          }
        }
      }
    } catch (_) {}

    if (points.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
            child: Text('Preview tidak tersedia',
                style: GoogleFonts.inter(color: Colors.black54))),
      );
    }

    final center =
        points[(points.length / 2).floor().clamp(0, points.length - 1)];

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
            Polyline(points: points, strokeWidth: 4.0, color: Colors.orange)
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
                point: points.first,
                width: 10,
                height: 10,
                child: const Icon(Icons.location_on,
                    color: Colors.green, size: 18)),
            if (points.length > 1)
              Marker(
                  point: points.last,
                  width: 10,
                  height: 10,
                  child: const Icon(Icons.flag, color: Colors.red, size: 18)),
          ],
        ),
      ],
    );
  }
}

class ChatInput extends StatelessWidget {
  final dynamic controller;
  const ChatInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: Colors.white,
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffEAEFF3),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4))
              ],
            ),
            child: TextField(
              controller: controller.textController,
              style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.04, color: const Color(0xFF435482)),
              decoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: GoogleFonts.inter(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF435482)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Color(0x14000000), width: 1.0)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Color(0x14000000), width: 1.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Color(0x14000000), width: 1.0)),
                filled: true,
                fillColor: const Color(0xffEAEFF3),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xffE45835)),
                    onPressed: controller.sendFromInput),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffEAEFF3),
            border: Border.all(color: const Color(0x14000000), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4))
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 24,
            child: ObxValue<RxBool>(
              (rx) => IconButton(
                icon: Icon(rx.value ? Icons.mic : Icons.mic_none,
                    color: Colors.red),
                onPressed: rx.value
                    ? controller.stopListening
                    : controller.startListening,
              ),
              controller.isMicTapped,
            ),
          ),
        ),
      ]),
    );
  }
}

class MicOverlay extends StatelessWidget {
  final VoidCallback onStop;
  final AnimationController? controllerValueGetter;
  const MicOverlay(
      {super.key, required this.onStop, this.controllerValueGetter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(alignment: Alignment.center, children: [
        if (controllerValueGetter != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controllerValueGetter!,
              builder: (context, child) {
                return CustomPaint(
                  painter:
                      VoiceFrequencyPainter(controllerValueGetter!.value * 10),
                );
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffEAEFF3),
            border: Border.all(color: const Color(0x14000000), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4))
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40,
            child: IconButton(
                icon: const Icon(Icons.mic, color: Colors.red, size: 30),
                onPressed: onStop),
          ),
        ),
        Positioned(
          top: 0,
          child: Text(
            'Mendengarkan...',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ]),
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
        _count = (_count % 5) + 1;
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
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
