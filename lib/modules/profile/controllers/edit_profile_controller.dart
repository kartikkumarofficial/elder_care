import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/cloudinary_service.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Country code (default India)
  final selectedCountryCode = "+91".obs;

  // UI state
  final isLoading = false.obs;

  // Image handling
  final selectedImage = Rxn<File>();
  final imagePreview = "".obs;

  @override
  void onInit() {
    super.onInit();

    final user = authController.user.value;

    nameController.text = user?.fullName ?? "";
    emailController.text = user?.email ?? "";
    imagePreview.value = user?.profileImage ?? "";

    // Load phone number if exists (split +91 & number)
    if (user?.phone != null && user!.phone!.isNotEmpty) {
      final phone = user.phone!;

      if (phone.startsWith("+")) {
        final match = RegExp(r'^(\+\d{1,3})(\d+)$').firstMatch(phone);
        if (match != null) {
          selectedCountryCode.value = match.group(1)!;
          phoneController.text = match.group(2)!;
        }
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------
  // PICK IMAGE (FilePicker)
  // ---------------------------------------------------------
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      selectedImage.value = file;
      imagePreview.value = file.path;
    }
  }

  // ---------------------------------------------------------
  // SAVE PROFILE CHANGES
  // ---------------------------------------------------------
  Future<void> saveProfileChanges() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final uid = authController.user.value?.id;
      if (uid == null) {
        Get.snackbar("Error", "User not found");
        return;
      }

      final newName = nameController.text.trim();
      final newEmail = emailController.text.trim();
      final phone = phoneController.text.trim();

      // Phone validation
      if (phone.isNotEmpty && phone.length < 8) {
        Get.snackbar(
          "Invalid phone number",
          "Please enter a valid phone number",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final fullPhone = phone.isEmpty
          ? null
          : "${selectedCountryCode.value}$phone";

      String? profileUrl = authController.user.value?.profileImage;

      // Upload new image if selected
      if (selectedImage.value != null) {
        final uploadedUrl = await CloudinaryService.uploadImage(
          selectedImage.value!,
          oldUrl: profileUrl,
        );

        if (uploadedUrl == null) {
          Get.snackbar("Error", "Image upload failed");
          return;
        }

        profileUrl = uploadedUrl;
      }

      // Update user table
      await Supabase.instance.client.from("users").update({
        "full_name": newName,
        "email": newEmail,
        "profile_image": profileUrl,
        "phone": fullPhone,
      }).eq("id", uid);

      // Update auth email if changed
      if (newEmail != authController.user.value?.email) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: newEmail),
        );
      }

      // Update local user model
      final u = authController.user.value;
      if (u != null) {
        u.fullName = newName;
        u.email = newEmail;
        u.profileImage = profileUrl;
        u.phone = fullPhone;
        authController.user.refresh();
      }

      Get.back();
      Get.snackbar("Success", "Profile updated successfully");

    } catch (e) {
      debugPrint("saveProfileChanges error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
