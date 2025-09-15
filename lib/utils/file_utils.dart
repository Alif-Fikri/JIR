import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> savePickedFilePermanently(File tmpFile) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(tmpFile.path)}';
  final savedPath = p.join(appDir.path, fileName);
  final savedFile = await tmpFile.copy(savedPath);
  return savedFile;
}
