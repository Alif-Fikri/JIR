import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String apiKey = dotenv.env['WEATHER_APIDEV_KEY']!;
  final double lat = -6.229728; // Jakarta
  final double lon = 106.689431;

  Future<Map<String, dynamic>> fetchWeatherForecast() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
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
