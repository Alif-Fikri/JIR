part of 'route_controller.dart';

extension RouteControllerNavigation on RouteController {
  void _startLocationUpdates() {
    try {
      _positionStream = Geolocator.getPositionStream().listen((position) async {
        final currentLocation = LatLng(position.latitude, position.longitude);
        userLocation(currentLocation);
        _updateRemainingMetrics(currentLocation);

        final now = DateTime.now();
        if (now.difference(_lastCheck).inSeconds.abs() > 10) {
          _checkRouteDeviation(currentLocation);
          _lastCheck = now;
        }
      });
    } catch (e, st) {
      _logError(e, st);
    }
  }

  void _checkRouteDeviation(LatLng currentLocation) async {
    try {
      if (routePoints.isEmpty || destination.value == null) return;

      startPoint ??= userLocation.value;

      final nearestPointOnRoute =
          _findNearestPoint(currentLocation, routePoints);
      final distanceToRoute = RouteController.calculateDistance(
        currentLocation,
        nearestPointOnRoute,
      );

      final totalDistance =
          RouteController.calculateDistance(startPoint!, destination.value!);
      final remainingDistance = RouteController.calculateDistance(
        currentLocation,
        destination.value!,
      );

      if (remainingDistance < totalDistance * 0.2) return;

      if (distanceToRoute > 50) {
        await _fetchNewRoute(currentLocation, destination.value!);
      }

      _updateRemainingMetrics(currentLocation);
    } catch (e, st) {
      _logError(e, st);
    }
  }

