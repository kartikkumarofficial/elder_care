import 'package:elder_care/controllers/dashboard_controller.dart';
import 'package:elder_care/presentation/screens/auth/signup_screen.dart' hide AuthController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var srcheight = MediaQuery.of(context).size.height;
    var srcwidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: srcwidth,
            padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: srcwidth * 0.05),
                Text(
                  'RentRover',
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: srcheight * 0.02),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/doc_aunt.png",
                    fit: BoxFit.fill,
                    width: srcwidth * 0.8,
                    height: srcheight * 0.2,
                  ),
                ),
                SizedBox(height: srcheight * 0.015),
                _buildFeatureCards(srcheight, srcwidth, textScaleFactor),
                SizedBox(height: srcheight * 0.02),
                _buildLoginCard(srcheight, srcwidth, textScaleFactor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards(double srcheight, double srcwidth, double textScaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _featureCard(Icons.favorite_border_outlined, "Health\nMonitoring", srcheight, srcwidth, textScaleFactor),
        SizedBox(width: srcwidth * 0.05),
        _featureCard(Icons.location_on_outlined, "Location\nTracking", srcheight, srcwidth, textScaleFactor),
        SizedBox(width: srcwidth * 0.05),
        _featureCard(Icons.medical_information_outlined, "Medication\nAlerts", srcheight, srcwidth, textScaleFactor),
      ],
    );
  }

  Widget _featureCard(IconData icon, String label, double srcheight, double srcwidth, double textScaleFactor) {
    return Expanded(
      child: Card(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: srcheight * 0.12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueAccent),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: textScaleFactor * 14, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(double srcheight, double srcwidth, double textScaleFactor) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(srcwidth * 0.05)),
      child: Padding(
        padding: EdgeInsets.all(srcwidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Login', style: TextStyle(fontSize: textScaleFactor * 28, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: srcheight * 0.01),
            Text('Welcome back, please log in', style: TextStyle(fontSize: textScaleFactor * 18, color: Colors.black54)),
            SizedBox(height: srcheight * 0.05),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: authController.emailController,
                    decoration: _inputDecoration('Email', 'Enter your email', Icons.email_outlined, srcwidth),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Email cannot be empty' : null,
                  ),
                  SizedBox(height: srcheight * 0.02),
                  TextFormField(
                    controller: authController.passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: _inputDecoration(
                      'Password',
                      'Enter your password',
                      Icons.lock_outline,
                      srcwidth,
                      trailingIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Password cannot be empty' : null,
                  ),
                  SizedBox(height: srcheight * 0.03),
                ],
              ),
            ),
            SizedBox(height: srcheight * 0.03),
            Obx(() => ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await authController.logIn();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.3, vertical: srcheight * 0.02),
                textStyle: TextStyle(fontSize: textScaleFactor * 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(srcwidth * 0.04)),
                elevation: 5,
              ),
              child: authController.isLoading.value
                  ? CircularProgressIndicator(strokeWidth: 3, color: Colors.white)
                  : Text('Login'),
            )),
            SizedBox(height: srcheight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: TextStyle(color: Colors.black54, fontSize: textScaleFactor * 14)),
                GestureDetector(
                  onTap: () => Get.to(() => SignUpScreen()),
                  child: Text('Sign Up', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: textScaleFactor * 14)),
                ),
              ],
            ),
            SizedBox(height: srcheight * 0.01),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon, double width, {Widget? trailingIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: trailingIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(width * 0.04)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }
}
