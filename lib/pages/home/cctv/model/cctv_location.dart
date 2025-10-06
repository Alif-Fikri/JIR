import 'package:latlong2/latlong.dart' as ll;

class CCTVLocation {
  final String name;
  final String url;
  final ll.LatLng coordinates;

  const CCTVLocation({
    required this.name,
    required this.url,
    required this.coordinates,
  });
}

final List<CCTVLocation> defaultCctvLocations = [
  CCTVLocation(
    name: 'DPR',
    url: 'https://cctv.balitower.co.id/Bendungan-Hilir-003-700014_1/embed.html',
    coordinates: ll.LatLng(-6.2096, 106.8005),
  ),
  CCTVLocation(
    name: 'Bundaran HI',
    url: 'https://cctv.balitower.co.id/Menteng-001-700123_5/embed.html',
    coordinates: ll.LatLng(-6.1945, 106.8229),
  ),
  CCTVLocation(
    name: 'Monas',
    url: 'https://cctv.balitower.co.id/Monas-Barat-009-506632_2/embed.html',
    coordinates: ll.LatLng(-6.1754, 106.8273),
  ),
  CCTVLocation(
    name: 'Patung Kuda',
    url: 'https://cctv.balitower.co.id/JPO-Merdeka-Barat-507357_9/embed.html',
    coordinates: ll.LatLng(-6.1715, 106.8343),
  ),
];
