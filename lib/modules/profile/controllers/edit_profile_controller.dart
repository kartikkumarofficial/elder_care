
import 'dart:io';
import 'package:elder_care/modules/auth/controllers/auth_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/cloudinary_service.dart';

class EditProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Text fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Pickers
  final ImagePicker _picker = ImagePicker();

  // Reactive state
  final RxBool isProcessing = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxString imagePreview = "".obs;

  @override
  void onInit() {
    super.onInit();
    final user = authController.user.value;
    nameController.text = user?.fullName ?? "";
    emailController.text = user?.email ?? "";
    imagePreview.value = user?.profileImage ?? "";
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// ---------------------------------------------
  /// PICK → CROP (1:1) → UPLOAD (Cloudinary) → SAVE
  /// ---------------------------------------------
  Future<void> pickCropUploadImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      // Crop to 1:1
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color(0xFF7AB7A7),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          )
        ],
      );

      if (cropped == null) return;

      isUploadingImage.value = true;

      File file = File(cropped.path);

      // Upload to Cloudinary
      final uploadedUrl = await CloudinaryService.uploadImage(file);
      if (uploadedUrl == null) {
        Get.snackbar("Upload failed", "Could not upload image.");
        return;
      }

      // Update Supabase users table
      final updated = await authController.updateUserData({
        "profile_image": uploadedUrl,
      });

      if (!updated) {
        Get.snackbar("Error", "Could not save image to database.");
        return;
      }

      // Update local user for instant UI refresh
      final localUser = authController.user.value;
      if (localUser != null) {
        localUser.profileImage = uploadedUrl;
        authController.user.refresh();
      }

      imagePreview.value = uploadedUrl;

      Get.snackbar("Success", "Profile picture updated!");

    } catch (e) {
      debugPrint("pickCropUploadImage error: $e");
      Get.snackbar("Error", "Something went wrong.");
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// ---------------------------------------------
  /// SAVE NAME + EMAIL (with Supabase Auth update)
  /// ---------------------------------------------
  Future<void> saveProfileChanges() async {
    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();
    final user = authController.user.value;

    if (user == null) {
      Get.snackbar("Error", "No user found.");
      return;
    }

    if (newName.isEmpty) {
      Get.snackbar("Error", "Name cannot be empty.");
      return;
    }
    if (newEmail.isEmpty) {
      Get.snackbar("Error", "Email cannot be empty.");
      return;
    }

    try {
      isProcessing.value = true;

      bool emailChanged = newEmail != user.email;

      // If email changed → update in Supabase Auth
      if (emailChanged) {
        final res = await authController.supabase.auth.updateUser(
          UserAttributes(email: newEmail),
        );

        if (res.user == null) {
          Get.snackbar("Error", "Email update failed (Supabase Auth)");
          return;
        }
      }

      // Update database row in users table
      final updated = await authController.updateUserData({
        "full_name": newName,
        if (emailChanged) "email": newEmail,
      });

      if (!updated) {
        Get.snackbar("Error", "Failed to update profile details.");
        return;
      }

      // Update local model
      user.fullName = newName;
      if (emailChanged) user.email = newEmail;

      authController.user.refresh();

      Get.snackbar("Success", "Profile updated successfully!");
      Get.back();

    } catch (e) {
      debugPrint("saveProfileChanges error: $e");
      Get.snackbar("Error", "Something went wrong.");
    } finally {
      isProcessing.value = false;
    }
  }
}
