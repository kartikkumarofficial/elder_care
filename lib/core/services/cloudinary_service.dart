import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../app/utils/constants.dart';

class CloudinaryService {
  static const _cloudName = constants.cloudName;
  static const _uploadPreset = constants.uploadPreset;

  static final _apiKey = constants.cloudinaryApiKey;
  static final _apiSecret = constants.cloudinaryApiSecret;

  /// Extract public_id from Cloudinary URL
  static String? extractPublicId(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final path = uri.path; // /image/upload/v123/filename_abc.jpg
      final segments = path.split('/');
      final fileName = segments.last; // filename_abc.jpg
      final publicId = fileName.split('.').first; // filename_abc
      return publicId;
    } catch (_) {
      return null;
    }
  }

  /// Deletes old image from Cloudinary
  static Future<bool> deleteImage(String publicId) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/resources/image/upload?public_ids[]=$publicId'
    );

    final authHeader = 'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}';

    final res = await http.delete(
      url,
      headers: {"Authorization": authHeader},
    );

    if (res.statusCode == 200) {
      debugPrint("Cloudinary: Old image deleted → $publicId");
      return true;
    }

    debugPrint("Cloudinary delete failed: ${res.body}");
    return false;
  }

  /// Uploads a File to Cloudinary + cleans up old image
  static Future<String?> uploadImage(File imageFile, {String? oldUrl}) async {
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
        final newUrl = data['secure_url'] as String?;

        // AUTO CLEANUP: Delete old image
        if (oldUrl != null && oldUrl.isNotEmpty) {
          final publicId = extractPublicId(oldUrl);
          if (publicId != null) {
            deleteImage(publicId);
          }
        }

        return newUrl;
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
