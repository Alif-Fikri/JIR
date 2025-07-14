import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:JIR/config.dart';

class WeatherService {
  final double lat = -6.229728; // Jakarta
  final double lon = 106.689431;
  final String weatherUrl = mainUrl;

  Future<Map<String, dynamic>> fetchWeather() async {
    final url = Uri.parse('$weatherUrl/weather?lat=$lat&lon=$lon');

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
}
