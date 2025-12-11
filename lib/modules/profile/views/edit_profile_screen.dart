import 'dart:io';
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
        title: Text(
          'Edit Profile',
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87),
        ),
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
              SizedBox(height: h * 0.10),

              Obx(() {
                final preview = controller.imagePreview.value;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Hero(
                      tag: "profile-avatar",
                      child: CircleAvatar(
                        radius: w * 0.20,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: controller.selectedImage.value != null
                            ? FileImage(controller.selectedImage.value!)
                            : (preview.startsWith("http")
                            ? NetworkImage(preview)
                            : null),
                        child: (preview.isEmpty)
                            ? Icon(Icons.person, size: w * 0.20, color: Colors.grey)
                            : null,
                      ),
                    ),

                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          width: w * 0.12,
                          height: w * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF7AB7A7),
                            child: Icon(Icons.edit, color: Colors.white, size: w * 0.06),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: h * 0.03),

              buildField("Full Name", controller.nameController, w),
              SizedBox(height: h * 0.02),

              buildField("Email", controller.emailController, w, email: true),
              SizedBox(height: h * 0.04),

              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    await controller.saveProfileChanges();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AB7A7),
                    minimumSize: Size(double.infinity, h * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.04),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'Save Changes',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.045,
                    ),
                  ),
                );
              }),

              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller, double w,
      {bool email = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(w * 0.04),
              borderSide: BorderSide.none,
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
