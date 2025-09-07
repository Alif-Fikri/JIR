import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'chat_service.dart';

class RouteControllerForChat extends GetxController
    with GetTickerProviderStateMixin {
  var userLocation = Rx<LatLng?>(null);
  var startLocation = Rx<LatLng?>(null);
  var endLocation = Rx<LatLng?>(null);
  var polylinePoints = <LatLng>[].obs;
  var waypoints = <LatLng>[].obs;
  var steps = <Map<String, dynamic>>[].obs;
  var activeStepIndex = 0.obs;
  var userHeading = 0.0.obs;
  var floodMarkers = <LatLng>[].obs;
  var isNavigating = false.obs;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassSubscription;

  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  final FlutterTts tts = FlutterTts();
  final Distance distanceCalculator = Distance();

  @override
  void onInit() {
    super.onInit();
    _initLocation();
    _initCompass();
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  void _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location service disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied permanently');
      }

      final pos = await Geolocator.getCurrentPosition();
      userLocation.value = LatLng(pos.latitude, pos.longitude);

      _positionStream =
          Geolocator.getPositionStream(distanceFilter: 5).listen((p) {
        userLocation.value = LatLng(p.latitude, p.longitude);
        if (isNavigating.value) _checkNextStep();
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal mendapatkan lokasi: $e");
    }
  }

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) userHeading.value = event.heading!;
    });
  }

  Future<void> loadRouteFromChat(String message) async {
    try {
      final data = await ChatService.getChatResponse(message);

      if (data.containsKey('start') && data.containsKey('end')) {
        final start = data['start']['coords'];
        final end = data['end']['coords'];
        final wps = data['waypoints'] as List<dynamic>? ?? [];
        final stepData = data['steps'] as List<dynamic>? ?? [];

        startLocation.value = LatLng(start[0], start[1]);
        endLocation.value = LatLng(end[0], end[1]);
        waypoints.value =
            wps.map((wp) => LatLng(wp[0] as double, wp[1] as double)).toList();
        polylinePoints.value = [
          startLocation.value!,
          ...waypoints,
          endLocation.value!,
        ];

        steps.value = stepData
            .map<Map<String, dynamic>>((s) => {
                  'instruction': s['instruction'],
                  'distance': s['distance'],
                  'coords': s['coords'],
                })
            .toList();

        activeStepIndex.value = 0;
      } else {
        Get.snackbar("Chatbot", "Tidak ada rute ditemukan");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void startNavigation() {
    if (steps.isEmpty) return;
    isNavigating.value = true;
    _speakCurrentStep();
  }

  void stopNavigation() {
    isNavigating.value = false;
    tts.stop();
  }

  void _checkNextStep() async {
    if (!isNavigating.value || userLocation.value == null) return;
    final currentStep = steps[activeStepIndex.value];
    final stepCoord =
        LatLng(currentStep['coords'][0], currentStep['coords'][1]);

    final distance = distanceCalculator.as(
      LengthUnit.Meter,
      userLocation.value!,
      stepCoord,
    );

    if (distance < 15) {
      if (activeStepIndex.value < steps.length - 1) {
        activeStepIndex.value++;
        _speakCurrentStep();
      } else {
        stopNavigation();
        Get.snackbar("Selesai", "Anda telah tiba di tujuan");
      }
    }
  }

  Future<void> _speakCurrentStep() async {
    await tts.stop();
    final step = steps[activeStepIndex.value];
    await tts.speak(step['instruction'] ?? '');
  }

  void setFloodMarkers(List<LatLng> markers) {
    floodMarkers.value = markers;
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _compassSubscription?.cancel();
    pulseController.dispose();
    tts.stop();
    super.onClose();
  }
}
