// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:latlong2/latlong.dart' as ll;

// class RouteLineConfig {
//   RouteLineConfig({
//     required this.id,
//     required this.points,
//     required this.color,
//     required this.width,
//     this.opacity,
//   });

//   final String id;
//   final List<ll.LatLng> points;
//   final Color color;
//   final double width;
//   final double? opacity;
// }

// class _MarkerDescriptor {
//   _MarkerDescriptor({
//     required this.position,
//     required this.markerType,
//     required this.usesRadarAnimation,
//     this.color,
//   });

//   final ll.LatLng position;
//   final String markerType;
//   final bool usesRadarAnimation;
//   final Color? color;
// }

// class _RouteDescriptor {
//   _RouteDescriptor({required this.signature});
//   final String signature;
// }

// class MapboxReusableMap extends StatefulWidget {
//   final String accessToken;
//   final String styleUri;
//   final ll.LatLng? initialLocation;
//   final ll.LatLng? userLocation;
//   final double? userHeading;
//   final List<ll.LatLng>? markers;
//   final List<Map<String, dynamic>>? markerData;
//   final List<ll.LatLng>? routePoints;
//   final List<ll.LatLng>? waypoints;
//   final ll.LatLng? destination;
//   final void Function(int index)? onMarkerTap;
//   final void Function(Map<String, dynamic>)? onMarkerDataTap;
//   final List<RouteLineConfig>? routeLines;
//   final ValueChanged<String>? onRouteTap;
//   final double initialZoom;
//   final double? initialPitch;
//   final double? initialBearing;
//   final bool enable3DBuildings;
//   final bool autoPitchOnRoute;
//   final double navigationPitch;
//   final double? navigationZoom;
//   final void Function(MapboxMap)? onMapCreated;

//   const MapboxReusableMap({
//     super.key,
//     required this.accessToken,
//     this.styleUri = MapboxStyles.MAPBOX_STREETS,
//     this.initialLocation,
//     this.userLocation,
//     this.userHeading,
//     this.markers,
//     this.markerData,
//     this.routePoints,
//     this.waypoints,
//     this.destination,
//     this.onMarkerTap,
//     this.onMarkerDataTap,
//     this.routeLines,
//     this.onRouteTap,
//     this.initialZoom = 14.0,
//     this.initialPitch,
//     this.initialBearing,
//     this.enable3DBuildings = false,
//     this.autoPitchOnRoute = false,
//     this.navigationPitch = 48.0,
//     this.navigationZoom,
//     this.onMapCreated,
//   });

//   @override
//   State<MapboxReusableMap> createState() => _MapboxReusableMapState();
// }

// mixin _MapboxAnnotationMixin on State<MapboxReusableMap> {
//   PointAnnotationManager? pointManager;
//   PointAnnotationManager? userPointManager;
//   PolylineAnnotationManager? polylineManager;
//   final Map<String, int> markerTapIndex = {};
//   final Map<String, Map<String, dynamic>> _markerDataById = {};
//   final Map<String, PointAnnotation> _markerAnnotations = {};
//   final Map<String, _MarkerDescriptor> _markerDescriptors = {};
//   final Map<String, PointAnnotation> _waypointAnnotations = {};
//   final Map<String, ll.LatLng> _waypointPositions = {};
//   PointAnnotation? _destinationAnnotation;
//   ll.LatLng? _destinationPosition;
//   PointAnnotation? _userAnnotation;
//   final Map<int, Uint8List> _radarMarkerCache = {};
//   Uint8List? _cctvMarkerImage;
//   Uint8List? _destinationMarkerImage;
//   final List<PointAnnotation> _floodAnnotations = [];
//   final Map<String, PolylineAnnotation> _routeAnnotations = {};
//   final Map<String, _RouteDescriptor> _routeDescriptors = {};
//   String? _lastHandledAnnotationId;
//   DateTime? _lastHandledAnnotationTime;
//   static const double _radarBaseSize = 1.55;
//   static const double _radarMinScale = 1.0;
//   static const double _radarMaxScale = 1.25;
//   static const Color _statusColorNormal = Color(0xFF4CAF50);
//   static const Color _statusColorSiaga2 = Color(0xFFFF9800);
//   static const Color _statusColorSiaga1 = Color(0xFFD32F2F);
//   static const Color _statusColorDefault = Color(0xFFE53935);
//   double _queuedRadarScale = 1.0;
//   double? _lastAppliedRadarScale;
//   bool _radarUpdateScheduled = false;

//   double get radarMinScale => _radarMinScale;
//   double get radarMaxScale => _radarMaxScale;
//   Cancelable? _tapCancelable;

//   Point _toPoint(ll.LatLng p) =>
//       Point(coordinates: Position(p.longitude, p.latitude));

//   Future<void> ensureAnnotationManagers(
//     MapboxMap map,
//     bool Function(PointAnnotation annotation) handler,
//   ) async {
//     print('[MAP LIFE] ensureAnnotationManagers - creating managers if needed');
//     pointManager ??= await map.annotations.createPointAnnotationManager();
//     print(
//         '[MAP LIFE] ensureAnnotationManagers - pointManager created? ${pointManager != null}');

//     polylineManager ??= await map.annotations.createPolylineAnnotationManager();
//     print(
//         '[MAP LIFE] ensureAnnotationManagers - polylineManager created? ${polylineManager != null}');

//     try {
//       _tapCancelable?.cancel();
//     } catch (_) {}

//     try {
//       _tapCancelable = pointManager!.tapEvents(onTap: (annotation) {
//         print('[MAP LIFE] tapEvents received -> id=${annotation.id}');
//         try {
//           handler(annotation);
//         } catch (e, st) {
//           print('[MAP LIFE] handler error: $e\n$st');
//         }
//       });
//       print('[MAP LIFE] tapEvents registered on single pointManager');
//     } catch (e, st) {
//       _tapCancelable = null;
//       print('[MAP LIFE] failed to register tapEvents: $e\n$st');
//     }
//   }

//   String _markerKey(ll.LatLng position, Map<String, dynamic>? data, int index) {
//     if (data != null) {
//       const candidates = [
//         'id',
//         'ID',
//         'Id',
//         'markerId',
//         'MARKER_ID',
//         'identifier',
//         'location',
//         'LOCATION',
//         'name',
//         'NAME',
//         'NAMA_PINTU_AIR',
//       ];
//       for (final field in candidates) {
//         final value = data[field];
//         final normalized = _normalizeKeyValue(value);
//         if (normalized != null) {
//           return 'data:$field:$normalized';
//         }
//       }
//     }

//     final lat = position.latitude.toStringAsFixed(6);
//     final lng = position.longitude.toStringAsFixed(6);
//     return 'idx:$index@$lat,$lng';
//   }

//   String _waypointKey(int index, ll.LatLng point) {
//     final lat = point.latitude.toStringAsFixed(6);
//     final lng = point.longitude.toStringAsFixed(6);
//     return 'wp:$index@$lat,$lng';
//   }

//   String? _normalizeKeyValue(dynamic value) {
//     if (value == null) return null;
//     final str = value.toString().trim();
//     if (str.isEmpty) return null;
//     return str.toLowerCase();
//   }

//   bool _positionsMatch(ll.LatLng a, ll.LatLng b) {
//     return (a.latitude - b.latitude).abs() < 0.000001 &&
//         (a.longitude - b.longitude).abs() < 0.000001;
//   }

