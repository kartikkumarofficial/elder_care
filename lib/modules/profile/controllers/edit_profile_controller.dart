import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../auth/controllers/auth_controller.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final selectedImage = Rxn<File>();       // for temporary preview
  final imagePreview = "".obs;             // for network or file preview

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

  // ---------------------------------------------------------
  // PICK IMAGE (FilePicker, very stable vs ImagePicker)
  // ---------------------------------------------------------
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      selectedImage.value = file;
      imagePreview.value = file.path; // update preview instantly
    }
  }


  // ---------------------------------------------------------
  // SAVE PROFILE: Upload Image → Update DB → Update Auth → Go Back
  // ---------------------------------------------------------
  Future<void> saveProfileChanges() async {
    isLoading.value = true;

    try {
      String? profileUrl = authController.user.value?.profileImage;

      // 1) Upload new image if selected
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

      // 2) Save new name + email + profile image in Supabase table
      final uid = authController.user.value?.id;

      if (uid == null) {
        Get.snackbar("Error", "User not found");
        return;
      }

      final newName = nameController.text.trim();
      final newEmail = emailController.text.trim();

      await Supabase.instance.client
          .from("users")
          .update({
        "full_name": newName,
        "email": newEmail,
        "profile_image": profileUrl,
      })
          .eq("id", uid);

      // 3) Update Supabase Auth email if changed
      if (newEmail != authController.user.value?.email) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: newEmail),
        );
      }

      // 4) Update local model
      final u = authController.user.value;
      if (u != null) {
        u.fullName = newName;
        u.email = newEmail;
        u.profileImage = profileUrl;
        authController.user.refresh();
      }

      // 5) Exit the screen
      Get.back();
      Get.snackbar("Success", "Profile updated!");

    } catch (e) {
      debugPrint("saveProfileChanges error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
