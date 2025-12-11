// presentation/screens/auth/new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

class NewPasswordScreen extends StatelessWidget {
  NewPasswordScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFeaf4f2), Color(0xFFfdfaf6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/role2.png"),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.08),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Set New Password",
                      style: GoogleFonts.nunito(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w800,
                      )),
                  SizedBox(height: h * 0.02),
                  Text(
                    "Create a new password for your account.",
                    style: GoogleFonts.nunito(fontSize: w * 0.04, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: h * 0.04),
                  TextFormField(
                    controller: newPassController,
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'Use at least 6 characters' : null,
                    decoration: InputDecoration(
                      hintText: "New Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  TextFormField(
                    controller: confirmPassController,
                    obscureText: true,
                    validator: (v) => v != newPassController.text ? 'Passwords do not match' : null,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  Obx(() => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        authController.setNewPassword(newPassController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7AB7A7),
                      minimumSize: Size(double.infinity, h * 0.065),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                        : Text("Set Password", style: GoogleFonts.nunito(color:Colors.white,fontWeight: FontWeight.bold, fontSize: w * 0.045)),
                  )),
                  SizedBox(height: h * 0.02),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text("Back", style: GoogleFonts.nunito(color: Colors.teal.shade600, fontWeight: FontWeight.w700)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
