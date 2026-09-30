import 'dart:io';

import 'package:image/image.dart' as img;

class ImageUtil {

  static Future<File> prepareDocumentForUpload(File file) async {

     const int maxUploadBytes = 800 * 1024; // 800 KB

    bool isImageFile(File file) {
      final ext = file.path.split('.').last.toLowerCase();
      return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
    }

    if (!isImageFile(file)) return file;

    final originalBytes = await file.readAsBytes();
    if (originalBytes.length <= maxUploadBytes) return file;

    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw Exception('Could not process the selected image.');
    }

    var current = decoded;
    var quality = 85;
    List<int> bytes = img.encodeJpg(current, quality: quality);

    while (bytes.length > maxUploadBytes && quality > 40) {
      quality -= 10;
      bytes = img.encodeJpg(current, quality: quality);
    }

    while (bytes.length > maxUploadBytes && current.width > 800) {
      final targetWidth = (current.width * 0.85).round();
      current = img.copyResize(current, width: targetWidth);
      quality = 85;
      bytes = img.encodeJpg(current, quality: quality);

      while (bytes.length > maxUploadBytes && quality > 40) {
        quality -= 10;
        bytes = img.encodeJpg(current, quality: quality);
      }
    }

    if (bytes.length > maxUploadBytes) {
      throw Exception('Unable to reduce image below 800 KB.');
    }

    final tempDir = await Directory.systemTemp.createTemp('customer_app_');
    final tempFile = File(
        '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
}