  LatLng _findNearestPoint(LatLng point, List<LatLng> route) {
    LatLng nearest = route.first;
    double minDistance = double.maxFinite;

    for (final routePoint in route) {
      final dist = RouteController.calculateDistance(point, routePoint);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = routePoint;
      }
    }
    return nearest;
  }

  int? _findNearestPointIndex(LatLng point, List<LatLng> route) {
    if (route.isEmpty) return null;

    int nearestIndex = 0;
    double minDistance = double.maxFinite;

    for (int i = 0; i < route.length; i++) {
      final dist = RouteController.calculateDistance(point, route[i]);
      if (dist < minDistance) {
        minDistance = dist;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  void _startCompassUpdates() {
    try {
      if (_compassSubscription != null) {
        return;
      }

      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (event.heading == null) {
          return;
        }
        final double heading = event.heading!;
        userHeading(heading);
      }, onError: (error) {});
    } catch (e, st) {
      _logError(e, st);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showUserMessage('Lokasi tidak aktif',
            'Layanan lokasi perangkat Anda tidak aktif. Aktifkan lokasi lalu coba lagi.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showUserMessage('Izin Lokasi Ditolak',
              'Aplikasi membutuhkan izin lokasi untuk menampilkan peta di posisi Anda.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showUserMessage('Izin Lokasi Permanen Ditolak',
            'Mohon aktifkan izin lokasi di pengaturan perangkat.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      userLocation(LatLng(position.latitude, position.longitude));
      _updateRemainingMetrics(userLocation.value);
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Tidak dapat mengambil lokasi',
        'Gagal mendapatkan lokasi. Periksa pengaturan lokasi dan coba lagi.',
      );
    }
  }

  Future<bool> _ensureUserLocation({bool silent = false}) async {
    if (userLocation.value != null) {
      return true;
    }
    await _getUserLocation();
    if (userLocation.value == null && !silent) {
      _showUserMessage(
        'Lokasi pengguna tidak tersedia',
        'Aktifkan layanan lokasi dan coba lagi.',
      );
    }
    return userLocation.value != null;
  }

  void _updateRemainingMetrics(LatLng? currentLocation) {
    if (currentLocation == null || routePoints.isEmpty) {
      return;
    }

    final index = _findNearestPointIndex(currentLocation, routePoints);
    if (index == null) {
      return;
    }

    double distanceToNextPoint = RouteController.calculateDistance(
      currentLocation,
      routePoints[index],
    );

    double remainingDistance = distanceToNextPoint;
    for (int i = index; i < routePoints.length - 1; i++) {
      remainingDistance += RouteController.calculateDistance(
        routePoints[i],
        routePoints[i + 1],
      );
    }

    remainingRouteDistance.value =
        remainingDistance.clamp(0, totalRouteDistance.value).toDouble();

    if (totalRouteDistance.value > 0) {
      final ratio = remainingRouteDistance.value / totalRouteDistance.value;
      remainingRouteDuration.value = (totalRouteDuration.value * ratio)
          .clamp(0, totalRouteDuration.value)
          .toDouble();
    } else {
      remainingRouteDuration.value = 0;
    }

    final distanceCovered =
        (totalRouteDistance.value - remainingRouteDistance.value)
            .clamp(0, totalRouteDistance.value);
    double accumulated = 0;
    String instruction = '';

    for (final step in routeSteps) {
      final stepDistance = (step['distance'] as num?)?.toDouble() ?? 0.0;
      accumulated += stepDistance;
      if (accumulated >= distanceCovered) {
        instruction = step['instruction']?.toString() ?? '';
        break;
      }
    }

    nextInstruction.value = instruction;

    if (remainingRouteDistance.value <= 30) {
      remainingRouteDistance.value = 0;
      remainingRouteDuration.value = 0;
      nextInstruction.value = 'Anda telah tiba di tujuan';
      if (routePoints.isNotEmpty) {
        routePoints.clear();
      }
      if (optimizedWaypoints.isNotEmpty) {
        optimizedWaypoints.clear();
      }
      if (routeOptions.isNotEmpty) {
        routeOptions.clear();
        selectedRouteIndex.value = 0;
      }
      routeActive.value = false;
      activeRoutePolyline.clear();
    } else {
      routeActive.value = true;
      _trimActivePolyline(currentLocation);
    }

    _syncForegroundNotification();
  }

  void _trimActivePolyline(LatLng currentLocation) {
    if (activeRoutePolyline.length <= 2) {
      return;
    }

    final nearestIndex =
        _findNearestPointIndex(currentLocation, activeRoutePolyline);
    if (nearestIndex == null || nearestIndex <= 0) {
      return;
    }

    final removeCount = math.min(nearestIndex, activeRoutePolyline.length - 2);
    if (removeCount <= 0) {
      return;
    }

    activeRoutePolyline.removeRange(0, removeCount);
    activeRoutePolyline.refresh();
  }

  void _syncForegroundNotification({bool forceStart = false}) {
    if (!GetPlatform.isAndroid) {
      return;
    }

    final isActive = routeActive.value && remainingRouteDistance.value > 0;
    if (!isActive) {
      if (_foregroundServiceActive) {
        unawaited(NavigationForegroundBridge.stop());
        _foregroundServiceActive = false;
        _lastForegroundUpdate = null;
      }
      return;
    }

    final now = DateTime.now();
    if (!forceStart &&
        _lastForegroundUpdate != null &&
        now.difference(_lastForegroundUpdate!).inSeconds < 3) {
      return;
    }

    final title = destinationLabel.value.isNotEmpty
        ? destinationLabel.value
        : 'Perjalanan aktif';
    final subtitle = destinationAddress.value;
    final instruction = nextInstruction.value.isNotEmpty
        ? nextInstruction.value
        : (subtitle.isNotEmpty ? subtitle : 'Ikuti arah di aplikasi');
    final distanceText =
        RouteController.formatDistance(remainingRouteDistance.value);
    final durationText =
        RouteController.formatDuration(remainingRouteDuration.value);

    if (!_foregroundServiceActive || forceStart) {
      unawaited(NavigationForegroundBridge.start(
        title: title,
        subtitle: subtitle,
        distance: distanceText,
        duration: durationText,
        instruction: instruction,
      ));
      _foregroundServiceActive = true;
    } else {
      unawaited(NavigationForegroundBridge.update(
        title: title,
        subtitle: subtitle,
        distance: distanceText,
        duration: durationText,
        instruction: instruction,
      ));
    }

    _lastForegroundUpdate = now;
  }
}