//   String _buildRouteSignature(
//     List<ll.LatLng> points,
//     int color,
//     double width,
//     double opacity,
//   ) {
//     final buffer = StringBuffer()
//       ..write(color)
//       ..write('|')
//       ..write(width.toStringAsFixed(2))
//       ..write('|')
//       ..write(opacity.toStringAsFixed(2));
//     for (final point in points) {
//       buffer
//         ..write(';')
//         ..write(point.latitude.toStringAsFixed(6))
//         ..write(',')
//         ..write(point.longitude.toStringAsFixed(6));
//     }
//     return buffer.toString();
//   }

//   Future<void> updatePointAnnotations({
//     required List<ll.LatLng>? markers,
//     required List<Map<String, dynamic>>? markerData,
//     required List<ll.LatLng>? waypoints,
//     required ll.LatLng? destination,
//     required void Function(int index)? onMarkerTap,
//   }) async {
//     final manager = pointManager;
//     if (manager == null) {
//       print(
//           '[MAP LIFE] updatePointAnnotations skipped because pointManager==null');
//       return;
//     }

//     markerTapIndex.clear();
//     _markerDataById.clear();

//     final desiredMarkerKeys = <String>{};
//     final newFloodAnnotations = <PointAnnotation>[];

//     if (markers != null) {
//       for (var i = 0; i < markers.length; i++) {
//         final position = markers[i];
//         final data =
//             markerData != null && i < markerData.length ? markerData[i] : null;
//         final rawType =
//             (data?['markerType'] ?? data?['type'])?.toString().toLowerCase();
//         final markerType = rawType?.isNotEmpty == true ? rawType! : 'default';
//         final markerKey = _markerKey(position, data, i);
//         desiredMarkerKeys.add(markerKey);

//         final descriptor = _markerDescriptors[markerKey];
//         final existingAnnotation = _markerAnnotations[markerKey];

//         bool usesRadarAnimation = markerType != 'cctv';
//         Color? markerColor;
//         bool needsRecreate = existingAnnotation == null || descriptor == null;

//         if (usesRadarAnimation) {
//           markerColor = _resolveMarkerColor(data);
//         }

//         if (!needsRecreate) {
//           final descriptorNonNull = descriptor;
//           final annotationNonNull = existingAnnotation;
//           final moved = !_positionsMatch(descriptorNonNull.position, position);
//           final typeChanged = descriptorNonNull.markerType != markerType;
//           final radarChanged =
//               descriptorNonNull.usesRadarAnimation != usesRadarAnimation;
//           final colorChanged = descriptorNonNull.color != markerColor;

//           if (typeChanged || radarChanged || colorChanged) {
//             needsRecreate = true;
//           } else if (moved) {
//             annotationNonNull.geometry = _toPoint(position);
//             try {
//               await manager.update(annotationNonNull);
//             } catch (e, st) {
//               print('[MAP LIFE] update marker failed, recreating: $e\n$st');
//               needsRecreate = true;
//             }
//           }
//         }

//         PointAnnotation? annotation = existingAnnotation;

//         if (needsRecreate) {
//           if (existingAnnotation != null) {
//             try {
//               await manager.delete(existingAnnotation);
//             } catch (e, st) {
//               print('[MAP LIFE] delete marker before recreate failed: $e\n$st');
//             }
//           }

//           try {
//             if (markerType == 'cctv') {
//               final image = await _resolveCctvMarkerImage();
//               final options = PointAnnotationOptions(
//                 geometry: _toPoint(position),
//                 image: image,
//                 iconAnchor: IconAnchor.CENTER,
//                 iconSize: 1.15,
//               );
//               annotation = await manager.create(options);
//             } else {
//               markerColor ??= _resolveMarkerColor(data);
//               final image = await _resolveRadarMarkerImage(markerColor);
//               final options = PointAnnotationOptions(
//                 geometry: _toPoint(position),
//                 image: image,
//                 iconAnchor: IconAnchor.CENTER,
//                 iconSize: _radarBaseSize,
//               );
//               annotation = await manager.create(options);
//             }
//           } catch (e, st) {
//             print('[MAP LIFE] create marker failed: $e\n$st');
//             _markerAnnotations.remove(markerKey);
//             _markerDescriptors.remove(markerKey);
//             continue;
//           }
//         }

//         if (annotation == null) {
//           continue;
//         }

//         _markerAnnotations[markerKey] = annotation;
//         _markerDescriptors[markerKey] = _MarkerDescriptor(
//           position: position,
//           markerType: markerType,
//           usesRadarAnimation: usesRadarAnimation,
//           color: markerColor,
//         );

//         if (usesRadarAnimation) {
//           newFloodAnnotations.add(annotation);
//         }

//         if (onMarkerTap != null) {
//           markerTapIndex[annotation.id] = i;
//         }

//         if (data != null) {
//           _markerDataById[annotation.id] = data;
//         }
//       }
//     }

//     final staleMarkerKeys = _markerAnnotations.keys
//         .where((key) => !desiredMarkerKeys.contains(key))
//         .toList(growable: false);
//     if (staleMarkerKeys.isNotEmpty) {
//       for (final key in staleMarkerKeys) {
//         final annotation = _markerAnnotations.remove(key);
//         _markerDescriptors.remove(key);
//         if (annotation != null) {
//           try {
//             await manager.delete(annotation);
//           } catch (e, st) {
//             print('[MAP LIFE] delete stale marker failed: $e\n$st');
//           }
//         }
//       }
//     }

//     bool radarChanged = _floodAnnotations.length != newFloodAnnotations.length;
//     if (!radarChanged) {
//       for (var i = 0; i < newFloodAnnotations.length; i++) {
//         if (!identical(_floodAnnotations[i], newFloodAnnotations[i])) {
//           radarChanged = true;
//           break;
//         }
//       }
//     }
//     if (radarChanged) {
//       _floodAnnotations
//         ..clear()
//         ..addAll(newFloodAnnotations);
//       _lastAppliedRadarScale = null;
//       _queuedRadarScale = 1.0;
//     }

//     final desiredWaypointKeys = <String>{};
//     if (waypoints != null) {
//       for (var i = 0; i < waypoints.length; i++) {
//         final waypoint = waypoints[i];
//         final key = _waypointKey(i, waypoint);
//         desiredWaypointKeys.add(key);
//         final existing = _waypointAnnotations[key];
//         final previousPosition = _waypointPositions[key];

//         if (existing == null) {
//           final options = PointAnnotationOptions(
//             geometry: _toPoint(waypoint),
//             iconSize: 1.0,
//             iconColor: Colors.orange.value,
//           );
//           try {
//             final annotation = await manager.create(options);
//             _waypointAnnotations[key] = annotation;
//             _waypointPositions[key] = waypoint;
//             print('[MAP LIFE] created waypoint annotation id=${annotation.id}');
//           } catch (e, st) {
//             print('[MAP LIFE] create waypoint failed: $e\n$st');
//           }
//           continue;
//         }

