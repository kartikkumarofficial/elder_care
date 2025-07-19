
import 'package:elder_care/presentation/screens/auth/signup_screen.dart';
import 'package:elder_care/presentation/screens/main_scaffold.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {

   LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;





  @override
  Widget build(BuildContext context) {
    var srcheight = MediaQuery.of(context).size.height;
    var srcwidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: srcwidth,
        height: srcheight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.08),
                child: Column(
                  children: [
                    SizedBox(height: srcwidth*0.1,),
                    Text(
                      'RentRover',

                      style: GoogleFonts.pacifico(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                    // Text(
                    //   'Welcome to ElderCare+',
                    //   style: TextStyle(
                    //     fontSize: textScaleFactor * 26,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    SizedBox(height: srcheight * 0.02),

                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Image.asset(
                        "assets/images/doc_aunt.png",
                        fit: BoxFit.fill,
                        width: srcwidth * 0.8,
                        height: srcheight * 0.2,
                      ),
                    ),
                    SizedBox(height: srcheight * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.0145),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Elevated Health Monitoring Container
                          Expanded(
                            child: Card(
                              elevation: 10, // Adds elevation
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: srcheight * 0.12, // Set the height of the containers
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_border_outlined, color: Colors.blueAccent),
                                    Text("Health\nMonitoring", textAlign: TextAlign.center, style: TextStyle(fontSize: textScaleFactor * 14, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: srcwidth * 0.05), // Add spacing between containers
                          // Elevated Location Tracking Container
                          Expanded(
                            child: Card(
                              elevation: 10, // Adds elevation
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: srcheight * 0.12, // Same height for consistency
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                                    Text("Location\nTracking", textAlign: TextAlign.center, style: TextStyle(fontSize: textScaleFactor * 14, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: srcwidth * 0.05), // Add spacing between containers
                          // Elevated Medication Alerts Container
                          Expanded(
                            child: Card(
                              elevation: 10, // Adds elevation
                              shadowColor: Colors.black.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                height: srcheight * 0.12, // Same height for consistency
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.medical_information_outlined, color: Colors.blueAccent),
                                    Text("Medication\nAlerts", textAlign: TextAlign.center, style: TextStyle(fontSize: textScaleFactor * 14, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: srcheight * 0.02),
                    Card(
                      elevation: 10,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(srcwidth * 0.05),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left:srcwidth * 0.05,right: srcwidth * 0.05,top: srcwidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(height: srcheight * 0.02),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: textScaleFactor * 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: srcheight * 0.01),
                            Text(
                              'Welcome back, please log in',
                              style: TextStyle(
                                fontSize: textScaleFactor * 18,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: srcheight * 0.05),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: authController.emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(srcwidth * 0.04),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(srcwidth * 0.04),
                                        borderSide: const BorderSide(
                                          color: Colors.blueAccent,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: srcheight * 0.02),
                                  TextFormField(
                                    controller:authController.passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(srcwidth * 0.04),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(srcwidth * 0.04),
                                        borderSide: const BorderSide(
                                          color: Colors.blueAccent,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                    obscureText: !_isPasswordVisible,
                                  ),
                                  SizedBox(height: srcheight * 0.03),
                                ],
                              ),
                            ),
                            SizedBox(height: srcheight * 0.03),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  authController.logIn();
                                }
                              },
                              style: ElevatedButton.styleFrom(

                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: srcwidth * 0.3,
                                  vertical: srcheight * 0.02,
                                ),
                                textStyle: TextStyle(
                                  fontSize: textScaleFactor * 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(srcwidth * 0.04),
                                ),
                                elevation: 5,
                              ),
                              child: loading
                                  ? CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              )
                                  : Text('Login'),
                            ),
                            SizedBox(height: srcheight * 0.03),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: textScaleFactor * 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpScreen()));
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: textScaleFactor * 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: srcheight * 0.01),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}