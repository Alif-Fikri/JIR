part of 'route_controller.dart';

extension RouteControllerPlaces on RouteController {
  void _resetPlacesSession() {
    _placesSessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, String> _buildPlacesHeaders({
    required String fieldMask,
    bool includeSessionToken = false,
  }) {
    final headers = <String, String>{
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

    if (includeSessionToken && _placesSessionToken != null) {
      headers['X-Goog-Session-Token'] = _placesSessionToken!;
    }

    return headers;
  }

  String? _normalizePlaceId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('places/')) return raw;
    return 'places/$raw';
  }

  Map<String, dynamic>? _mapPlaceToSuggestion(
    Map<String, dynamic>? place, {
    String source = 'search',
    LatLng? origin,
  }) {
    if (place == null) return null;

    final normalized = Map<String, dynamic>.from(place);
    final placeId = _normalizePlaceId(
      (normalized['id'] ?? normalized['placeId'])?.toString(),
    );

    if (placeId == null) return null;

    final displayNameMap =
        (normalized['displayName'] as Map?)?.cast<String, dynamic>();
    final displayName = displayNameMap?['text']?.toString() ??
        normalized['displayName']?.toString() ??
        '';
    final formattedAddress = normalized['formattedAddress']?.toString() ?? '';
    final types =
        (normalized['types'] as List?)?.map((e) => e.toString()).toList() ??
            <String>[];
    final mappedType = _mapGooglePlaceTypes(types);
    final description =
        formattedAddress.isNotEmpty ? formattedAddress : displayName;
    final normalizedDisplay =
        displayName.isNotEmpty ? displayName : description;

    final locationMap =
        (normalized['location'] as Map?)?.cast<String, dynamic>();
    final lat = double.tryParse(locationMap?['latitude']?.toString() ?? '');
    final lng = double.tryParse(locationMap?['longitude']?.toString() ?? '');

    double? distanceMeters = (normalized['distanceMeters'] as num?)?.toDouble();
    if (distanceMeters == null &&
        origin != null &&
        lat != null &&
        lng != null) {
      distanceMeters =
          RouteController.calculateDistance(origin, LatLng(lat, lng));
    }

    return {
      'id': placeId,
      'display_name': normalizedDisplay,
      'place_name': description,
      'type': mappedType,
      'raw_types': types,
      if (lat != null && lng != null)
        'location': {
          'lat': lat,
          'lng': lng,
        },
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (distanceMeters != null)
        'distance_text': RouteController.formatDistance(distanceMeters),
      'source': source,
    };
  }

