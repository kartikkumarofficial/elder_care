// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


import '../../app/utils/constants.dart';

class CloudinaryService {
  static const _cloudName = constants.cloudName; // or constants.cloudName depending on your file
  static const _uploadPreset = constants.uploadPreset;

  /// Uploads a File to Cloudinary and returns the secure_url or null on failure.
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri =
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final status = streamedResponse.statusCode;
      final responseBody = await streamedResponse.stream.bytesToString();

      if (status == 200 || status == 201) {
        final data = jsonDecode(responseBody);
        return data['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary upload failed: $status -> $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('CloudinaryService.uploadImage error: $e');
      return null;
    }
  }
}
