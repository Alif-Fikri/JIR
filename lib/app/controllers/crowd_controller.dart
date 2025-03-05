import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CrowdController extends GetxController {
  final RxMap<String, dynamic> liveData = <String, dynamic>{}.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;

  // final Map<String, dynamic> yesterdayCrowd = [
  //   {'location': 'DPR', 'count': '3.2k', 'level': 'High'},
  //   {'location': 'Bundaran HI', 'count': '2.3k', 'level': 'Medium'},
  //   {'location': 'Monas', 'count': '700', 'level': 'Low'},
  //   {'location': 'Patung Kuda', 'count': '900', 'level': 'Low'},
  // ];

  final Map<String, LatLng> locations = const {
    'DPR': LatLng(-6.2096, 106.8005),
    'Bundaran HI': LatLng(-6.1945, 106.8229),
    'Monas': LatLng(-6.1754, 106.8273),
    'Patung Kuda': LatLng(-6.1715, 106.8343),
  };

  @override
  void onInit() {
    super.onInit();
    fetchData();
    Timer.periodic(const Duration(seconds: 10), (timer) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      final response =
          await http.get(Uri.parse('http://localhost:8000/get_predictions'));
      print(response.body);

      if (response.statusCode == 200) {
        liveData.value = json.decode(response.body);
        errorMessage.value = '';
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLoading(false);
    }
  }

  String getLevel(int count) {
    if (count > 2000) return 'Ramai';
    if (count > 1000) return 'Sedang';
    return 'Sepi';
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'Ramai':
        return Colors.red;
      case 'Sedang':
        return Colors.orange;
      case 'Sepi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
