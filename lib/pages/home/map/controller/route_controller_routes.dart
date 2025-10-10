part of 'route_controller.dart';

extension RouteControllerRoutes on RouteController {
  Future<void> fetchOptimizedRoute() async {
    if (!await _ensureUserLocation()) {
      return;
    }

    if (destination.value == null) {
      _showUserMessage(
        'Belum ada lokasi',
        'Pastikan lokasi Anda dan tujuan telah dipilih.',
      );
      return;
    }

    if (selectedVehicle.value.isEmpty) {
      selectedVehicle.value = 'motorcycle';
    }

    startPoint = userLocation.value;
    routePoints.clear();
    routeSteps.clear();
    optimizedWaypoints.clear();
    routeOptions.clear();
    selectedRouteIndex.value = 0;
    isLoading(true);

    try {
      await _requestGoogleRoute(
        start: userLocation.value!,
        end: destination.value!,
        failureTitle: 'Gagal memuat rute',
        failureMessage: 'Gagal memuat rute. Silakan coba lagi.',
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchNewRoute(LatLng start, LatLng end) async {
    await _requestGoogleRoute(
      start: start,
      end: end,
      successTitle: 'Rute diperbarui',
      successMessage: 'Rute telah diperbarui.',
      failureTitle: 'Tidak dapat memperbarui rute',
      failureMessage: 'Rute tidak tersedia saat ini. Silakan coba lagi nanti.',
    );
  }

  Future<void> _requestGoogleRoute({
    required LatLng start,
    required LatLng end,
    String? successTitle,
    String? successMessage,
    String? failureTitle,
    String? failureMessage,
  }) async {
    if (!GoogleMapsConfig.isValid()) {
      _showUserMessage(
        'API Google Maps tidak tersedia',
        'Pastikan GOOGLE_MAPS_API_KEY sudah dikonfigurasi pada aplikasi.',
      );
      return;
    }

    final vehicle =
        selectedVehicle.value.isEmpty ? 'motorcycle' : selectedVehicle.value;
    final shouldAvoidHighways = vehicle == 'motorcycle';

    String? failureDetails;
    String? failureCode;

    final preferredOutcome = await _tryRoutesPreferredRoute(
      start: start,
      end: end,
      vehicle: vehicle,
      avoidHighways: shouldAvoidHighways,
    );

    if (preferredOutcome.success) {
      if (successTitle != null && successMessage != null) {
        _showUserMessage(successTitle, successMessage);
      }
      return;
    }

    failureDetails = preferredOutcome.message;
    failureCode = preferredOutcome.code;

    final legacyOutcome = await _tryLegacyDirections(
      start: start,
      end: end,
      avoidHighways: shouldAvoidHighways,
    );

    if (legacyOutcome.success) {
      if (successTitle != null && successMessage != null) {
        _showUserMessage(successTitle, successMessage);
      }
      return;
    }

    failureDetails ??= legacyOutcome.message;
    failureCode ??= legacyOutcome.code;

    final defaultMessage = failureMessage ??
        'Rute tidak tersedia saat ini. Silakan coba lagi nanti.';
    final detailParts = <String>[];
    final failureDetailMessage = failureDetails;
    if (failureDetailMessage != null && failureDetailMessage.isNotEmpty) {
      detailParts.add(failureDetailMessage);
    }
    final failureDetailCode = failureCode;
    if (failureDetailCode != null && failureDetailCode.isNotEmpty) {
      detailParts.add('Kode: $failureDetailCode');
    }
    final detailedMessage = detailParts.isNotEmpty
        ? '$defaultMessage\n(${detailParts.join(' — ')})'
        : defaultMessage;

    _showUserMessage(
      failureTitle ?? 'Gagal memuat rute',
      detailedMessage,
    );
  }

  Future<_RouteRequestOutcome> _tryRoutesPreferredRoute({
    required LatLng start,
    required LatLng end,
    required String vehicle,
    required bool avoidHighways,
  }) async {
    final departureTime =
        DateTime.now().toUtc().add(const Duration(minutes: 2));

    final body = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': start.latitude,
            'longitude': start.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': end.latitude,
            'longitude': end.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE_OPTIMAL',
      'computeAlternativeRoutes': true,
      'polylineQuality': 'HIGH_QUALITY',
      'extraComputations': ['TRAFFIC_ON_POLYLINE'],
      'routeModifiers': {
        'avoidHighways': avoidHighways,
        'avoidTolls': false,
        'avoidFerries': false,
      },
      'languageCode': 'id-ID',
      'departureTime': departureTime.toIso8601String(),
    };

    final fieldMask =
        'routes.distanceMeters,routes.duration,routes.staticDuration,'
        'routes.description,routes.travelAdvisory,'
        'routes.polyline.encodedPolyline,'
        'routes.legs.distanceMeters,routes.legs.duration,'
        'routes.legs.staticDuration,'
        'routes.legs.steps.distanceMeters,'
        'routes.legs.steps.staticDuration,'
        'routes.legs.steps.navigationInstruction.instructions,'
        'routes.legs.steps.navigationInstruction.maneuver,'
        'routes.legs.steps.polyline.encodedPolyline';

    final headers = _buildRoutesHeaders(fieldMask: fieldMask);

    try {
      final response = await _dio.post(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
      );

      final data = response.data as Map<String, dynamic>?;
      final routes = (data?['routes'] as List?)
              ?.whereType<Map>()
              .map((route) => route.cast<String, dynamic>())
              .toList() ??
          const <Map<String, dynamic>>[];

      if (routes.isEmpty) {
        final message = _extractGoogleErrorMessage(data) ??
            'Layanan rute tidak mengembalikan jalur.';
        return _RouteRequestOutcome.failure(message: message);
      }

      _parseRoutesPreferredData(routes);
      if (routeOptions.isEmpty) {
        return _RouteRequestOutcome.failure(
          message: 'Tidak ada rute yang dapat digunakan saat ini.',
        );
      }

      return _RouteRequestOutcome.success();
    } on DioException catch (e, st) {
      _logError(e, st, 'RoutesPreferred');
      if (e.response?.data != null) {
        debugPrint('[RouteController][RoutesPreferred][payload] '
            '${e.response?.data}');
      }
      final message = _extractGoogleErrorMessage(e.response?.data) ??
          e.message ??
          'Tidak dapat terhubung ke layanan rute.';
      final code = e.response?.statusCode?.toString();
      return _RouteRequestOutcome.failure(message: message, code: code);
    } catch (e, st) {
      _logError(e, st, 'RoutesPreferred');
      return _RouteRequestOutcome.failure(
        message: 'Terjadi kesalahan internal saat memproses rute.',
      );
    }
  }

  Future<_RouteRequestOutcome> _tryLegacyDirections({
    required LatLng start,
    required LatLng end,
    required bool avoidHighways,
  }) async {
    const url = 'https://maps.googleapis.com/maps/api/directions/json';
    final query = <String, dynamic>{
      'origin': '${start.latitude},${start.longitude}',
      'destination': '${end.latitude},${end.longitude}',
      'key': GoogleMapsConfig.apiKey,
      'alternatives': 'true',
      'language': 'id',
      'region': 'id',
      'units': 'metric',
      'mode': 'driving',
      'departure_time': 'now',
    };

    if (avoidHighways) {
      query['avoid'] = 'highways';
    }

    try {
      Map<String, dynamic>? data;
      List<dynamic>? routes;

      final response = await _dio.get(
        url,
        queryParameters: Map<String, dynamic>.from(query),
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        data = response.data as Map<String, dynamic>?;
        routes = data?['routes'] as List?;
      }

      if ((routes == null || routes.isEmpty) && avoidHighways) {
        final fallbackQuery = Map<String, dynamic>.from(query)..remove('avoid');
        final fallbackResponse = await _dio.get(
          url,
          queryParameters: fallbackQuery,
          options: Options(responseType: ResponseType.json),
        );
        if (fallbackResponse.statusCode == 200) {
          data = fallbackResponse.data as Map<String, dynamic>?;
          routes = data?['routes'] as List?;
        }
      }

      if (data == null || routes == null || routes.isEmpty) {
        final status = (data?['status'] ?? response.statusCode)?.toString();
        final message = _extractGoogleErrorMessage(data) ??
            'Rute tidak ditemukan untuk perjalanan ini.';
        return _RouteRequestOutcome.failure(
          message: message,
          code: status,
        );
      }

      _parseOptimizedRouteDataSafely(data);
      if (routeOptions.isEmpty) {
        return _RouteRequestOutcome.failure(
          message: 'Rute tidak dapat diproses.',
        );
      }

      return _RouteRequestOutcome.success();
    } on DioException catch (e, st) {
      _logError(e, st, 'LegacyDirections');
      if (e.response?.data != null) {
        debugPrint('[RouteController][Directions][payload] '
            '${e.response?.data}');
      }
      final message = _extractGoogleErrorMessage(e.response?.data) ??
          e.message ??
          'Tidak dapat terhubung ke server lama.';
      final code = e.response?.statusCode?.toString();
      return _RouteRequestOutcome.failure(message: message, code: code);
    } catch (e, st) {
      _logError(e, st, 'LegacyDirections');
      return _RouteRequestOutcome.failure(
        message: 'Terjadi kesalahan saat memproses rute lama.',
      );
    }
  }

  void _parseOptimizedRouteDataSafely(dynamic data) {
    try {
      _parseGoogleRouteData(data as Map<String, dynamic>);
    } catch (e, st) {
      _logError(e, st);
      _showUserMessage(
        'Data rute tidak valid',
        'Server mengirim data rute yang tidak dapat diproses. Silakan coba lagi nanti.',
      );
    }
  }

  void _parseGoogleRouteData(Map<String, dynamic> map) {
    optimizedWaypoints.clear();

    final routes = map['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No routes returned by Google Directions');
    }

    routes.sort((a, b) {
      final mapA = a as Map<String, dynamic>;
      final mapB = b as Map<String, dynamic>;
      final legsA = mapA['legs'] as List?;
      final legsB = mapB['legs'] as List?;
      final legA = legsA != null && legsA.isNotEmpty
          ? legsA.first as Map<String, dynamic>
          : null;
      final legB = legsB != null && legsB.isNotEmpty
          ? legsB.first as Map<String, dynamic>
          : null;
      final durationA =
          (legA?['duration']?['value'] as num?)?.toDouble() ?? double.infinity;
      final durationB =
          (legB?['duration']?['value'] as num?)?.toDouble() ?? double.infinity;
      return durationA.compareTo(durationB);
    });

    final parsedOptions = <RouteOption>[];
    final maxRoutes = routes.length < 2 ? routes.length : 2;
    for (int i = 0; i < maxRoutes; i++) {
      final route = routes[i] as Map<String, dynamic>;
      final summaryRaw = (route['summary'] ?? '').toString().trim();
      final legs = route['legs'] as List? ?? [];
      final leg = legs.isNotEmpty ? legs.first as Map<String, dynamic> : null;
      final overviewPolyline =
          route['overview_polyline'] as Map<String, dynamic>?;
      final encodedPolyline = overviewPolyline?['points']?.toString();
      final points = encodedPolyline != null
          ? _decodePolyline(encodedPolyline)
          : <LatLng>[];

      final distance = (leg?['distance']?['value'] as num?)?.toDouble() ?? 0.0;
      final duration = (leg?['duration']?['value'] as num?)?.toDouble() ?? 0.0;
      final durationInTraffic =
          (leg?['duration_in_traffic']?['value'] as num?)?.toDouble() ??
              duration;

      parsedOptions.add(
        RouteOption(
          id: 'route_$i',
          index: i,
          points: points,
          steps: _extractGoogleRouteSteps(leg),
          distance: distance,
          duration: durationInTraffic,
          durationTypical: duration,
          trafficDelay: math.max(durationInTraffic - duration, 0.0),
          summary: summaryRaw.isNotEmpty ? summaryRaw : 'Rute ${i + 1}',
        ),
      );
    }

    _updateActiveRouteOptions(parsedOptions);
  }

  void _updateActiveRouteOptions(List<RouteOption> options) {
    routeOptions.assignAll(options);

    if (routeOptions.isEmpty) {
      routePoints.clear();
      routeSteps.clear();
      totalRouteDistance.value = 0.0;
      totalRouteDuration.value = 0.0;
      remainingRouteDistance.value = 0.0;
      remainingRouteDuration.value = 0.0;
      nextInstruction.value = '';
      routeActive.value = false;
      activeRoutePolyline.clear();
      _syncForegroundNotification();
      return;
    }

    _applyRouteSelection(0);
  }

  void _parseRoutesPreferredData(List<Map<String, dynamic>> routes) {
    if (routes.isEmpty) {
      _updateActiveRouteOptions(const <RouteOption>[]);
      return;
    }

    final sortedRoutes = List<Map<String, dynamic>>.from(routes)
      ..sort((a, b) {
        final durationA = _durationStringToSeconds(a['duration']);
        final durationB = _durationStringToSeconds(b['duration']);
        return durationA.compareTo(durationB);
      });

    final parsedOptions = <RouteOption>[];
    final maxRoutes = sortedRoutes.length < 2 ? sortedRoutes.length : 2;

    for (int i = 0; i < maxRoutes; i++) {
      final route = sortedRoutes[i];
      final legs = (route['legs'] as List?)
              ?.whereType<Map>()
              .map((leg) => leg.cast<String, dynamic>())
              .toList() ??
          const <Map<String, dynamic>>[];
      final leg = legs.isNotEmpty ? legs.first : null;

      final encodedPolyline =
          (route['polyline'] as Map?)?['encodedPolyline']?.toString();
      final points = encodedPolyline != null
          ? _decodePolyline(encodedPolyline)
          : <LatLng>[];

      final distance = (route['distanceMeters'] as num?)?.toDouble() ??
          (leg?['distanceMeters'] as num?)?.toDouble() ??
          0.0;
      final duration = _durationStringToSeconds(route['duration']);
      final staticDuration = _durationStringToSeconds(
        route['staticDuration'] ?? leg?['staticDuration'],
      );
      final description = (route['description'] ?? '').toString();

      double trafficDelay = math.max(duration - staticDuration, 0.0);
      final advisory = route['travelAdvisory'];
      if (advisory is Map) {
        final delay = _durationStringToSeconds(advisory['delay']);
        if (delay > 0) {
          trafficDelay = delay;
        }
      }

      parsedOptions.add(
        RouteOption(
          id: 'route_pref_$i',
          index: i,
          points: points,
          steps: _extractRoutesPreferredSteps(leg),
          distance: distance,
          duration: duration,
          durationTypical: staticDuration > 0 ? staticDuration : duration,
          trafficDelay: trafficDelay,
          summary: description.isNotEmpty ? description : 'Rute ${i + 1}',
        ),
      );
    }

    _updateActiveRouteOptions(parsedOptions);
  }

  List<Map<String, dynamic>> _extractRoutesPreferredSteps(
      Map<String, dynamic>? leg) {
    final steps = (leg?['steps'] as List?) ?? const [];
    return steps.whereType<Map>().map((rawStep) {
      final step = rawStep.cast<String, dynamic>();
      final navigationInstruction =
          (step['navigationInstruction'] as Map?)?.cast<String, dynamic>();
      final instructionRaw =
          navigationInstruction?['instructions']?.toString() ?? '';
      final cleanedInstruction =
          instructionRaw.isNotEmpty ? _stripHtml(instructionRaw) : '';
      final distance = (step['distanceMeters'] as num?)?.toDouble() ?? 0.0;
      final duration = _durationStringToSeconds(step['staticDuration']);
      final polyline =
          (step['polyline'] as Map?)?['encodedPolyline']?.toString();
      final maneuver = navigationInstruction?['maneuver']?.toString();
      final normalizedManeuver = _normalizeRoutesPreferredManeuver(maneuver);
      final fallbackInstruction = cleanedInstruction.isNotEmpty
          ? cleanedInstruction
          : RouteController.parseManeuver({
              'type': normalizedManeuver['type'],
              'modifier': normalizedManeuver['modifier'],
              'name': '',
            });

      return <String, dynamic>{
        'instruction': fallbackInstruction.isNotEmpty
            ? fallbackInstruction
            : 'Lanjutkan perjalanan',
        'distance': distance,
        'duration': duration,
        'type': normalizedManeuver['type'] ?? '',
        'modifier': normalizedManeuver['modifier'] ?? '',
        'name': cleanedInstruction.isNotEmpty
            ? cleanedInstruction
            : 'Langkah berikutnya',
        if (polyline != null) 'polyline': polyline,
      };
    }).toList();
  }

  Map<String, String> _normalizeRoutesPreferredManeuver(String? rawManeuver) {
    if (rawManeuver == null || rawManeuver.isEmpty) {
      return const {'type': '', 'modifier': ''};
    }

    const directMap = <String, Map<String, String>>{
      'TURN_LEFT': {'type': 'turn', 'modifier': 'left'},
      'TURN_RIGHT': {'type': 'turn', 'modifier': 'right'},
      'TURN_SLIGHT_LEFT': {'type': 'turn', 'modifier': 'slight left'},
      'TURN_SLIGHT_RIGHT': {'type': 'turn', 'modifier': 'slight right'},
      'TURN_SHARP_LEFT': {'type': 'turn', 'modifier': 'sharp left'},
      'TURN_SHARP_RIGHT': {'type': 'turn', 'modifier': 'sharp right'},
      'STRAIGHT': {'type': 'continue', 'modifier': 'straight'},
      'KEEP_LEFT': {'type': 'continue', 'modifier': 'left'},
      'KEEP_RIGHT': {'type': 'continue', 'modifier': 'right'},
      'KEEP_STRAIGHT': {'type': 'continue', 'modifier': 'straight'},
      'MERGE': {'type': 'merge', 'modifier': ''},
      'MERGE_LEFT': {'type': 'merge', 'modifier': 'left'},
      'MERGE_RIGHT': {'type': 'merge', 'modifier': 'right'},
      'FORK_LEFT': {'type': 'fork', 'modifier': 'left'},
      'FORK_RIGHT': {'type': 'fork', 'modifier': 'right'},
      'ON_RAMP_LEFT': {'type': 'on ramp', 'modifier': 'left'},
      'ON_RAMP_RIGHT': {'type': 'on ramp', 'modifier': 'right'},
      'OFF_RAMP_LEFT': {'type': 'off ramp', 'modifier': 'left'},
      'OFF_RAMP_RIGHT': {'type': 'off ramp', 'modifier': 'right'},
      'OFF_RAMP_STRAIGHT': {'type': 'off ramp', 'modifier': 'straight'},
      'ROUNDABOUT_LEFT': {'type': 'roundabout', 'modifier': 'left'},
      'ROUNDABOUT_RIGHT': {'type': 'roundabout', 'modifier': 'right'},
      'ROUNDABOUT': {'type': 'roundabout', 'modifier': ''},
      'ENTER_ROUNDABOUT': {'type': 'roundabout', 'modifier': ''},
      'EXIT_ROUNDABOUT': {'type': 'roundabout', 'modifier': ''},
      'DEPART': {'type': 'depart', 'modifier': ''},
      'ARRIVE': {'type': 'arrive', 'modifier': ''},
      'ARRIVE_LEFT': {'type': 'arrive', 'modifier': 'left'},
      'ARRIVE_RIGHT': {'type': 'arrive', 'modifier': 'right'},
      'NAME_CHANGE': {'type': 'new name', 'modifier': ''},
      'TAKE_FERRY': {'type': 'continue', 'modifier': ''},
      'FERRY': {'type': 'continue', 'modifier': ''},
      'UTURN': {'type': 'turn', 'modifier': 'uturn'},
      'UTURN_LEFT': {'type': 'turn', 'modifier': 'uturn-left'},
      'UTURN_RIGHT': {'type': 'turn', 'modifier': 'uturn-right'},
      'U_TURN': {'type': 'turn', 'modifier': 'uturn'},
      'U_TURN_LEFT': {'type': 'turn', 'modifier': 'uturn-left'},
      'U_TURN_RIGHT': {'type': 'turn', 'modifier': 'uturn-right'},
    };

    final upper = rawManeuver.toUpperCase();
    final mapped = directMap[upper];
    if (mapped != null) {
      return mapped;
    }

    final tokens = rawManeuver.toLowerCase().split('_');
    if (tokens.isEmpty) {
      return const {'type': '', 'modifier': ''};
    }

    String first = tokens.first;
    List<String> remainder =
        tokens.length > 1 ? List<String>.from(tokens.sublist(1)) : <String>[];

    if (first == 'u' && remainder.isNotEmpty && remainder.first == 'turn') {
      first = 'turn';
      remainder =
          remainder.length > 1 ? ['uturn', remainder.last] : <String>['uturn'];
    } else if (first == 'uturn') {
      first = 'turn';
      if (remainder.isEmpty) {
        remainder = <String>['uturn'];
      } else {
        remainder[0] = 'uturn-${remainder[0]}';
      }
    }

    switch (first) {
      case 'turn':
        final modifier = remainder.join(' ').trim();
        if (modifier.isEmpty || modifier == 'turn') {
          return const {'type': 'turn', 'modifier': ''};
        }
        if (modifier == 'uturn') {
          return const {'type': 'turn', 'modifier': 'uturn'};
        }
        return {'type': 'turn', 'modifier': modifier};
      case 'keep':
        return {
          'type': 'continue',
          'modifier': remainder.isNotEmpty ? remainder.last : 'straight',
        };
      case 'merge':
        return {
          'type': 'merge',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'fork':
        return {
          'type': 'fork',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'on':
        return {
          'type': 'on ramp',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'off':
        return {
          'type': 'off ramp',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'roundabout':
        return {
          'type': 'roundabout',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'arrive':
        return {
          'type': 'arrive',
          'modifier': remainder.isNotEmpty ? remainder.last : '',
        };
      case 'depart':
        return const {'type': 'depart', 'modifier': ''};
    }

    return const {'type': '', 'modifier': ''};
  }

  List<Map<String, dynamic>> _extractGoogleRouteSteps(
      Map<String, dynamic>? leg) {
    final steps = (leg?['steps'] as List?) ?? const [];
    return steps.whereType<Map<String, dynamic>>().map((step) {
      final htmlInstruction = (step['html_instructions'] ?? '').toString();
      final cleanedInstruction = _stripHtml(htmlInstruction);
      final maneuverRaw = (step['maneuver'] ?? '').toString();
      final distance = (step['distance']?['value'] as num?)?.toDouble() ?? 0.0;
      final duration = (step['duration']?['value'] as num?)?.toDouble() ?? 0.0;
      final name = (step['name'] ?? step['street_name'] ?? '').toString();
      final exitNumber = step['exit_number'] ?? step['roundabout_exit_number'];

      final maneuverParts = _splitManeuver(maneuverRaw);
      final fallbackInstruction = cleanedInstruction.isNotEmpty
          ? cleanedInstruction
          : RouteController.parseManeuver({
              'type': maneuverParts['type'],
              'modifier': maneuverParts['modifier'],
              'keluar': exitNumber,
              'name': name,
            });

      return {
        'instruction': fallbackInstruction,
        'distance': distance,
        'duration': duration,
        'type': maneuverParts['type'] ?? '',
        'modifier': maneuverParts['modifier'] ?? '',
        'name': name.isNotEmpty ? name : 'Jalan tanpa nama',
      };
    }).toList();
  }

  Map<String, String> _splitManeuver(String value) {
    if (value.isEmpty) {
      return const {'type': '', 'modifier': ''};
    }
    final normalized = value.trim();
    final parts = normalized.split(RegExp(r'[-_]'));
    if (parts.isEmpty) {
      return const {'type': '', 'modifier': ''};
    }
    final type = parts.first;
    final modifier = parts.length > 1 ? parts.sublist(1).join('-') : '';
    return {'type': type, 'modifier': modifier};
  }

  double _durationStringToSeconds(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)s').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '') ?? 0.0;
      }
    }
    return 0.0;
  }

  Map<String, String> _buildRoutesHeaders({required String fieldMask}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': GoogleMapsConfig.apiKey,
      'X-Goog-FieldMask': fieldMask,
    };

    final androidPackage = GoogleMapsConfig.androidPackageName;
    if (androidPackage.isNotEmpty) {
      headers['X-Android-Package'] = androidPackage;
      final androidCert = GoogleMapsConfig.androidCertificateSha1;
      if (androidCert.isNotEmpty) {
        headers['X-Android-Cert'] = androidCert;
      }
    }

    final iosBundle = GoogleMapsConfig.iosBundleIdentifier;
    if (iosBundle.isNotEmpty) {
      headers['X-Ios-Bundle-Identifier'] = iosBundle;
    }

    return headers;
  }
}
