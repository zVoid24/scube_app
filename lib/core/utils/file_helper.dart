import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<void> saveAndOpen(
    List<int> bytes,
    String fileName, {
    required String mime,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);

    await OpenFile.open(file.path, type: mime);
  }
}
