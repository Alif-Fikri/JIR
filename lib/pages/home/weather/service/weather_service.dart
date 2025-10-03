import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

class WeatherService {
  final double lat = -6.229728;
  final double lon = 106.689431;
  final String weatherUrl = mainUrl;

  Future<Map<String, dynamic>> fetchWeather() async {
    final url = Uri.parse('$weatherUrl/api/weather?lat=$lat&lon=$lon');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  Map<String, dynamic> parseCurrentWeather(Map<String, dynamic> json) {
    return {
      'temp': json['current']['temp'],
      'description': json['current']['weather'][0]['description'],
    };
  }

  List<Map<String, dynamic>> parseHourlyWeather(List<dynamic> list) {
    return list.take(12).map((item) {
      return {
        'dt': item['dt'],
        'temp': item['temp'],
        'description': item['weather'][0]['description'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> parseDailyWeather(List<dynamic> list) {
    return list.take(7).map((item) {
      return {
        'dt': item['dt'],
        'temp': item['temp']['day'],
        'description': item['weather'][0]['description'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchHourlyWindow(
      {int before = 2, int after = 2}) async {
    final uri = Uri.parse(
        '$weatherUrl/api/weather/hourly-window?lat=$lat&lon=$lon&before=$before&after=$after');
    final r = await http.get(uri);
    if (r.statusCode != 200)
      throw Exception('Failed to fetch hourly window: ${r.statusCode}');
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final list = (body['window'] as List<dynamic>)
        .map((e) => {
              'dt': e['dt'],
              'temp': (e['temp'] is num)
                  ? (e['temp'] as num).toDouble()
                  : double.tryParse(e['temp'].toString()) ?? 0.0,
              'description': e['description'] ?? ''
            })
        .toList()
        .cast<Map<String, dynamic>>();
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchHistory({int hours = 24}) async {
    final uri = Uri.parse(
        '$weatherUrl/api/weather/history?lat=$lat&lon=$lon&hours=$hours');
    final r = await http.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Failed to fetch history: ${r.statusCode}');
    }
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final list = (body['history'] as List<dynamic>)
        .map((e) => {
              'dt': e['dt'],
              'temp': (e['temp'] is num)
                  ? (e['temp'] as num).toDouble()
                  : double.tryParse(e['temp'].toString()) ?? 0.0,
              'description': e['description'] ?? ''
            })
        .toList()
        .cast<Map<String, dynamic>>();
    return list;
  }
}
