import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

class MapboxReusableMap extends StatefulWidget {
  final String accessToken;
  final String styleUri;
  final ll.LatLng? initialLocation;
  final ll.LatLng? userLocation;
  final double? userHeading;
  final List<ll.LatLng>? markers;
  final List<Map<String, dynamic>>? markerData;
  final List<ll.LatLng>? routePoints;
  final List<ll.LatLng>? waypoints;
  final void Function(int index)? onMarkerTap;
  final void Function(Map<String, dynamic>)? onMarkerDataTap;
  final double initialZoom;
  final void Function(MapboxMap)? onMapCreated;

  const MapboxReusableMap({
    super.key,
    required this.accessToken,
    this.styleUri = MapboxStyles.MAPBOX_STREETS,
    this.initialLocation,
    this.userLocation,
    this.userHeading,
    this.markers,
    this.markerData,
    this.routePoints,
    this.waypoints,
    this.onMarkerTap,
    this.onMarkerDataTap,
    this.initialZoom = 14.0,
    this.onMapCreated,
  });

  @override
  State<MapboxReusableMap> createState() => _MapboxReusableMapState();
}

mixin _MapboxAnnotationMixin on State<MapboxReusableMap> {
  PointAnnotationManager? pointManager;
  PointAnnotationManager? userPointManager;
  PolylineAnnotationManager? polylineManager;
  final Map<String, int> markerTapIndex = {};
  final Map<String, Map<String, dynamic>> _markerDataById = {};
  bool _tapEventsAttached = false;
  Function(PointAnnotation)? _annotationClickListener;
  PointAnnotation? _userAnnotation;
  final Map<int, Uint8List> _radarMarkerCache = {};
  final List<PointAnnotation> _floodAnnotations = [];
  String? _lastHandledAnnotationId;
  DateTime? _lastHandledAnnotationTime;
  static const double _radarBaseSize = 1.55;
  static const double _radarMinScale = 1.0;
  static const double _radarMaxScale = 1.25;
  static const Color _statusColorNormal = Color(0xFF4CAF50);
  static const Color _statusColorSiaga3 = Color(0xFFFFC107);
  static const Color _statusColorSiaga2 = Color(0xFFFF9800);
  static const Color _statusColorSiaga1 = Color(0xFFD32F2F);
  static const Color _statusColorDefault = Color(0xFFE53935);
  double _queuedRadarScale = 1.0;
  double? _lastAppliedRadarScale;
  bool _radarUpdateScheduled = false;

  double get radarMinScale => _radarMinScale;
  double get radarMaxScale => _radarMaxScale;
  Cancelable? _tapCancelable;

  Point _toPoint(ll.LatLng p) =>
      Point(coordinates: Position(p.longitude, p.latitude));

  Future<void> ensureAnnotationManagers(
    MapboxMap map,
    bool Function(PointAnnotation annotation) handler,
  ) async {
    print('[MAP LIFE] ensureAnnotationManagers - creating managers if needed');
    pointManager ??= await map.annotations.createPointAnnotationManager();
    print(
        '[MAP LIFE] ensureAnnotationManagers - pointManager created? ${pointManager != null}');

    polylineManager ??= await map.annotations.createPolylineAnnotationManager();
    print(
        '[MAP LIFE] ensureAnnotationManagers - polylineManager created? ${polylineManager != null}');

    try {
      _tapCancelable?.cancel();
    } catch (_) {}

    try {
      _tapCancelable = pointManager!.tapEvents(onTap: (annotation) {
        print('[MAP LIFE] tapEvents received -> id=${annotation.id}');
        try {
          handler(annotation);
        } catch (e, st) {
          print('[MAP LIFE] handler error: $e\n$st');
        }
      });
      print('[MAP LIFE] tapEvents registered on single pointManager');
    } catch (e, st) {
      _tapCancelable = null;
      print('[MAP LIFE] failed to register tapEvents: $e\n$st');
    }
  }

  Future<void> updatePointAnnotations({
    required List<ll.LatLng>? markers,
    required List<Map<String, dynamic>>? markerData,
    required List<ll.LatLng>? waypoints,
    required void Function(int index)? onMarkerTap,
  }) async {
    if (pointManager == null) {
      print(
          '[MAP LIFE] updatePointAnnotations skipped because pointManager==null');
      return;
    }
    try {
      await pointManager!.deleteAll();
    } catch (_) {}
    markerTapIndex.clear();
    _markerDataById.clear();
    _floodAnnotations.clear();
    _lastAppliedRadarScale = null;
    _queuedRadarScale = 1.0;

    print(
        '[MAP LIFE] updatePointAnnotations markers=${markers?.length ?? 0} markerData=${markerData?.length ?? 0}');

    if (markers != null) {
      for (var i = 0; i < markers.length; i++) {
        final position = markers[i];
        final data =
            markerData != null && i < markerData.length ? markerData[i] : null;
        final color = _resolveMarkerColor(data);
        final image = await _resolveRadarMarkerImage(color);
        final options = PointAnnotationOptions(
          geometry: _toPoint(position),
          image: image,
          iconAnchor: IconAnchor.CENTER,
          iconSize: _radarBaseSize,
        );
        try {
          final annotation = await pointManager!.create(options);
          print(
              '[MAP LIFE] created annotation id=${annotation.id} index=$i pos=${position.latitude},${position.longitude}');
          _floodAnnotations.add(annotation);
          if (onMarkerTap != null) {
            markerTapIndex[annotation.id] = i;
            print(
                '[MAP LIFE] mapped annotation.id=${annotation.id} -> index=$i');
          }
          if (data != null) {
            _markerDataById[annotation.id] = data;
          }
        } catch (e, st) {
          print('[MAP LIFE] create annotation failed: $e\n$st');
        }
      }
    }

    if (waypoints != null) {
      for (final waypoint in waypoints) {
        final options = PointAnnotationOptions(
          geometry: _toPoint(waypoint),
          iconSize: 1.0,
          iconColor: Colors.orange.value,
        );
        try {
          final a = await pointManager!.create(options);
          print('[MAP LIFE] created waypoint annotation id=${a.id}');
        } catch (e, st) {
          print('[MAP LIFE] create waypoint failed: $e\n$st');
        }
      }
    }
  }

  Color _resolveMarkerColor(Map<String, dynamic>? data) {
    if (data == null) return _statusColorDefault;
    final rawStatus = data['STATUS_SIAGA']?.toString() ?? '';
    final status = rawStatus.toLowerCase().trim();
    if (status.isEmpty) {
      return _statusColorDefault;
    }

    if (_statusContains(
        status, const ['normal', 'siaga 4', 'siaga4', 'hijau'])) {
      return _statusColorNormal;
    }

    if (_statusContains(
        status, const ['siaga 3', 'siaga3', 'waspada', 'kuning', 'orange'])) {
      return _statusColorSiaga3;
    }

    if (_statusContains(status, const ['siaga 2', 'siaga2', 'siaga dua'])) {
      return _statusColorSiaga2;
    }

    if (_statusContains(status, const ['siaga 1', 'siaga1', 'awas', 'merah'])) {
      return _statusColorSiaga1;
    }

    return _statusColorDefault;
  }

  bool _statusContains(String status, List<String> keywords) {
    for (final keyword in keywords) {
      if (keyword.isEmpty) continue;
      final token = keyword.toLowerCase();
      if (status.contains(token)) {
        return true;
      }
    }
    return false;
  }

  void updateRadarAnimation(double scale) {
    if (pointManager == null || _floodAnnotations.isEmpty) {
      return;
    }

    final clamped = scale.clamp(_radarMinScale, _radarMaxScale).toDouble();
    _queuedRadarScale = clamped;
    if (_radarUpdateScheduled) return;
    _radarUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyQueuedRadarScale();
    });
  }

  Future<void> _applyQueuedRadarScale() async {
    _radarUpdateScheduled = false;
    final manager = pointManager;
    if (manager == null || _floodAnnotations.isEmpty) return;

    final scale = _queuedRadarScale;
    if (_lastAppliedRadarScale != null &&
        (scale - _lastAppliedRadarScale!).abs() < 0.01) {
      return;
    }
    _lastAppliedRadarScale = scale;

    final annotationsSnapshot = List<PointAnnotation>.from(_floodAnnotations);
    for (final annotation in annotationsSnapshot) {
      if (!_floodAnnotations.contains(annotation)) {
        continue;
      }
      annotation.iconSize = _radarBaseSize * scale;
      try {
        await manager.update(annotation);
      } catch (_) {}
    }
  }

  Future<Uint8List> _resolveRadarMarkerImage(Color color) async {
    final cached = _radarMarkerCache[color.value];
    if (cached != null) return cached;

    const double dimension = 96;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final center = ui.Offset(dimension / 2, dimension / 2);

    final outerPaint = ui.Paint()
      ..color = color.withOpacity(0.22)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(center, dimension / 2, outerPaint);

    final midPaint = ui.Paint()
      ..color = color.withOpacity(0.28)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = dimension * 0.16;
    canvas.drawCircle(center, dimension * 0.34, midPaint);

    final innerPaint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(center, dimension * 0.18, innerPaint);

    final corePaint = ui.Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(center, dimension * 0.08, corePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(dimension.toInt(), dimension.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode radar marker image');
    }
    final bytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    _radarMarkerCache[color.value] = bytes;
    return bytes;
  }

  Future<void> updateUserLocationAnnotation({
    required ll.LatLng? userLocation,
    required Uint8List? userLocationImage,
    required double? userHeading,
  }) async {
    if (pointManager == null) return;

    if (userLocation == null) {
      if (_userAnnotation != null) {
        try {
          await pointManager!.delete(_userAnnotation!);
        } catch (_) {}
        _userAnnotation = null;
      }
      return;
    }

    final heading = userHeading ?? 0.0;

    if (_userAnnotation == null) {
      if (userLocationImage != null) {
        final options = PointAnnotationOptions(
          geometry: _toPoint(userLocation),
          image: userLocationImage,
          iconAnchor: IconAnchor.CENTER,
          iconRotate: heading,
          iconSize: 2.85,
        );
        try {
          _userAnnotation = await pointManager!.create(options);
          print('[MAP LIFE] created user annotation id=${_userAnnotation?.id}');
        } catch (e, st) {
          print('[MAP LIFE] create user annotation failed: $e\n$st');
        }
      } else {
        final options = PointAnnotationOptions(
          geometry: _toPoint(userLocation),
          iconColor: Colors.blue.value,
          iconAnchor: IconAnchor.CENTER,
          iconRotate: heading,
          iconSize: 2.85,
        );
        try {
          _userAnnotation = await pointManager!.create(options);
          print(
              '[MAP LIFE] created user annotation (color) id=${_userAnnotation?.id}');
        } catch (e, st) {
          print('[MAP LIFE] create user annotation (color) failed: $e\n$st');
        }
      }
      return;
    }

    _userAnnotation!
      ..geometry = _toPoint(userLocation)
      ..iconRotate = heading
      ..iconAnchor = IconAnchor.CENTER
      ..iconSize = 2.85;

    try {
      await pointManager!.update(_userAnnotation!);
      print('[MAP LIFE] updated user annotation id=${_userAnnotation?.id}');
    } catch (e, st) {
      try {
        await pointManager!.delete(_userAnnotation!);
      } catch (_) {}
      _userAnnotation = null;
      await updateUserLocationAnnotation(
        userLocation: userLocation,
        userLocationImage: userLocationImage,
        userHeading: heading,
      );
    }
  }

  Future<void> updatePolylineAnnotations(List<ll.LatLng>? routePoints) async {
    if (polylineManager == null) return;

    try {
      await polylineManager!.deleteAll();
    } catch (_) {}

    if (routePoints == null || routePoints.isEmpty) {
      return;
    }

    final coords =
        routePoints.map((p) => Position(p.longitude, p.latitude)).toList();

    final polyline = PolylineAnnotationOptions(
      geometry: LineString(coordinates: coords),
      lineColor: Colors.blue.value,
      lineWidth: 5.0,
    );

    try {
      await polylineManager!.create(polyline);
    } catch (_) {}
  }

  bool handleMarkerTap(PointAnnotation annotation) {
    bool handled = false;

    Map<String, dynamic>? data;
    final rawData = _markerDataById[annotation.id];
    if (rawData != null) {
      data = Map<String, dynamic>.from(rawData);
    }

    if (data != null && widget.onMarkerDataTap != null) {
      try {
        widget.onMarkerDataTap!(data);
        handled = true;
      } catch (_) {}
    }

    int? index = markerTapIndex[annotation.id];
    if (index == null && widget.markers != null && widget.markers!.isNotEmpty) {
      final geom = annotation.geometry;
      final tappedLat = geom.coordinates.lat;
      final tappedLng = geom.coordinates.lng;
      for (var i = 0; i < widget.markers!.length; i++) {
        final point = widget.markers![i];
        final latDiff = (point.latitude - tappedLat).abs();
        final lngDiff = (point.longitude - tappedLng).abs();
        if (latDiff < 0.00005 && lngDiff < 0.00005) {
          index = i;
          break;
        }
      }
    }

    if (index != null) {
      if (!handled && widget.onMarkerDataTap != null) {
        final dataList = widget.markerData;
        if (dataList != null && index >= 0 && index < dataList.length) {
          try {
            widget.onMarkerDataTap!(
              Map<String, dynamic>.from(dataList[index]),
            );
            handled = true;
          } catch (_) {}
        }
      }

      if (widget.onMarkerTap != null) {
        try {
          widget.onMarkerTap!(index);
          handled = true;
        } catch (_) {}
      }
    }

    if (handled) {
      _lastHandledAnnotationId = annotation.id;
      _lastHandledAnnotationTime = DateTime.now();
    }

    return handled;
  }

  void disposeAnnotations() {
    print('[MAP LIFE] disposeAnnotations called');
    try {
      _tapCancelable?.cancel();
    } catch (_) {}
    try {
      pointManager?.deleteAll();
    } catch (_) {}
    try {
      polylineManager?.deleteAll();
    } catch (_) {}
    markerTapIndex.clear();
    _markerDataById.clear();
    _tapCancelable = null;
    _annotationClickListener = null;
    _tapEventsAttached = false;
    pointManager = null;
    userPointManager = null;
    polylineManager = null;
    _userAnnotation = null;
    _floodAnnotations.clear();
    _radarMarkerCache.clear();
    _lastAppliedRadarScale = null;
    _radarUpdateScheduled = false;
    _queuedRadarScale = 1.0;
  }
}

