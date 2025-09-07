import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:JIR/pages/home/map/controller/route_controller.dart';

class ReusableMap extends StatefulWidget {
  final LatLng initialLocation;
  final List<Marker> markers;
  final LatLng? userLocation;
  final LatLng? destination;
  final List<LatLng>? routePoints;
  final List<LatLng>? waypoints;
  final Function(MapController)? onMapCreated;
  final double? userHeading;

  const ReusableMap({
    super.key,
    required this.initialLocation,
    required this.markers,
    this.onMapCreated,
    this.userLocation,
    this.destination,
    this.routePoints,
    this.waypoints,
    this.userHeading,
  });

  @override
  ReusableMapState createState() => ReusableMapState();
}

class ReusableMapState extends State<ReusableMap>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng? _lastUserLocation;
  bool _shouldUpdateMap = true;
  bool _isRouteInitialized = false;
  List<LatLng>? _lastRoutePoints;
  List<LatLng>? _lastWaypoints;
  final distance = const Distance();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initMapPosition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initMapPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(widget.initialLocation, 15.0);
    });
  }

  @override
  void didUpdateWidget(ReusableMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userLocation != null && _lastUserLocation != null) {
      final dist = distance(widget.userLocation!, _lastUserLocation!);
      if (dist > 10) {
        _shouldUpdateMap = true;
        _lastUserLocation = widget.userLocation;

        _filterPassedRoutePoints();
        _checkIfDestinationReached();
      }
    }

    if (!_isRouteInitialized ||
        !_areRoutesEqual(widget.routePoints, _lastRoutePoints) ||
        !_areRoutesEqual(widget.waypoints, _lastWaypoints)) {
      _lastRoutePoints = widget.routePoints;
      _lastWaypoints = widget.waypoints;
      _updateMapBounds();
      _isRouteInitialized = true;
    }
  }

  bool _areRoutesEqual(List<LatLng>? a, List<LatLng>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _updateMapBounds() {
    List<LatLng> allPoints = [];

    if (widget.routePoints != null) {
      allPoints.addAll(widget.routePoints!);
    }

    if (widget.waypoints != null) {
      allPoints.addAll(widget.waypoints!);
    }

    if (widget.userLocation != null) {
      allPoints.add(widget.userLocation!);
    }

    if (widget.destination != null) {
      allPoints.add(widget.destination!);
    }

    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(100),
          maxZoom: 17.0,
        ),
      );
    });
  }

  void _updateMapPosition() {
    if (widget.userLocation != null) {
      _mapController.move(widget.userLocation!, _mapController.camera.zoom);
    }
  }

  void _filterPassedRoutePoints() {
    if (widget.userLocation == null || widget.routePoints == null) return;
    const double thresholdDistance = 10.0;

    setState(() {
      widget.routePoints!.removeWhere((point) {
        return distance(widget.userLocation!, point) < thresholdDistance;
      });
    });
  }

  void _checkIfDestinationReached() {
    if (widget.userLocation == null || widget.destination == null) return;
    const double destinationThreshold = 20.0;

    if (distance(widget.userLocation!, widget.destination!) <
        destinationThreshold) {
      setState(() {
        widget.routePoints!.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_shouldUpdateMap && widget.userLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMapPosition();
        _shouldUpdateMap = false;
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.initialLocation,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.drag |
                        InteractiveFlag.flingAnimation |
                        InteractiveFlag.pinchMove |
                        InteractiveFlag.pinchZoom,
                  ),
                ),
                children: [
                  _buildTileLayer(),
                  _buildRouteLayer(),
                  _buildWaypointsLayer(),
                  _buildMarkers(),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    heroTag: 'zoomIn',
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    heroTag: 'zoomOut',
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    heroTag: 'myLocation',
                    onPressed: () {
                      if (widget.userLocation != null) {
                        _mapController.move(widget.userLocation!, 15.0);
                      }
                    },
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      userAgentPackageName: 'com.example.JIR',
      tileBuilder: (context, tileWidget, tile) {
        return AnimatedOpacity(
          opacity: 0.95,
          duration: const Duration(milliseconds: 300),
          child: tileWidget,
        );
      },
    );
  }

  Widget _buildWaypointsLayer() {
    if (widget.waypoints == null || widget.waypoints!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: widget.waypoints!,
          strokeWidth: 3.0,
          color: Colors.orange.withOpacity(0.7),
          borderColor: Colors.orange.withOpacity(0.3),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }

  MarkerLayer _buildMarkers() {
    final markers = [
      ...widget.markers,
      if (widget.userLocation != null)
        Marker(
          point: widget.userLocation!,
          width: 60,
          height: 60,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: const _UserLocationMarker(),
          ),
        ),
      if (widget.destination != null)
        Marker(
          point: widget.destination!,
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ],
          ),
        ),
      if (widget.waypoints != null)
        ...widget.waypoints!.map((waypoint) {
          return Marker(
            point: waypoint,
            width: 30,
            height: 30,
            child: const Icon(
              Icons.location_pin,
              color: Colors.orange,
              size: 30,
            ),
          );
        }).toList(),
    ];

    return MarkerLayer(markers: markers, rotate: false);
  }

  Widget _buildRouteLayer() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: widget.routePoints!,
          strokeWidth: 4.0,
          color: Colors.blue,
          borderColor: Colors.blue.withOpacity(0.5),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentHeading = Get.find<RouteController>().userHeading.value;
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: (currentHeading * (math.pi / 180)),
            child: CustomPaint(
              size: const Size(48, 48),
              painter: _DirectionLightPainter(),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _DirectionLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path =
        ui.Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width * 0.4, size.height * 0.3)
          ..lineTo(size.width * 0.6, size.height * 0.3)
          ..close();

    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
