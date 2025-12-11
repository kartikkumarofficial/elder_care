import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordEmailScreen extends StatelessWidget {
  ForgotPasswordEmailScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Reset Password",
                  style: GoogleFonts.nunito(
                    fontSize: w * 0.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: h * 0.01),

                Text(
                  "Enter your email and we’ll send you a reset link.",
                  style: GoogleFonts.nunito(
                    fontSize: w * 0.042,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: h * 0.06),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Colors.teal.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      BorderSide(color: Colors.teal.shade400, width: 2),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.06),

                Obx(
                      () => ElevatedButton(
                    //     onPressed: (){},
                    onPressed: authController.isLoading.value
                        ? null

                        : () async {
                      await authController.resetPassword(
                        emailController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7AB7A7),
                      minimumSize: Size(double.infinity, h * 0.065),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5)
                        : Text(
                      "Send Reset Link",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.03),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    "Back to Login",
                    style: GoogleFonts.nunito(
                      color: Colors.teal.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: w * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
