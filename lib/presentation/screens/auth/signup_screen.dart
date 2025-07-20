// Add at the top
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var srcheight = MediaQuery.of(context).size.height;
    var srcwidth = MediaQuery.of(context).size.width;
    var textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.08,vertical: srcwidth*0.2),
                    child: Column(
                      children: [
                        SizedBox(height: srcheight * 0.05),
                        _buildRoleSelectionCard(srcwidth, srcheight, textScaler),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleSelectionCard(
      double srcwidth, double srcheight, TextScaler textScaler) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(srcwidth * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(srcwidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text(
            //   "Choose your role",
            //   style: TextStyle(
            //     fontSize: textScaler.scale(28),
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // SizedBox(height: srcheight * 0.02),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     roleOption(srcwidth, srcheight, "Caregiver",
            //         "assets/images/caregiver.png", Colors.green[300]!),
            //     roleOption(srcwidth, srcheight, "Careseeker",
            //         "assets/images/careseeker.png", Colors.blue[300]!),
            //   ],
            // ),
            // SizedBox(height: srcheight * 0.03),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: textScaler.scale(28),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: srcheight * 0.01),
            Text(
              'Sign up to get started',
              style: TextStyle(
                fontSize: textScaler.scale(18),
                color: Colors.black54,
              ),
            ),
            SizedBox(height: srcheight * 0.03),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: authController.nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      } else if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                    decoration: buildInputDecoration(
                      srcwidth,
                      'Name',
                      'Enter your name',
                      icon: Icons.person,
                    ),
                  ),
                  SizedBox(height: srcheight * 0.02),

                  // Email Field
                  TextFormField(
                    controller: authController.emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    decoration: buildInputDecoration(
                      srcwidth,
                      'Email',
                      'Enter your email',
                      icon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: srcheight * 0.02),

                  // Password Field
                  Obx(() => TextFormField(
                    controller: authController.passwordController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      } else if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    obscureText: !authController.isPasswordVisible.value,
                    decoration: buildInputDecoration(
                      srcwidth,
                      'Password',
                      'Enter your password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(authController.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                    ),
                  )),
                  SizedBox(height: srcheight * 0.02),

                  // Confirm Password Field
                  TextFormField(
                    controller: authController.passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please confirm your password';
                      } else if (value.trim() !=
                          authController.passwordController.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: buildInputDecoration(
                      srcwidth,
                      'Confirm Password',
                      'Re-enter your password',
                      icon: Icons.lock,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: srcheight * 0.03),

            // Submit Button
            Obx(() => ElevatedButton(
              onPressed:authController.isLoading.value?null: () {
                if (_formKey.currentState!.validate()) {
                  authController.signUp();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: srcwidth * 0.2,
                    vertical: srcheight * 0.02),
                textStyle: TextStyle(
                  fontSize: textScaler.scale(18),
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(srcwidth * 0.04),
                ),
                elevation: 5,
              ),
              child: authController.isLoading.value
                  ? CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              )
                  : Text('Sign Up'),
            )),
            SizedBox(height: srcheight * 0.03),

            // Login Redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: textScaler.scale(14),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/login'),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: textScaler.scale(14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: srcheight * 0.01),
          ],
        ),
      ),
    );
  }



  InputDecoration buildInputDecoration(double width, String label, String hint,
      {IconData? icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }
}
