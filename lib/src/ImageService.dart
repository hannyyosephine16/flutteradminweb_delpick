import 'dart:convert';
import 'dart:typed_data';
import 'dart:async'; // Tambahkan import ini untuk Completer
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ImageHelperService {
  static final ImagePicker _picker = ImagePicker();

  /// Convert XFile to base64 string (compatible dengan backend)
  static Future<String?> convertToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      // Format sesuai yang diharapkan backend
      String mimeType = _getMimeType(file.name);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('Error converting to base64: $e');
      return null;
    }
  }

  /// Get MIME type from file extension
  static String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Pick image from gallery/camera with web support
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      if (kIsWeb) {
        // Untuk web, hanya support gallery
        return await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality ?? 85,
        );
      } else {
        // Untuk mobile
        return await _picker.pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality ?? 85,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Alternative: Pick dengan HTML input (Web only)
  static Future<String?> pickImageWeb() async {
    if (!kIsWeb) return null;

    final completer = Completer<String?>();

    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;

    input.onChange.listen((e) async {
      final files = input.files;
      if (files?.isNotEmpty == true) {
        final file = files!.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          final result = reader.result as String;
          completer.complete(result);
        });

        reader.onError.listen((e) {
          completer.complete(null);
        });

        reader.readAsDataUrl(file);
      } else {
        completer.complete(null);
      }
    });

    input.click();
    return completer.future;
  }

  /// Validate image file size (in bytes)
  static bool isValidFileSize(int fileSize, {int maxSizeInMB = 5}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  /// Validate image file type
  static bool isValidImageType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return validExtensions.contains(extension);
  }
}
