import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/post_model.dart';

class PostController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  static const _cloudName = constants.cloudName;
  static const _uploadPreset = constants.uploadPreset;

  var isUploading = false.obs;

  Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      print("Cloudinary Status Code: ${res.statusCode}");
      print("Cloudinary Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Exception: $e");
      return null;
    }
  }


  Future<void> uploadPost({
    required File image,
    required String caption,
    required DateTime scheduledAt,
  }) async {
    isUploading.value = true;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      Get.snackbar("Error", "User not logged in.",colorText: Colors.white,);
      isUploading.value = false;
      return;
    }

    final imageUrl = await uploadToCloudinary(image);
    if (imageUrl == null) {
      Get.snackbar("Error", "Image upload failed.",colorText: Colors.white,);
      isUploading.value = false;
      return;
    }

    final response = await supabase.from('posts').insert({
      'image_url': imageUrl,
      'caption': caption,
      'scheduled_at': scheduledAt.toIso8601String(),
      'user_id': userId,
    }).select();

    if (response.isEmpty) {
      Get.snackbar("Error", "Failed to insert post.",colorText: Colors.white,);
    } else {
      Get.snackbar("Success", "Post uploaded successfully.",colorText: Colors.white,);
    }



    isUploading.value = false;
  }

  Future<List<PostModel>> fetchScheduledPosts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('posts')
        .select()
        .eq('user_id', userId)
        .gt('scheduled_at', DateTime.now().toIso8601String());

    if (response is List) {
      return response.map((e) => PostModel.fromJson(e)).toList();
    } else {
      print("Scheduled Post Fetch Error: $response");
      return [];
    }
  }

}
