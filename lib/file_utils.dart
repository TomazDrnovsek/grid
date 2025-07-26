import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FileUtils {
  /// Returns (and creates if needed) the app's private "images" folder.
  static Future<Directory> getAppImagesDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docsDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Copies [source] into app storage and compresses it.
  /// - maxWidth: 1080px, quality: 80
  /// - preserves EXIF orientation (autoCorrectionAngle)
  /// Throws on I/O errors.
  static Future<File> copyAndCompress(XFile source) async {
    final appDir = await getAppImagesDir();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${appDir.path}/IMG_$timestamp.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      targetPath,
      minWidth: 1080,
      // Let plugin decide minHeight to preserve aspect ratio
      quality: 80,
      autoCorrectionAngle: true,
      keepExif: true,
    );

    if (result == null) {
      throw Exception('Compression failed for ${source.path}');
    }
    return File(result.path);
  }
}