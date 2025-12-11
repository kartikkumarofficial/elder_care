
import 'dart:io';

import 'package:elder_care/modules/auth/controllers/auth_controller.dart';
import 'package:elder_care/modules/profile/views/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/cloudinary_service.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final SupabaseClient supabase = Supabase.instance.client;

  final RxBool isUploading = false.obs;
  final ImagePicker _picker = ImagePicker();

  /// Pick + Upload to Cloudinary + Update Supabase user table
  Future<void> pickAndUploadImage() async {
    try {
      final XFile? picked =
      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final File imageFile = File(picked.path);
      isUploading.value = true;

      // 1) Upload to Cloudinary
      final url = await CloudinaryService.uploadImage(imageFile);

      if (url == null) {
        Get.snackbar("Upload Failed", "Could not upload image",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
        return;
      }

      // 2) Update Supabase users table (snake_case)
      final success = await authController.updateUserData({"profile_image": url});

      if (!success) {
        Get.snackbar("Error", "Failed to update profile image",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
        return;
      }

      // 3) Update local reactive user model
      final localUser = authController.user.value;
      if (localUser != null) {
        localUser.profileImage = url; // your model uses camelCase
        authController.user.refresh();
      }

      Get.snackbar("Success", "Profile image updated!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
    } catch (e) {
      debugPrint("pickAndUploadImage error: $e");
      Get.snackbar("Error", "Something went wrong", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
    } finally {
      isUploading.value = false;
    }
  }
  Future<void> refreshProfile() async {
    try {
      final uid = authController.user.value?.id;
      if (uid == null) return;

      final data = await supabase.from('users').select().eq('id', uid).single();

      authController.user.value = UserModel.fromJson(data);
    } catch (e) {
      print("Profile refresh error: $e");
    }
  }


  void onEditProfileTap() => Get.to(() => EditProfileScreen());
  void onLinkedTap() => Get.toNamed('/linked-care');
  void onPrivacyTap() => Get.toNamed('/privacy');
  void onHelpTap() => Get.toNamed('/help');

  void onLogoutTap() => authController.logOut();
}
