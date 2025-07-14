import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:JIR/config.dart';

class FloodService {
  final String url = "$mainUrl/api/flood/data";

  Future<List<Map<String, dynamic>>> fetchFloodData() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jsonData = decoded["data"];

        return jsonData
            .map<Map<String, dynamic>>((item) => {
                  "NAMA_PINTU_AIR": item["NAMA_PINTU_AIR"],
                  "LATITUDE": item["LATITUDE"],
                  "LONGITUDE": item["LONGITUDE"],
                  "RECORD_STATUS": item["RECORD_STATUS"],
                  "TINGGI_AIR": item["TINGGI_AIR"],
                  "TINGGI_AIR_SEBELUMNYA": item["TINGGI_AIR_SEBELUMNYA"],
                  "TANGGAL": item["TANGGAL"],
                  "STATUS_SIAGA": item["STATUS_SIAGA"]
                })
            .toList();
      } else {
        throw Exception("Gagal memuat data dari backend");
      }
    } catch (e) {
      print("Error saat ambil data banjir: $e");
      return [];
    }
  }
}