class _MapboxReusableMapState extends State<MapboxReusableMap>
    with TickerProviderStateMixin, _MapboxAnnotationMixin {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleAttempted = false;
  final ll.LatLng _fallback = ll.LatLng(-6.200000, 106.816666);
  bool _hasCenteredOnUser = false;
  ll.LatLng? _lastCenteredUserLocation;
  static const double _tapHitSlopPx = 64.0;

  Uint8List? _lastUserImage;
  int? _lastUserImageHeadingBucket;

  late final AnimationController _radarAnim;

  @override
  void initState() {
    super.initState();
    _radarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )
      ..addListener(() {
        final t = _radarAnim.value;
        final eased = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        final scale = radarMinScale + (radarMaxScale - radarMinScale) * eased;
        updateRadarAnimation(scale);
      })
      ..repeat();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _map = mapboxMap;
    print('[MAP LIFE] _onMapCreated called');

    if (!_styleAttempted) {
      try {
        print('[MAP LIFE] loading styleUri=${widget.styleUri}');
        await _map!.loadStyleURI(widget.styleUri);
        print('[MAP LIFE] loadStyleURI finished');
      } catch (e, st) {
        print('[MAP LIFE] loadStyleURI error: $e\n$st');
      }
      _styleAttempted = true;
    }

    int tries = 0;
    while (tries < 12) {
      tries++;
      try {
        print('[MAP LIFE] ensureAnnotationManagers attempt #$tries');
        await ensureAnnotationManagers(_map!, (annotation) {
          try {
            return handleMarkerTap(annotation);
          } catch (_) {
            return false;
          }
        });

        _mapReady = true;

        print('[MAP LIFE] managers ready, calling _updateAll');

        await _updateAll();

        print('[MAP LIFE] _updateAll finished');

        widget.onMapCreated?.call(_map!);

        setState(() {});
        return;
      } catch (e, st) {
        print('[MAP LIFE] ensureAnnotationManagers failed: $e\n$st');
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    print('[MAP LIFE] _onMapCreated giving up after $tries tries');
    setState(() {});
  }

  void _handleMapTap(MapContentGestureContext context) {
    unawaited(_handleMapTapInternal(context));
  }

  Future<void> _handleMapTapInternal(MapContentGestureContext context) async {
    if (!_mapReady || _map == null) return;
    if (_floodAnnotations.isEmpty) return;
    if (context.gestureState != GestureState.ended) return;

    final tapPosition = context.touchPosition;
    PointAnnotation? closest;
    double closestDistance = double.infinity;

    for (final annotation in List<PointAnnotation>.from(_floodAnnotations)) {
      try {
        final screen = await _map!.pixelForCoordinate(annotation.geometry);
        final dx = screen.x - tapPosition.x;
        final dy = screen.y - tapPosition.y;
        final distance = math.sqrt(dx * dx + dy * dy);
        if (distance < closestDistance) {
          closestDistance = distance;
          closest = annotation;
        }
      } catch (_) {}
    }

    if (closest == null) return;
    if (closestDistance > _tapHitSlopPx) return;

    if (_lastHandledAnnotationId == closest.id &&
        _lastHandledAnnotationTime != null &&
        DateTime.now().difference(_lastHandledAnnotationTime!) <
            const Duration(milliseconds: 350)) {
      return;
    }

    handleMarkerTap(closest);
  }

  Future<void> _updateAll() async {
    if (!_mapReady || _map == null) return;

    await updatePointAnnotations(
      markers: widget.markers,
      markerData: widget.markerData,
      waypoints: widget.waypoints,
      onMarkerTap: widget.onMarkerTap,
    );

    await updatePolylineAnnotations(widget.routePoints);

    await _fitToBounds();

    final userImg = await _generateAndCacheUserImage(widget.userHeading);
    await updateUserLocationAnnotation(
      userLocation: widget.userLocation,
      userLocationImage: userImg,
      userHeading: widget.userHeading,
    );
    await _centerOnUserIfNeeded();
  }

  Future<Uint8List?> _generateAndCacheUserImage(double? heading) async {
    if (heading == null) {
      if (_lastUserImage != null && _lastUserImageHeadingBucket == 0) {
        return _lastUserImage;
      }
      final bytes = await _renderUserMarkerPng(0);
      _lastUserImage = bytes;
      _lastUserImageHeadingBucket = 0;
      return bytes;
    }

    final bucketSize = 8;
    final bucket = (heading / bucketSize).round();
    if (_lastUserImage != null && _lastUserImageHeadingBucket == bucket) {
      return _lastUserImage;
    }
    final bytes = await _renderUserMarkerPng(heading);
    _lastUserImage = bytes;
    _lastUserImageHeadingBucket = bucket;
    return bytes;
  }

  Future<Uint8List> _renderUserMarkerPng(double headingDeg,
      {int dimension = 96}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder,
        Rect.fromLTWH(0, 0, dimension.toDouble(), dimension.toDouble()));
    final center = ui.Offset(dimension / 2, dimension / 2);

    final ringPaint = ui.Paint()
      ..color = Colors.blue.withOpacity(0.18)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(center, dimension * 0.45, ringPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(headingDeg * (math.pi / 180));
    final path = ui.Path();
    path.moveTo(0, -dimension * 0.22);
    path.lineTo(-dimension * 0.08, 0);
    path.lineTo(dimension * 0.08, 0);
    path.close();
    final triPaint = ui.Paint()..color = Colors.blue.shade700;
    canvas.drawPath(path, triPaint);
    canvas.restore();

    final centerPaint = ui.Paint()..color = Colors.blue.shade700;
    canvas.drawCircle(center, dimension * 0.12, centerPaint);

    final borderPaint = ui.Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, dimension * 0.12, borderPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(dimension, dimension);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }

  Future<void> _fitToBounds() async {
    if (_map == null) return;
    if (_hasCenteredOnUser && widget.userLocation != null) return;
    final all = <ll.LatLng>[];
    if (widget.routePoints != null) all.addAll(widget.routePoints!);
    if (widget.markers != null) all.addAll(widget.markers!);
    if (widget.waypoints != null) all.addAll(widget.waypoints!);
    if (widget.userLocation != null) all.add(widget.userLocation!);
    if (all.isEmpty) return;
    double minLat = all.first.latitude, maxLat = all.first.latitude;
    double minLng = all.first.longitude, maxLng = all.first.longitude;
    for (final p in all) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final center = Point(
        coordinates: Position((minLng + maxLng) / 2, (minLat + maxLat) / 2));
    final zoom = _calcZoom(minLat, maxLat, minLng, maxLng);
    try {
      await _map!.flyTo(CameraOptions(center: center, zoom: zoom),
          MapAnimationOptions(duration: 700));
    } catch (_) {}
  }

  double _calcZoom(double minLat, double maxLat, double minLng, double maxLng) {
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    if (maxDiff > 10) return 5.0;
    if (maxDiff > 5) return 7.0;
    if (maxDiff > 2) return 9.0;
    if (maxDiff > 1) return 11.0;
    if (maxDiff > 0.5) return 12.0;
    if (maxDiff > 0.1) return 13.0;
    return widget.initialZoom;
  }

  ll.LatLng _resolveInitialCenter() {
    if (widget.initialLocation != null) {
      return widget.initialLocation!;
    }
    if (widget.userLocation != null) {
      return widget.userLocation!;
    }
    if (widget.markers != null && widget.markers!.isNotEmpty) {
      return widget.markers!.first;
    }
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      return widget.routePoints!.first;
    }
    if (widget.waypoints != null && widget.waypoints!.isNotEmpty) {
      return widget.waypoints!.first;
    }
    return _fallback;
  }

  Future<void> _centerOnUserIfNeeded() async {
    if (_map == null || !_mapReady) return;
    final user = widget.userLocation;
    if (user == null) return;
    if (_hasCenteredOnUser && _lastCenteredUserLocation != null) {
      return;
    }
    try {
      await _map!.flyTo(
        CameraOptions(center: _toPoint(user), zoom: 15.0),
        MapAnimationOptions(duration: 600),
      );
      _hasCenteredOnUser = true;
      _lastCenteredUserLocation = user;
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant MapboxReusableMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        '[MAP LIFE] didUpdateWidget called. oldMarkers=${oldWidget.markers?.length ?? 0} newMarkers=${widget.markers?.length ?? 0}');

    if (oldWidget.userLocation == null && widget.userLocation != null) {
      _hasCenteredOnUser = false;
      _lastCenteredUserLocation = null;
    }
    if (widget.userLocation == null) {
      _hasCenteredOnUser = false;
      _lastCenteredUserLocation = null;
    }

    if (_mapReady && _map != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print(
              '[MAP LIFE] didUpdateWidget -> ensureAnnotationManagers + _updateAll');
          await ensureAnnotationManagers(_map!, (annotation) {
            try {
              return handleMarkerTap(annotation);
            } catch (_) {
              return false;
            }
          });
          await _updateAll();
          print('[MAP LIFE] didUpdateWidget -> _updateAll finished');
        } catch (e, st) {
          print('[MAP LIFE] didUpdateWidget -> update failed: $e\n$st');
        }
      });
    }

    if (oldWidget.onMarkerTap != widget.onMarkerTap && _map != null) {
      ensureAnnotationManagers(_map!, (annotation) {
        try {
          return handleMarkerTap(annotation);
        } catch (_) {
          return false;
        }
      });
    }
  }

  @override
  void dispose() {
    try {
      disposeAnnotations();
    } catch (_) {}
    _radarAnim.stop();
    _radarAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _resolveInitialCenter();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            MapWidget(
              key: ValueKey(widget.accessToken + widget.styleUri),
              styleUri: widget.styleUri,
              cameraOptions: CameraOptions(
                center: _toPoint(center),
                zoom: widget.initialZoom,
              ),
              onMapCreated: _onMapCreated,
              onTapListener: _handleMapTap,
            ),
            if (!_mapReady)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            Positioned(
              right: 16,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () async {
                      if (_map == null) return;
                      try {
                        final state = await _map!.getCameraState();
                        await _map!.setCamera(
                          CameraOptions(zoom: state.zoom + 1),
                        );
                      } catch (_) {}
                    },
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () async {
                      if (_map == null) return;
                      try {
                        final state = await _map!.getCameraState();
                        await _map!.setCamera(
                          CameraOptions(zoom: state.zoom - 1),
                        );
                      } catch (_) {}
                    },
                    child: const Icon(Icons.remove, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    backgroundColor: Colors.white,
                    heroTag: 'center',
                    mini: true,
                    onPressed: () async {
                      if (_map == null) return;
                      final loc = widget.userLocation ??
                          widget.initialLocation ??
                          _fallback;
                      try {
                        await _map!.flyTo(
                          CameraOptions(center: _toPoint(loc), zoom: 15),
                          MapAnimationOptions(duration: 700),
                        );
                      } catch (_) {}
                    },
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