//         if (previousPosition == null ||
//             !_positionsMatch(previousPosition, waypoint)) {
//           existing.geometry = _toPoint(waypoint);
//           try {
//             await manager.update(existing);
//             _waypointPositions[key] = waypoint;
//           } catch (e, st) {
//             print('[MAP LIFE] update waypoint failed, recreating: $e\n$st');
//             try {
//               await manager.delete(existing);
//             } catch (_) {}
//             final options = PointAnnotationOptions(
//               geometry: _toPoint(waypoint),
//               iconSize: 1.0,
//               iconColor: Colors.orange.value,
//             );
//             try {
//               final annotation = await manager.create(options);
//               _waypointAnnotations[key] = annotation;
//               _waypointPositions[key] = waypoint;
//             } catch (e2, st2) {
//               print('[MAP LIFE] recreate waypoint failed: $e2\n$st2');
//               _waypointAnnotations.remove(key);
//               _waypointPositions.remove(key);
//             }
//           }
//         }
//       }
//     }

//     final staleWaypointKeys = _waypointAnnotations.keys
//         .where((key) => !desiredWaypointKeys.contains(key))
//         .toList(growable: false);
//     if (staleWaypointKeys.isNotEmpty) {
//       for (final key in staleWaypointKeys) {
//         final annotation = _waypointAnnotations.remove(key);
//         _waypointPositions.remove(key);
//         if (annotation != null) {
//           try {
//             await manager.delete(annotation);
//           } catch (e, st) {
//             print('[MAP LIFE] delete waypoint failed: $e\n$st');
//           }
//         }
//       }
//     }

//     if (destination == null) {
//       if (_destinationAnnotation != null) {
//         try {
//           await manager.delete(_destinationAnnotation!);
//         } catch (e, st) {
//           print('[MAP LIFE] delete destination annotation failed: $e\n$st');
//         }
//         _destinationAnnotation = null;
//         _destinationPosition = null;
//       }
//     } else {
//       if (_destinationAnnotation == null) {
//         try {
//           final image = await _resolveDestinationMarkerImage();
//           final options = PointAnnotationOptions(
//             geometry: _toPoint(destination),
//             image: image,
//             iconAnchor: IconAnchor.BOTTOM,
//             iconSize: 0.9,
//           );
//           _destinationAnnotation = await manager.create(options);
//           _destinationPosition = destination;
//           print(
//               '[MAP LIFE] created destination annotation id=${_destinationAnnotation?.id}');
//         } catch (e, st) {
//           print('[MAP LIFE] create destination annotation failed: $e\n$st');
//         }
//       } else {
//         if (_destinationPosition == null ||
//             !_positionsMatch(_destinationPosition!, destination)) {
//           _destinationAnnotation!.geometry = _toPoint(destination);
//           try {
//             await manager.update(_destinationAnnotation!);
//             _destinationPosition = destination;
//           } catch (e, st) {
//             print('[MAP LIFE] update destination failed, recreating: $e\n$st');
//             try {
//               await manager.delete(_destinationAnnotation!);
//             } catch (_) {}
//             _destinationAnnotation = null;
//             _destinationPosition = null;
//             try {
//               final image = await _resolveDestinationMarkerImage();
//               final options = PointAnnotationOptions(
//                 geometry: _toPoint(destination),
//                 image: image,
//                 iconAnchor: IconAnchor.BOTTOM,
//                 iconSize: 0.9,
//               );
//               _destinationAnnotation = await manager.create(options);
//               _destinationPosition = destination;
//             } catch (e2, st2) {
//               print('[MAP LIFE] recreate destination failed: $e2\n$st2');
//             }
//           }
//         }
//       }
//     }
//   }

//   Color _resolveMarkerColor(Map<String, dynamic>? data) {
//     if (data == null) return _statusColorDefault;
//     final rawStatus = data['STATUS_SIAGA']?.toString() ?? '';
//     final status = rawStatus.toLowerCase().trim();
//     if (status.isEmpty) {
//       return _statusColorDefault;
//     }

//     if (_statusContains(
//         status, const ['normal', 'siaga 4', 'siaga4', 'hijau'])) {
//       return _statusColorNormal;
//     }

//     if (_statusContains(status, const [
//       'siaga 3',
//       'siaga3',
//       'siaga tiga',
//       'waspada',
//       'kuning',
//       'orange'
//     ])) {
//       return _statusColorSiaga2;
//     }

//     if (_statusContains(
//         status, const ['siaga merah', 'siaga 2', 'siaga2', 'awas', 'merah'])) {
//       return _statusColorSiaga1;
//     }

//     return _statusColorDefault;
//   }

//   bool _statusContains(String status, List<String> keywords) {
//     for (final keyword in keywords) {
//       if (keyword.isEmpty) continue;
//       final token = keyword.toLowerCase();
//       if (status.contains(token)) {
//         return true;
//       }
//     }
//     return false;
//   }

//   void updateRadarAnimation(double scale) {
//     if (pointManager == null || _floodAnnotations.isEmpty) {
//       return;
//     }

//     final clamped = scale.clamp(_radarMinScale, _radarMaxScale).toDouble();
//     _queuedRadarScale = clamped;
//     if (_radarUpdateScheduled) return;
//     _radarUpdateScheduled = true;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _applyQueuedRadarScale();
//     });
//   }

//   Future<void> _applyQueuedRadarScale() async {
//     _radarUpdateScheduled = false;
//     final manager = pointManager;
//     if (manager == null || _floodAnnotations.isEmpty) return;

//     final scale = _queuedRadarScale;

//     if (_lastAppliedRadarScale != null &&
//         (scale - _lastAppliedRadarScale!).abs() < 0.05) {
//       return;
//     }
//     _lastAppliedRadarScale = scale;

//     final annotationsSnapshot = List<PointAnnotation>.from(_floodAnnotations);
//     for (final annotation in annotationsSnapshot) {
//       if (!_floodAnnotations.contains(annotation)) {
//         continue;
//       }
//       annotation.iconSize = _radarBaseSize * scale;
//       try {
//         await manager.update(annotation);
//       } catch (_) {}
//     }
//   }

//   Future<Uint8List> _resolveRadarMarkerImage(Color color) async {
//     final cached = _radarMarkerCache[color.value];
//     if (cached != null) return cached;

//     // kecil
//     const double dimension = 45;
//     final recorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(recorder);
//     final center = ui.Offset(dimension / 2, dimension / 2);

//     final outerPaint = ui.Paint()
//       ..color = color.withOpacity(0.22)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, dimension / 2, outerPaint);

//     final midPaint = ui.Paint()
//       ..color = color.withOpacity(0.28)
//       ..style = ui.PaintingStyle.stroke
//       ..strokeWidth = dimension * 0.16;
//     canvas.drawCircle(center, dimension * 0.34, midPaint);

//     final innerPaint = ui.Paint()
//       ..color = color
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, dimension * 0.18, innerPaint);

//     final corePaint = ui.Paint()
//       ..color = Colors.white.withOpacity(0.7)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, dimension * 0.08, corePaint);

