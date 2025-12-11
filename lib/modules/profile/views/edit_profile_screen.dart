// lib/presentation/screens/profile/edit_profile_screen.dart
import 'dart:io';
// import 'package:elder_care/controllers/edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final EditProfileController controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Edit Profile', style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back, color: Colors.black87)),
      ),
      body: Container(
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFeaf4f2), Color(0xFFfdfaf6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.07, vertical: h * 0.03),
          child: Column(
            children: [
              SizedBox(height: h * 0.01),

              /// Avatar preview + edit badge
              Obx(() {
                final preview = controller.imagePreview.value;
                final isUploading = controller.isUploadingImage.value;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: w * 0.20,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: (preview.isEmpty)
                          ? null
                          : (preview.startsWith('http') ? NetworkImage(preview) : FileImage(File(preview)) as ImageProvider),
                      child: preview.isEmpty ? Icon(Icons.person, size: w * 0.20, color: Colors.grey) : null,
                    ),

                    // spinner overlay when uploading
                    if (isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.35)),
                          child: Center(child: SizedBox(width: w * 0.08, height: w * 0.08, child: const CircularProgressIndicator(color: Colors.white))),
                        ),
                      ),

                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: controller.pickCropUploadImage,
                        child: Container(
                          width: w * 0.12,
                          height: w * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: CircleAvatar(backgroundColor: const Color(0xFF7AB7A7), child: Icon(Icons.edit, color: Colors.white, size: w * 0.06)),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: h * 0.03),

              // Full name
              Align(alignment: Alignment.centerLeft, child: Text('Full Name', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.black87))),
              SizedBox(height: 6),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(w * 0.04), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),

              SizedBox(height: h * 0.02),

              // Email
              Align(alignment: Alignment.centerLeft, child: Text('Email', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.black87))),
              SizedBox(height: 6),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(w * 0.04), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),

              SizedBox(height: h * 0.04),

              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isProcessing.value ? null : controller.saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AB7A7),
                    minimumSize: Size(double.infinity, h * 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.04)),
                  ),
                  child: controller.isProcessing.value
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Save Changes', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold, fontSize: w * 0.045)),
                );
              }),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
