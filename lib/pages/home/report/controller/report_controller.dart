import 'dart:convert';
import 'dart:io';
import 'package:JIR/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:JIR/config.dart';
import 'package:JIR/utils/file_utils.dart';

class ReportController extends GetxController {
  final imageFile = Rxn<File>();
  final description = ''.obs;
  final reportType = 'Banjir'.obs;
  final severity = 'Rendah'.obs;
  final address = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final contactName = ''.obs;
  final contactPhone = ''.obs;
  final dateTime = DateTime.now().obs;
  final isAnonymous = false.obs;

  final _picker = ImagePicker();
  final reports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReportsFromHive();
  }

  Map<String, dynamic> _normalizeReport(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      final Map<String, dynamic> out = {};
      raw.forEach((k, v) {
        out[k.toString()] = v;
      });
      return out;
    }
    return {};
  }

  List<Map<String, dynamic>> _normalizeReportList(dynamic rawList) {
    final List<Map<String, dynamic>> out = [];
    if (rawList is List) {
      for (var it in rawList) {
        final m = _normalizeReport(it);
        if (m.isNotEmpty) out.add(m);
      }
    }
    return out;
  }

  Future<void> loadReportsFromHive() async {
    try {
      if (!Hive.isBoxOpen('reports')) {
        await Hive.openBox('reports');
      }
      final box = Hive.box('reports');
      final stored = box.get('list', defaultValue: []);
      final normalized = _normalizeReportList(stored);
      reports.assignAll(normalized);
    } catch (e) {
      reports.clear();
    }
  }

  Future<void> saveReportsToHive() async {
    try {
      if (!Hive.isBoxOpen('reports')) {
        await Hive.openBox('reports');
      }
      final box = Hive.box('reports');

      final List<Map<String, dynamic>> toStore = reports.map((r) {
        final Map<String, dynamic> m = {};
        r.forEach((k, v) {
          m[k.toString()] = v;
        });
        return m;
      }).toList();

      await box.put('list', toStore);
    } catch (e) {
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        final tmp = File(pickedFile.path);
        final saved = await savePickedFilePermanently(tmp);
        imageFile.value = saved;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> fillLocationFromGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Lokasi', 'Layanan lokasi tidak aktif');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Lokasi', 'Permission lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Lokasi', 'Permission lokasi permanen ditolak');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      address.value =
          '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      Get.snackbar('Lokasi', 'Lokasi berhasil diambil');
    } catch (e) {
      Get.snackbar('Lokasi', 'Gagal mengambil lokasi: ${e.toString()}');
    }
  }

  void setDateTime(DateTime dt) {
    dateTime.value = dt;
  }

  Future<void> submitReport() async {
    if (!isAnonymous.value) {
      if (contactName.value.trim().isEmpty ||
          contactPhone.value.trim().isEmpty) {
        Get.snackbar('Error', 'Isi nama & nomor telepon atau centang anonim');
        return;
      }
    }

    if (imageFile.value == null) {
      Get.snackbar('Error', 'Masukkan foto bukti');
      return;
    }

    Get.toNamed(AppRoutes.reportLoading);
    final now = DateTime.now();
    final report = {
      'id': now.millisecondsSinceEpoch,
      'type': reportType.value,
      'severity': severity.value,
      'address': address.value,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'description': description.value,
      'imagePath': imageFile.value!.path,
      'contactName': isAnonymous.value ? 'Anonim' : contactName.value,
      'contactPhone': isAnonymous.value ? '' : contactPhone.value,
      'dateTime': dateTime.value.toIso8601String(),
      'isAnonymous': isAnonymous.value,
      'status': 'Menunggu'
    };

    final imagePath =
        (report['imagePath'] is String) ? report['imagePath'] as String : '';

    bool uploaded = false;
    if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      uploaded = await _uploadReportToServer(report, file);
    }

    reports.insert(0, Map<String, dynamic>.from(report));
    await saveReportsToHive();
    imageFile.value = null;
    description.value = '';
    contactName.value = '';
    contactPhone.value = '';
    isAnonymous.value = false;
    Get.offNamed(AppRoutes.home, arguments: 1);

    if (uploaded) {
      Get.snackbar('Sukses', 'Laporan berhasil dikirim');
    } else {
      Get.snackbar('Tersimpan', 'Laporan tersimpan secara lokal (offline)');
    }
  }

  Future<bool> _uploadReportToServer(
      Map<String, dynamic> report, File image) async {
    try {
      final uri = Uri.parse("$mainUrl/api/reports/");
      final request = http.MultipartRequest('POST', uri);

      request.fields['type'] = (report['type'] ?? '').toString();
      request.fields['severity'] = (report['severity'] ?? '').toString();
      request.fields['address'] = (report['address'] ?? '').toString();
      request.fields['latitude'] = (report['latitude'] ?? '').toString();
      request.fields['longitude'] = (report['longitude'] ?? '').toString();
      request.fields['description'] = (report['description'] ?? '').toString();
      request.fields['contact_name'] = (report['contactName'] ?? '').toString();
      request.fields['contact_phone'] =
          (report['contactPhone'] ?? '').toString();
      request.fields['date_time'] = (report['dateTime'] ?? '').toString();
      request.fields['is_anonymous'] =
          (report['isAnonymous'] == true) ? 'true' : 'false';
      if (Hive.isBoxOpen('authBox')) {
        final authBox = Hive.box('authBox');
        final token = authBox.get('fcm_token');
        if (token != null) request.fields['device_token'] = token.toString();
      }

      final fileStream = http.ByteStream(image.openRead());
      final length = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: path.basename(image.path),
      );
      request.files.add(multipartFile);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final resp = await http.Response.fromStream(streamedResponse);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchReportFromServer(int reportId) async {
    try {
      final uri = Uri.parse("$mainUrl/api/reports/$reportId");
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(resp.body);
        return json;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshReportFromServer(int reportId) async {
    final serverReport = await fetchReportFromServer(reportId);
    if (serverReport == null) return;

    try {
      if (!Hive.isBoxOpen('reports')) {
        await Hive.openBox('reports');
      }
      final box = Hive.box('reports');
      final rawCurrent = box.get('list', defaultValue: []);
      final List<Map<String, dynamic>> current =
          _normalizeReportList(rawCurrent);

      final idx = current.indexWhere((r) {
        final dynamic rid = r['id'];
        if (rid == null) return false;
        return rid.toString() == serverReport['id'].toString();
      });

      final mapped = <String, dynamic>{
        'id': serverReport['id'],
        'type': serverReport['type'],
        'severity': serverReport['severity'],
        'address': serverReport['address'],
        'latitude': serverReport['latitude'],
        'longitude': serverReport['longitude'],
        'description': serverReport['description'],
        'imagePath':
            serverReport['image_path'] ?? serverReport['imagePath'] ?? '',
        'contactName': serverReport['contact_name'] ??
            serverReport['contactName'] ??
            'Anonim',
        'contactPhone':
            serverReport['contact_phone'] ?? serverReport['contactPhone'] ?? '',
        'dateTime': serverReport['date_time'] ?? serverReport['dateTime'],
        'isAnonymous': serverReport['is_anonymous'] ??
            serverReport['isAnonymous'] ??
            false,
        'status': serverReport['status'] ?? 'Menunggu',
        'reject_reason': serverReport['reject_reason'] ?? '',
      };

      if (idx >= 0) {
        current[idx] = mapped;
      } else {
        current.insert(0, mapped);
      }

      await box.put('list', current);
      reports.assignAll(List<Map<String, dynamic>>.from(current));
    } catch (e) {
    }
  }
}
