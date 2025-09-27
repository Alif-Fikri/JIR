import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

String normalizeLocalPath(String path) {
  if (path.startsWith('file://')) {
    try {
      return Uri.parse(path).toFilePath();
    } catch (_) {
      return path.replaceFirst('file://', '');
    }
  }
  return path;
}

File? resolveLocalFile(String path) {
  if (path.isEmpty) return null;
  try {
    final normalized = normalizeLocalPath(path);
    final file = File(normalized);
    if (file.existsSync()) {
      return file;
    }
  } catch (_) {}
  return null;
}

Future<File> savePickedFilePermanently(File tmpFile) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}_${p.basename(tmpFile.path)}';
  final savedPath = p.join(appDir.path, fileName);
  final savedFile = await tmpFile.copy(savedPath);
  return savedFile;
}
