import 'package:http/http.dart' as http;
import 'dart:convert';

class FloodService {
  final String url = "https://poskobanjir.dsdadki.web.id/datatmalaststatus.json";

  Future<List<Map<String, dynamic>>> fetchFloodData() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // data yg dikonsum
        List<Map<String, dynamic>> filteredData = jsonData.map((item) {
          return {
            "NAMA_PINTU_AIR": item["NAMA_PINTU_AIR"],
            "LATITUDE": item["LATITUDE"],
            "LONGITUDE": item["LONGITUDE"],
            "RECORD_STATUS": item["RECORD_STATUS"],
            "TINGGI_AIR": item["TINGGI_AIR"],
            "TINGGI_AIR_SEBELUMNYA": item["TINGGI_AIR_SEBELUMNYA"],
            "TANGGAL": item["TANGGAL"],
            "STATUS_SIAGA": item["STATUS_SIAGA"]
          };
        }).toList();

        return filteredData;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