//     final picture = recorder.endRecording();
//     final image = await picture.toImage(dimension.toInt(), dimension.toInt());
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     if (byteData == null) {
//       throw StateError('Failed to encode radar marker image');
//     }
//     final bytes = byteData.buffer
//         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
//     _radarMarkerCache[color.value] = bytes;
//     return bytes;
//   }

//   Future<Uint8List> _resolveCctvMarkerImage() async {
//     if (_cctvMarkerImage != null) return _cctvMarkerImage!;

//     // kecil
//     const double dimension = 64;
//     final recorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(recorder);
//     final center = ui.Offset(dimension / 2, dimension / 2);

//     final basePaint = ui.Paint()
//       ..color = const Color(0xFF1D3557)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, dimension * 0.46, basePaint);

//     final innerRingPaint = ui.Paint()
//       ..color = const Color(0xFF457B9D)
//       ..style = ui.PaintingStyle.stroke
//       ..strokeWidth = dimension * 0.06;
//     canvas.drawCircle(center, dimension * 0.34, innerRingPaint);

//     final cameraBodyRect = ui.Rect.fromCenter(
//       center: center.translate(0, -dimension * 0.03),
//       width: dimension * 0.58,
//       height: dimension * 0.32,
//     );
//     final cameraBodyPaint = ui.Paint()
//       ..color = Colors.white
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawRRect(
//       ui.RRect.fromRectAndRadius(cameraBodyRect, ui.Radius.circular(12)),
//       cameraBodyPaint,
//     );

//     final lensPaint = ui.Paint()
//       ..color = const Color(0xFF1D3557)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(
//         center.translate(0, -dimension * 0.03), dimension * 0.1, lensPaint);

//     final lensHighlightPaint = ui.Paint()
//       ..color = Colors.white.withAlpha(178)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center.translate(-dimension * 0.03, -dimension * 0.07),
//         dimension * 0.035, lensHighlightPaint);

//     final indicatorPaint = ui.Paint()
//       ..color = const Color(0xFFE63946)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(
//       cameraBodyRect.topRight - const ui.Offset(12, -12),
//       dimension * 0.04,
//       indicatorPaint,
//     );

//     final footRect = ui.Rect.fromCenter(
//       center: center.translate(0, dimension * 0.18),
//       width: dimension * 0.32,
//       height: dimension * 0.12,
//     );
//     canvas.drawRRect(
//       ui.RRect.fromRectAndRadius(footRect, ui.Radius.circular(10)),
//       cameraBodyPaint,
//     );

//     final stemPaint = ui.Paint()
//       ..color = Colors.white
//       ..style = ui.PaintingStyle.fill;
//     final stemRect = ui.Rect.fromCenter(
//       center: center.translate(0, dimension * 0.08),
//       width: dimension * 0.1,
//       height: dimension * 0.16,
//     );
//     canvas.drawRRect(
//       ui.RRect.fromRectAndRadius(stemRect, ui.Radius.circular(6)),
//       stemPaint,
//     );

//     final picture = recorder.endRecording();
//     final image = await picture.toImage(dimension.toInt(), dimension.toInt());
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     if (byteData == null) {
//       throw StateError('Failed to encode CCTV marker image');
//     }
//     final bytes = byteData.buffer
//         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
//     _cctvMarkerImage = bytes;
//     return bytes;
//   }

//   Future<Uint8List> _resolveDestinationMarkerImage() async {
//     if (_destinationMarkerImage != null) {
//       return _destinationMarkerImage!;
//     }

//     const double width = 64;
//     const double height = 86; 
//     final recorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(recorder);

//     final path = ui.Path()
//       ..moveTo(width / 2, height * 0.08)
//       ..quadraticBezierTo(width * 0.92, height * 0.34, width / 2, height * 0.96)
//       ..quadraticBezierTo(width * 0.08, height * 0.34, width / 2, height * 0.08)
//       ..close();

//     final gradient = ui.Gradient.linear(
//       ui.Offset(width / 2, height * 0.08),
//       ui.Offset(width / 2, height * 0.9),
//       const [Color(0xFF2563EB), Color(0xFF1E3A8A)],
//     );

//     final basePaint = ui.Paint()
//       ..shader = gradient
//       ..style = ui.PaintingStyle.fill;

//     canvas.drawShadow(path, Colors.black.withOpacity(0.25), 6, true);
//     canvas.drawPath(path, basePaint);

//     final innerCirclePaint = ui.Paint()
//       ..color = Colors.white
//       ..style = ui.PaintingStyle.fill;

//     final center = ui.Offset(width / 2, height * 0.38);
//     canvas.drawCircle(center, width * 0.18, innerCirclePaint);

//     final corePaint = ui.Paint()
//       ..color = const Color(0xFF2563EB)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, width * 0.1, corePaint);

//     final highlightPaint = ui.Paint()
//       ..color = Colors.white.withOpacity(0.35)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center.translate(-width * 0.05, -width * 0.05),
//         width * 0.05, highlightPaint);

//     final picture = recorder.endRecording();
//     final image = await picture.toImage(width.toInt(), height.toInt());
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     if (byteData == null) {
//       throw StateError('Failed to encode destination marker image');
//     }

//     final bytes = byteData.buffer
//         .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
//     _destinationMarkerImage = bytes;
//     return bytes;
//   }

//   Future<void> updateUserLocationAnnotation({
//     required ll.LatLng? userLocation,
//     required Uint8List? userLocationImage,
//     required double? userHeading,
//   }) async {
//     final manager = pointManager;
//     if (manager == null) return;

//     if (userLocation == null) {
//       if (_userAnnotation != null) {
//         try {
//           await manager.delete(_userAnnotation!);
//         } catch (_) {}
//         _userAnnotation = null;
//       }
//       return;
//     }

//     final heading = userHeading ?? 0.0;

//     if (_userAnnotation == null) {
//       if (userLocationImage != null) {
//         final options = PointAnnotationOptions(
//           geometry: _toPoint(userLocation),
//           image: userLocationImage,
//           iconAnchor: IconAnchor.CENTER,
//           iconRotate: heading,
//           iconSize: 2.85,
//         );
//         try {
//           _userAnnotation = await pointManager!.create(options);
//           print('[MAP LIFE] created user annotation id=${_userAnnotation?.id}');
//         } catch (e, st) {
//           print('[MAP LIFE] create user annotation failed: $e\n$st');
//         }
//       } else {
//         final options = PointAnnotationOptions(
//           geometry: _toPoint(userLocation),
//           iconColor: Colors.blue.value,
//           iconAnchor: IconAnchor.CENTER,
//           iconRotate: heading,
//           iconSize: 2.85,
//         );
//         try {
//           _userAnnotation = await pointManager!.create(options);
//           print(
//               '[MAP LIFE] created user annotation (color) id=${_userAnnotation?.id}');
//         } catch (e, st) {
//           print('[MAP LIFE] create user annotation (color) failed: $e\n$st');
//         }
//       }
//       return;
//     }

//     _userAnnotation!
//       ..geometry = _toPoint(userLocation)
//       ..iconRotate = heading
//       ..iconAnchor = IconAnchor.CENTER
//       ..iconSize = 2.85;

//     try {
//       await pointManager!.update(_userAnnotation!);
//       print('[MAP LIFE] updated user annotation id=${_userAnnotation?.id}');
//     } catch (e) {
//       try {
//         await pointManager!.delete(_userAnnotation!);
//       } catch (_) {}
//       _userAnnotation = null;
//       await updateUserLocationAnnotation(
//         userLocation: userLocation,
//         userLocationImage: userLocationImage,
//         userHeading: heading,
//       );
//     }
//   }

//   Future<void> updatePolylineAnnotations({
//     required List<ll.LatLng>? primaryRoute,
//     required List<RouteLineConfig>? routeLines,
//   }) async {
//     final manager = polylineManager;
//     if (manager == null) return;

//     final desiredRouteIds = <String>{};

//     Future<void> upsertRoute({
//       required String routeId,
//       required List<ll.LatLng> points,
//       required int colorValue,
//       required double width,
//       required double opacity,
//     }) async {
//       if (points.length < 2) return;
//       desiredRouteIds.add(routeId);

//       final signature =
//           _buildRouteSignature(points, colorValue, width, opacity);
//       final existingAnnotation = _routeAnnotations[routeId];
//       final existingDescriptor = _routeDescriptors[routeId];

//       final geometry = LineString(
//         coordinates: points
//             .map((p) => Position(p.longitude, p.latitude))
//             .toList(growable: false),
//       );

//       if (existingAnnotation != null &&
//           existingDescriptor != null &&
//           existingDescriptor.signature == signature) {
//         return;
//       }

//       if (existingAnnotation != null) {
//         existingAnnotation.geometry = geometry;
//         existingAnnotation.lineColor = colorValue;
//         existingAnnotation.lineWidth = width;
//         existingAnnotation.lineOpacity = opacity;
//         try {
//           await manager.update(existingAnnotation);
//           _routeDescriptors[routeId] = _RouteDescriptor(signature: signature);
//           return;
//         } catch (e, st) {
//           print('[MAP LIFE] update polyline failed, recreating: $e\n$st');
//           try {
//             await manager.delete(existingAnnotation);
//           } catch (_) {}
//           _routeAnnotations.remove(routeId);
//           _routeDescriptors.remove(routeId);
//         }
//       }

//       final options = PolylineAnnotationOptions(
//         geometry: geometry,
//         lineColor: colorValue,
//         lineWidth: width,
//         lineOpacity: opacity,
//         lineJoin: LineJoin.ROUND,
//       );

//       try {
//         final annotation = await manager.create(options);
//         _routeAnnotations[routeId] = annotation;
//         _routeDescriptors[routeId] = _RouteDescriptor(signature: signature);
//       } catch (e, st) {
//         print('[MAP LIFE] create polyline failed: $e\n$st');
//       }
//     }

//     final configs = routeLines ?? const <RouteLineConfig>[];

//     if (configs.isNotEmpty) {
//       for (final config in configs) {
//         await upsertRoute(
//           routeId: config.id,
//           points: config.points,
//           colorValue: config.color.value,
//           width: config.width,
//           opacity: config.opacity ?? 1.0,
//         );
//       }
//     } else if (primaryRoute != null && primaryRoute.isNotEmpty) {
//       await upsertRoute(
//         routeId: '__primary__',
//         points: primaryRoute,
//         colorValue: Colors.blue.value,
//         width: 5.0,
//         opacity: 1.0,
//       );
//     }

//     final staleRouteIds = _routeAnnotations.keys
//         .where((id) => !desiredRouteIds.contains(id))
//         .toList(growable: false);
//     if (staleRouteIds.isNotEmpty) {
//       for (final id in staleRouteIds) {
//         final annotation = _routeAnnotations.remove(id);
//         _routeDescriptors.remove(id);
//         if (annotation != null) {
//           try {
//             await manager.delete(annotation);
//           } catch (e, st) {
//             print('[MAP LIFE] delete polyline failed: $e\n$st');
//           }
//         }
//       }
//     }
//   }

//   bool handleMarkerTap(PointAnnotation annotation) {
//     bool handled = false;

//     Map<String, dynamic>? data;
//     final rawData = _markerDataById[annotation.id];
//     if (rawData != null) {
//       data = Map<String, dynamic>.from(rawData);
//     }

//     if (data != null && widget.onMarkerDataTap != null) {
//       try {
//         widget.onMarkerDataTap!(data);
//         handled = true;
//       } catch (_) {}
//     }

//     int? index = markerTapIndex[annotation.id];
//     if (index == null && widget.markers != null && widget.markers!.isNotEmpty) {
//       final geom = annotation.geometry;
//       final tappedLat = geom.coordinates.lat;
//       final tappedLng = geom.coordinates.lng;
//       for (var i = 0; i < widget.markers!.length; i++) {
//         final point = widget.markers![i];
//         final latDiff = (point.latitude - tappedLat).abs();
//         final lngDiff = (point.longitude - tappedLng).abs();
//         if (latDiff < 0.00005 && lngDiff < 0.00005) {
//           index = i;
//           break;
//         }
//       }
//     }

//     if (index != null) {
//       if (!handled && widget.onMarkerDataTap != null) {
//         final dataList = widget.markerData;
//         if (dataList != null && index >= 0 && index < dataList.length) {
//           try {
//             widget.onMarkerDataTap!(
//               Map<String, dynamic>.from(dataList[index]),
//             );
//             handled = true;
//           } catch (_) {}
//         }
//       }

//       if (widget.onMarkerTap != null) {
//         try {
//           widget.onMarkerTap!(index);
//           handled = true;
//         } catch (_) {}
//       }
//     }

//     if (handled) {
//       _lastHandledAnnotationId = annotation.id;
//       _lastHandledAnnotationTime = DateTime.now();
//     }

//     return handled;
//   }

//   void disposeAnnotations() {
//     print('[MAP LIFE] disposeAnnotations called');
//     try {
//       _tapCancelable?.cancel();
//     } catch (_) {}
//     try {
//       pointManager?.deleteAll();
//     } catch (_) {}
//     try {
//       polylineManager?.deleteAll();
//     } catch (_) {}
//     markerTapIndex.clear();
//     _markerDataById.clear();
//     _markerAnnotations.clear();
//     _markerDescriptors.clear();
//     _waypointAnnotations.clear();
//     _waypointPositions.clear();
//     _tapCancelable = null;
//     pointManager = null;
//     userPointManager = null;
//     polylineManager = null;
//     _userAnnotation = null;
//     _floodAnnotations.clear();
//     _routeAnnotations.clear();
//     _routeDescriptors.clear();
//     _radarMarkerCache.clear();
//     _cctvMarkerImage = null;
//     _lastAppliedRadarScale = null;
//     _radarUpdateScheduled = false;
//     _queuedRadarScale = 1.0;
//   }
// }

// class _MapboxReusableMapState extends State<MapboxReusableMap>
//     with TickerProviderStateMixin, _MapboxAnnotationMixin {
//   MapboxMap? _map;
//   bool _mapReady = false;
//   bool _styleAttempted = false;
//   final ll.LatLng _fallback = ll.LatLng(-6.200000, 106.816666);
//   bool _hasCenteredOnUser = false;
//   ll.LatLng? _lastCenteredUserLocation;
//   static const double _tapHitSlopPx = 64.0;
//   static const double _routeTapThresholdMeters = 80;

//   Uint8List? _lastUserImage;
//   int? _lastUserImageHeadingBucket;
//   bool _applied3DCamera = false;
//   static const String _buildingsLayerId = 'jir-3d-buildings';
//   bool _buildingsLayerAdded = false;
//   double? _lastNavigationBearing;
//   double? _lastNavigationPitch;
//   DateTime? _lastNavigationUpdate;
//   static const Duration _navigationUpdateInterval = Duration(milliseconds: 700);

//   late final AnimationController _radarAnim;
//   Timer? _updateDebounce;

//   @override
//   void initState() {
//     super.initState();
//     _radarAnim = AnimationController(
//       vsync: this,
//       duration: const Duration(
//           milliseconds: 3000), // lebih lama => lebih sedikit update
//     )..addListener(() {
//         final t = _radarAnim.value;
//         final eased = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
//         final scale = radarMinScale + (radarMaxScale - radarMinScale) * eased;
//         updateRadarAnimation(scale);
//       });
//   }

//   void _maybeStartRadarAnim() {
//     try {
//       if (_floodAnnotations.isNotEmpty) {
//         if (!_radarAnim.isAnimating) _radarAnim.repeat();
//       } else {
//         if (_radarAnim.isAnimating) _radarAnim.stop();
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   void scheduleUpdateAll({int ms = 350}) {
//     _updateDebounce?.cancel();
//     _updateDebounce = Timer(Duration(milliseconds: ms), () async {
//       if (_mapReady && _map != null) {
//         try {
//           await ensureAnnotationManagers(_map!, (annotation) {
//             try {
//               return handleMarkerTap(annotation);
//             } catch (_) {
//               return false;
//             }
//           });
//           await _updateAll();
//         } catch (e, st) {
//           print('[MAP LIFE] debounced updateAll failed: $e\n$st');
//         }
//       }
//     });
//   }

//   Future<void> _onMapCreated(MapboxMap mapboxMap) async {
//     _map = mapboxMap;
//     print('[MAP LIFE] _onMapCreated called');

//     if (!_styleAttempted) {
//       try {
//         print('[MAP LIFE] loading styleUri=${widget.styleUri}');
//         await _map!.loadStyleURI(widget.styleUri);
//         print('[MAP LIFE] loadStyleURI finished');
//       } catch (e, st) {
//         print('[MAP LIFE] loadStyleURI error: $e\n$st');
//       }
//       _styleAttempted = true;
//     }

//     int tries = 0;
//     while (tries < 12) {
//       tries++;
//       try {
//         print('[MAP LIFE] ensureAnnotationManagers attempt #$tries');
//         await ensureAnnotationManagers(_map!, (annotation) {
//           try {
//             return handleMarkerTap(annotation);
//           } catch (_) {
//             return false;
//           }
//         });

//         _mapReady = true;

//         print('[MAP LIFE] managers ready, calling _updateAll');

//         await _updateAll();

//         print('[MAP LIFE] _updateAll finished');

//         widget.onMapCreated?.call(_map!);

//         setState(() {});
//         await _apply3DSettingsIfNeeded();
//         await _configureOrnaments();
//         return;
//       } catch (e, st) {
//         print('[MAP LIFE] ensureAnnotationManagers failed: $e\n$st');
//         await Future.delayed(const Duration(milliseconds: 250));
//       }
//     }

//     print('[MAP LIFE] _onMapCreated giving up after $tries tries');
//     setState(() {});
//   }

//   void _handleMapTap(MapContentGestureContext context) {
//     unawaited(_handleMapTapInternal(context));
//   }

//   Future<void> _handleMapTapInternal(MapContentGestureContext context) async {
//     if (!_mapReady || _map == null) return;
//     if (context.gestureState != GestureState.ended) return;

//     bool markerHandled = false;

//     if (_floodAnnotations.isNotEmpty) {
//       final tapPosition = context.touchPosition;
//       PointAnnotation? closest;
//       double closestDistance = double.infinity;

//       for (final annotation in List<PointAnnotation>.from(_floodAnnotations)) {
//         try {
//           final screen = await _map!.pixelForCoordinate(annotation.geometry);
//           final dx = screen.x - tapPosition.x;
//           final dy = screen.y - tapPosition.y;
//           final distance = math.sqrt(dx * dx + dy * dy);
//           if (distance < closestDistance) {
//             closestDistance = distance;
//             closest = annotation;
//           }
//         } catch (_) {}
//       }

//       if (closest != null && closestDistance <= _tapHitSlopPx) {
//         final recentlyHandled = _lastHandledAnnotationId == closest.id &&
//             _lastHandledAnnotationTime != null &&
//             DateTime.now().difference(_lastHandledAnnotationTime!) <
//                 const Duration(milliseconds: 350);

//         if (!recentlyHandled) {
//           markerHandled = handleMarkerTap(closest);
//         } else {
//           markerHandled = true;
//         }
//       }
//     }

//     if (!markerHandled &&
//         widget.routeLines != null &&
//         widget.routeLines!.isNotEmpty &&
//         widget.onRouteTap != null) {
//       try {
//         final tappedPoint =
//             await _map!.coordinateForPixel(context.touchPosition);
//         final tappedRouteId = _detectRouteTap(
//           ll.LatLng(
//             tappedPoint.coordinates.lat.toDouble(),
//             tappedPoint.coordinates.lng.toDouble(),
//           ),
//         );
//         if (tappedRouteId != null) {
//           widget.onRouteTap!(tappedRouteId);
//         }
//       } catch (_) {}
//     }
//   }

//   String? _detectRouteTap(ll.LatLng tapLatLng) {
//     final configs = widget.routeLines;
//     if (configs == null || configs.isEmpty) return null;

//     final distanceCalculator = const ll.Distance();
//     double bestDistance = double.infinity;
//     String? bestId;

//     for (final config in configs) {
//       for (final point in config.points) {
//         final distance = distanceCalculator(tapLatLng, point);
//         if (distance < bestDistance) {
//           bestDistance = distance;
//           bestId = config.id;
//         }
//       }
//     }

//     if (bestId != null && bestDistance <= _routeTapThresholdMeters) {
//       return bestId;
//     }

//     return null;
//   }

//   Future<void> _updateAll() async {
//     if (!_mapReady || _map == null) return;

//     await updatePointAnnotations(
//       markers: widget.markers,
//       markerData: widget.markerData,
//       waypoints: widget.waypoints,
//       destination: widget.destination,
//       onMarkerTap: widget.onMarkerTap,
//     );

//     _maybeStartRadarAnim();

//     await updatePolylineAnnotations(
//       primaryRoute: widget.routePoints,
//       routeLines: widget.routeLines,
//     );

//     await _fitToBounds();

//     final userImg = await _generateAndCacheUserImage(widget.userHeading);
//     await updateUserLocationAnnotation(
//       userLocation: widget.userLocation,
//       userLocationImage: userImg,
//       userHeading: widget.userHeading,
//     );
//     await _centerOnUserIfNeeded();
//     await _apply3DSettingsIfNeeded();
//     await _applyNavigationCameraIfNeeded();
//     await _configureOrnaments();
//   }

//   Future<void> _apply3DSettingsIfNeeded() async {
//     if (!_mapReady || _map == null) return;
//     final wants3D = widget.enable3DBuildings ||
//         (widget.initialPitch != null && widget.initialPitch != 0);
//     if (!wants3D) {
//       return;
//     }

//     if (!_applied3DCamera &&
//         (widget.initialPitch != null || widget.initialBearing != null)) {
//       try {
//         final state = await _map!.getCameraState();
//         await _map!.setCamera(
//           CameraOptions(
//             center: state.center,
//             zoom: state.zoom,
//             pitch: widget.initialPitch ?? state.pitch,
//             bearing: widget.initialBearing ?? state.bearing,
//           ),
//         );
//         _applied3DCamera = true;
//       } catch (e, st) {
//         print('[MAP LIFE] apply3D camera failed: $e\n$st');
//       }
//     }

//     if (widget.enable3DBuildings && !_buildingsLayerAdded) {
//       await _ensure3DBuildings();
//     }
//   }

//   Future<void> _applyNavigationCameraIfNeeded() async {
//     if (!_mapReady || _map == null) return;
//     if (!widget.autoPitchOnRoute) {
//       _lastNavigationBearing = null;
//       _lastNavigationPitch = null;
//       _lastNavigationUpdate = null;
//       return;
//     }

//     final route = widget.routePoints;
//     final user = widget.userLocation;
//     if (route == null || route.length < 2 || user == null) {
//       _lastNavigationBearing = null;
//       _lastNavigationPitch = null;
//       _lastNavigationUpdate = null;
//       return;
//     }

//     if (_lastNavigationUpdate != null &&
//         DateTime.now().difference(_lastNavigationUpdate!) <
//             _navigationUpdateInterval) {
//       return;
//     }

//     final nextPoint = _resolveNextRoutePoint(user, route);
//     if (nextPoint == null) {
//       return;
//     }

//     final bearing = _bearingBetween(user, nextPoint);
//     final pitch = widget.navigationPitch;

//     try {
//       final currentState = await _map!.getCameraState();
//       final zoomTarget = widget.navigationZoom ??
//           math.max(currentState.zoom, widget.initialZoom);

//       if (_lastNavigationBearing != null &&
//           (bearing - _lastNavigationBearing!).abs() < 1.5 &&
//           _lastNavigationPitch != null &&
//           (_lastNavigationPitch! - pitch).abs() < 1.0 &&
//           _lastNavigationUpdate != null &&
//           DateTime.now().difference(_lastNavigationUpdate!) <
//               _navigationUpdateInterval) {
//         return;
//       }

//       await _map!.easeTo(
//         CameraOptions(
//           center: _toPoint(user),
//           zoom: zoomTarget,
//           pitch: pitch,
//           bearing: bearing,
//         ),
//         MapAnimationOptions(duration: 600),
//       );

//       _lastNavigationBearing = bearing;
//       _lastNavigationPitch = pitch;
//       _lastNavigationUpdate = DateTime.now();
//     } catch (e, st) {
//       print('[MAP LIFE] applyNavigationCamera failed: $e\n$st');
//     }
//   }

//   ll.LatLng? _resolveNextRoutePoint(
//       ll.LatLng user, List<ll.LatLng> routePoints) {
//     if (routePoints.length < 2) {
//       return null;
//     }

//     final distance = ll.Distance();
//     double nearestDistance = double.infinity;
//     int nearestIndex = 0;

//     for (var i = 0; i < routePoints.length; i++) {
//       final current = routePoints[i];
//       final d = distance(user, current);
//       if (d < nearestDistance) {
//         nearestDistance = d;
//         nearestIndex = i;
//       }
//     }

//     if (nearestIndex < routePoints.length - 1) {
//       return routePoints[nearestIndex + 1];
//     }

//     if (nearestIndex > 0) {
//       return routePoints[nearestIndex - 1];
//     }

//     return routePoints.first;
//   }

//   double _bearingBetween(ll.LatLng start, ll.LatLng end) {
//     final lat1 = _degToRad(start.latitude);
//     final lat2 = _degToRad(end.latitude);
//     final deltaLon = _degToRad(end.longitude - start.longitude);

//     final y = math.sin(deltaLon) * math.cos(lat2);
//     final x = math.cos(lat1) * math.sin(lat2) -
//         math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
//     var bearing = math.atan2(y, x);
//     bearing = (bearing * 180 / math.pi + 360) % 360;
//     return bearing;
//   }

//   double _degToRad(double degrees) => degrees * (math.pi / 180);

//   Future<void> _configureOrnaments() async {
//     if (_map == null) return;
//     try {
//       await _map!.compass.updateSettings(
//         CompassSettings(
//           position: OrnamentPosition.TOP_LEFT,
//           marginLeft: 16,
//           marginTop: 112,
//           marginRight: 0,
//           marginBottom: 0,
//         ),
//       );
//     } catch (e, st) {
//       print('[MAP LIFE] configureOrnaments failed: $e\n$st');
//     }
//   }

//   Future<void> _ensure3DBuildings() async {
//     if (_map == null) {
//       return;
//     }
//     try {
//       final style = _map!.style;
//       final layerExists = await style.styleLayerExists(_buildingsLayerId);
//       if (!layerExists) {
//         final layer = FillExtrusionLayer(
//           id: _buildingsLayerId,
//           sourceId: 'composite',
//         )
//           ..sourceLayer = 'building'
//           ..minZoom = 15
//           ..filter = [
//             'all',
//             [
//               '==',
//               ['get', 'extrude'],
//               'true'
//             ],
//             [
//               '>=',
//               ['get', 'height'],
//               0
//             ],
//           ]
//           ..fillExtrusionColor = 0xFFB8C1D6
//           ..fillExtrusionOpacity = 0.65
//           ..fillExtrusionHeight = 36.0
//           ..fillExtrusionBase = 0.0;

//         await style.addLayer(layer);
//       }
//       _buildingsLayerAdded = true;
//     } catch (e, st) {
//       print('[MAP LIFE] ensure3DBuildings error: $e\n$st');
//     }
//   }

//   Future<Uint8List?> _generateAndCacheUserImage(double? heading) async {
//     if (heading == null) {
//       if (_lastUserImage != null && _lastUserImageHeadingBucket == 0) {
//         return _lastUserImage;
//       }
//       final bytes = await _renderUserMarkerPng(0);
//       _lastUserImage = bytes;
//       _lastUserImageHeadingBucket = 0;
//       return bytes;
//     }

//     final bucketSize = 20; // lebih besar => lebih jarang regenerate
//     final bucket = (heading / bucketSize).round();
//     if (_lastUserImage != null && _lastUserImageHeadingBucket == bucket) {
//       return _lastUserImage;
//     }
//     final bytes = await _renderUserMarkerPng(heading);
//     _lastUserImage = bytes;
//     _lastUserImageHeadingBucket = bucket;
//     return bytes;
//   }

//   Future<Uint8List> _renderUserMarkerPng(double headingDeg,
//       {int dimension = 64}) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(recorder,
//         Rect.fromLTWH(0, 0, dimension.toDouble(), dimension.toDouble()));
//     final center = ui.Offset(dimension / 2, dimension / 2);

//     final ringPaint = ui.Paint()
//       ..color = Colors.blue.withOpacity(0.18)
//       ..style = ui.PaintingStyle.fill;
//     canvas.drawCircle(center, dimension * 0.45, ringPaint);

//     canvas.save();
//     canvas.translate(center.dx, center.dy);
//     canvas.rotate(headingDeg * (math.pi / 180));
//     final path = ui.Path();
//     path.moveTo(0, -dimension * 0.22);
//     path.lineTo(-dimension * 0.08, 0);
//     path.lineTo(dimension * 0.08, 0);
//     path.close();
//     final triPaint = ui.Paint()..color = Colors.blue.shade700;
//     canvas.drawPath(path, triPaint);
//     canvas.restore();

//     final centerPaint = ui.Paint()..color = Colors.blue.shade700;
//     canvas.drawCircle(center, dimension * 0.12, centerPaint);

//     final borderPaint = ui.Paint()
//       ..color = Colors.white
//       ..style = ui.PaintingStyle.stroke
//       ..strokeWidth = 2;
//     canvas.drawCircle(center, dimension * 0.12, borderPaint);

//     final picture = recorder.endRecording();
//     final img = await picture.toImage(dimension, dimension);
//     final bd = await img.toByteData(format: ui.ImageByteFormat.png);
//     return bd!.buffer.asUint8List();
//   }

//   Future<void> _fitToBounds() async {
//     if (_map == null) return;
//     if (_hasCenteredOnUser && widget.userLocation != null) return;
//     final all = <ll.LatLng>[];
//     if (widget.routeLines != null) {
//       for (final line in widget.routeLines!) {
//         all.addAll(line.points);
//       }
//     }
//     if (widget.routePoints != null) all.addAll(widget.routePoints!);
//     if (widget.markers != null) all.addAll(widget.markers!);
//     if (widget.waypoints != null) all.addAll(widget.waypoints!);
//     if (widget.userLocation != null) all.add(widget.userLocation!);
//     if (all.isEmpty) return;
//     double minLat = all.first.latitude, maxLat = all.first.latitude;
//     double minLng = all.first.longitude, maxLng = all.first.longitude;
//     for (final p in all) {
//       if (p.latitude < minLat) minLat = p.latitude;
//       if (p.latitude > maxLat) maxLat = p.latitude;
//       if (p.longitude < minLng) minLng = p.longitude;
//       if (p.longitude > maxLng) maxLng = p.longitude;
//     }
//     final center = Point(
//         coordinates: Position((minLng + maxLng) / 2, (minLat + maxLat) / 2));
//     final zoom = _calcZoom(minLat, maxLat, minLng, maxLng);
//     try {
//       await _map!.flyTo(CameraOptions(center: center, zoom: zoom),
//           MapAnimationOptions(duration: 700));
//     } catch (_) {}
//   }

//   double _calcZoom(double minLat, double maxLat, double minLng, double maxLng) {
//     final latDiff = maxLat - minLat;
//     final lngDiff = maxLng - minLng;
//     final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
//     if (maxDiff > 10) return 5.0;
//     if (maxDiff > 5) return 7.0;
//     if (maxDiff > 2) return 9.0;
//     if (maxDiff > 1) return 11.0;
//     if (maxDiff > 0.5) return 12.0;
//     if (maxDiff > 0.1) return 13.0;
//     return widget.initialZoom;
//   }

//   ll.LatLng _resolveInitialCenter() {
//     if (widget.initialLocation != null) {
//       return widget.initialLocation!;
//     }
//     if (widget.userLocation != null) {
//       return widget.userLocation!;
//     }
//     if (widget.markers != null && widget.markers!.isNotEmpty) {
//       return widget.markers!.first;
//     }
//     if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
//       return widget.routePoints!.first;
//     }
//     if (widget.routeLines != null) {
//       for (final line in widget.routeLines!) {
//         if (line.points.isNotEmpty) {
//           return line.points.first;
//         }
//       }
//     }
//     if (widget.waypoints != null && widget.waypoints!.isNotEmpty) {
//       return widget.waypoints!.first;
//     }
//     return _fallback;
//   }

//   Future<void> _centerOnUserIfNeeded() async {
//     if (_map == null || !_mapReady) return;
//     final user = widget.userLocation;
//     if (user == null) return;
//     if (_hasCenteredOnUser && _lastCenteredUserLocation != null) {
//       return;
//     }
//     try {
//       await _map!.flyTo(
//         CameraOptions(center: _toPoint(user), zoom: 15.0),
//         MapAnimationOptions(duration: 600),
//       );
//       _hasCenteredOnUser = true;
//       _lastCenteredUserLocation = user;
//     } catch (_) {}
//   }

//   @override
//   void didUpdateWidget(covariant MapboxReusableMap oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     print(
//         '[MAP LIFE] didUpdateWidget called. oldMarkers=${oldWidget.markers?.length ?? 0} newMarkers=${widget.markers?.length ?? 0}');

//     if (oldWidget.userLocation == null && widget.userLocation != null) {
//       _hasCenteredOnUser = false;
//       _lastCenteredUserLocation = null;
//     }
//     if (widget.userLocation == null) {
//       _hasCenteredOnUser = false;
//       _lastCenteredUserLocation = null;
//     }

//     if (_mapReady && _map != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         scheduleUpdateAll();
//       });
//     }

//     if (oldWidget.onMarkerTap != widget.onMarkerTap && _map != null) {
//       ensureAnnotationManagers(_map!, (annotation) {
//         try {
//           return handleMarkerTap(annotation);
//         } catch (_) {
//           return false;
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     try {
//       disposeAnnotations();
//     } catch (_) {}
//     _updateDebounce?.cancel();
//     try {
//       if (_radarAnim.isAnimating) _radarAnim.stop();
//     } catch (_) {}
//     _radarAnim.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final center = _resolveInitialCenter();
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: [
//             MapWidget(
//               key: ValueKey(widget.accessToken + widget.styleUri),
//               styleUri: widget.styleUri,
//               cameraOptions: CameraOptions(
//                 center: _toPoint(center),
//                 zoom: widget.initialZoom,
//                 pitch: widget.initialPitch,
//                 bearing: widget.initialBearing,
//               ),
//               onMapCreated: _onMapCreated,
//               onTapListener: _handleMapTap,
//             ),
//             if (!_mapReady)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.white,
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             Positioned(
//               right: 16,
//               bottom: 20,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   FloatingActionButton(
//                     backgroundColor: Colors.white,
//                     heroTag: 'zoom_in',
//                     mini: true,
//                     onPressed: () async {
//                       if (_map == null) return;
//                       try {
//                         final state = await _map!.getCameraState();
//                         await _map!.setCamera(
//                           CameraOptions(zoom: state.zoom + 1),
//                         );
//                       } catch (_) {}
//                     },
//                     child: const Icon(Icons.add, color: Colors.black),
//                   ),
//                   const SizedBox(height: 8),
//                   FloatingActionButton(
//                     backgroundColor: Colors.white,
//                     heroTag: 'zoom_out',
//                     mini: true,
//                     onPressed: () async {
//                       if (_map == null) return;
//                       try {
//                         final state = await _map!.getCameraState();
//                         await _map!.setCamera(
//                           CameraOptions(zoom: state.zoom - 1),
//                         );
//                       } catch (_) {}
//                     },
//                     child: const Icon(Icons.remove, color: Colors.black),
//                   ),
//                   const SizedBox(height: 8),
//                   FloatingActionButton(
//                     backgroundColor: Colors.white,
//                     heroTag: 'center',
//                     mini: true,
//                     onPressed: () async {
//                       if (_map == null) return;
//                       final loc = widget.userLocation ??
//                           widget.initialLocation ??
//                           _fallback;
//                       try {
//                         await _map!.flyTo(
//                           CameraOptions(center: _toPoint(loc), zoom: 15),
//                           MapAnimationOptions(duration: 700),
//                         );
//                       } catch (_) {}
//                     },
//                     child: const Icon(Icons.my_location, color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