  Future<List<Map<String, dynamic>>> _searchPlacesByText(
    String query,
    LatLng? bias,
  ) async {
    final body = <String, dynamic>{
      'textQuery': query,
      'languageCode': 'id',
      'regionCode': 'ID',
      'pageSize': 10,
      'rankPreference': 'RELEVANCE',
    };

    if (bias != null) {
      body['locationBias'] = {
        'circle': {
          'center': {
            'latitude': bias.latitude,
            'longitude': bias.longitude,
          },
          'radius': 40000.0,
        },
      };
    }

    final fieldMask = [
      'places.id',
      'places.displayName',
      'places.formattedAddress',
      'places.location',
      'places.types',
    ].join(',');

    final response = await _dio.post(
      'https://places.googleapis.com/v1/places:searchText',
      data: body,
      options: Options(
        headers: _buildPlacesHeaders(
          fieldMask: fieldMask,
          includeSessionToken: true,
        ),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final origin = bias;
    final places = (response.data['places'] as List?) ?? const [];
    return places
        .whereType<Map>()
        .map(
          (place) => _mapPlaceToSuggestion(
            place.cast<String, dynamic>(),
            source: 'searchText',
            origin: origin,
          ),
        )
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<List<Map<String, dynamic>>> _searchPlacesAutocomplete(
    String query,
    LatLng? bias,
  ) async {
    final body = <String, dynamic>{
      'input': query,
      'languageCode': 'id',
      'sessionToken': _placesSessionToken,
      'includedRegionCodes': ['ID'],
      'includeQueryPredictions': false,
    };

    if (bias != null) {
      body['origin'] = {
        'location': {
          'latLng': {
            'latitude': bias.latitude,
            'longitude': bias.longitude,
          },
        },
      };
      body['locationBias'] = {
        'circle': {
          'center': {
            'latitude': bias.latitude,
            'longitude': bias.longitude,
          },
          'radius': 40000.0,
        },
      };
    }

    final fieldMask = [
      'suggestions.placePrediction.placeId',
      'suggestions.placePrediction.place.displayName',
      'suggestions.placePrediction.place.formattedAddress',
      'suggestions.placePrediction.place.location',
      'suggestions.placePrediction.place.types',
    ].join(',');

    final response = await _dio.post(
      'https://places.googleapis.com/v1/places:autocomplete',
      data: body,
      options: Options(
        headers: _buildPlacesHeaders(
          fieldMask: fieldMask,
          includeSessionToken: true,
        ),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final origin = bias;
    final suggestions = (response.data['suggestions'] as List?) ?? const [];

    return suggestions
        .whereType<Map>()
        .map((item) =>
            (item['placePrediction'] as Map?)?.cast<String, dynamic>())
        .whereType<Map<String, dynamic>>()
        .map((prediction) {
          final place =
              (prediction['place'] as Map?)?.cast<String, dynamic>() ??
                  <String, dynamic>{};
          if (!place.containsKey('id') && prediction['placeId'] != null) {
            place['id'] = prediction['placeId'];
          }
          return _mapPlaceToSuggestion(
            place,
            source: 'autocomplete',
            origin: origin,
          );
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<List<Map<String, dynamic>>> _searchPlacesNearby(
    String query,
    LatLng origin,
  ) async {
    final body = <String, dynamic>{
      'languageCode': 'id',
      'maxResultCount': 10,
      'rankPreference': 'DISTANCE',
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
          'radius': 5000.0,
        },
      },
    };

    if (query.isNotEmpty) {
      body['searchTerm'] = query;
    }

    final fieldMask = [
      'places.id',
      'places.displayName',
      'places.formattedAddress',
      'places.location',
      'places.distanceMeters',
      'places.types',
    ].join(',');

    final response = await _dio.post(
      'https://places.googleapis.com/v1/places:searchNearby',
      data: body,
      options: Options(
        headers: _buildPlacesHeaders(
          fieldMask: fieldMask,
        ),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final originPoint = origin;
    final places = (response.data['places'] as List?) ?? const [];
    return places
        .whereType<Map>()
        .map(
          (place) => _mapPlaceToSuggestion(
            place.cast<String, dynamic>(),
            source: 'nearby',
            origin: originPoint,
          ),
        )
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  String _mapGooglePlaceTypes(List<String> types) {
    if (types.isEmpty) return 'place';
    bool has(String fragment) {
      final fragmentLower = fragment.toLowerCase();
      return types.any((type) {
        final lower = type.toLowerCase();
        return lower == fragmentLower || lower.contains(fragmentLower);
      });
    }

    if (has('administrative_area_level_3') ||
        has('administrative_area_level_4')) {
      return 'district';
    }
    if (has('administrative_area_level_2')) {
      return 'district';
    }
    if (has('administrative_area_level_1')) {
      return 'region';
    }
    if (has('locality')) {
      return 'city';
    }
    if (has('sublocality') || has('neighborhood')) {
      return 'neighborhood';
    }
    if (has('postal_code')) {
      return 'postcode';
    }
    if (has('route') || has('street_address')) {
      return 'road';
    }
    if (has('establishment') || has('point_of_interest')) {
      return 'poi';
    }
    if (has('natural_feature')) {
      return 'natural_feature';
    }
    if (has('airport')) {
      return 'airport';
    }
    if (has('park')) {
      return 'park';
    }
    return 'place';
  }
}
