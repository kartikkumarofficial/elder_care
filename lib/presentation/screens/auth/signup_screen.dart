
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controllers/auth_controller.dart';
import 'login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool loading = false;
  String? selectedRole; // Track the selected role

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUp() {
    setState(() {
      loading = true;
    });
    try {
      // Simulating sign-up process without Firebase
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var srcheight = MediaQuery.of(context).size.height;
    var srcwidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SingleChildScrollView(
        child: Container(
          width: srcwidth,
          height: srcheight,
          child: Column(
            children: [
              SizedBox(height: srcheight * 0.1),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: srcwidth * 0.08),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(srcwidth * 0.05),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(srcwidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            " Choose your role",
                            style: TextStyle(
                              fontSize: textScaleFactor * 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Updated text color for better contrast
                            ),
                          ),
                          SizedBox(height: srcheight * 0.02),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Caregiver Container
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Caregiver";
                                    });
                                  },
                                  child: Material(
                                    elevation: selectedRole == "Caregiver" ? 10 : 4,
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.green[300], // Green color for Caregiver
                                    child: Container(
                                      height: srcheight * 0.135,
                                      width: srcwidth * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Image.asset(
                                        "assets/images/caregiver.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 30),

                                // Care Seeker Container
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = "Careseeker";
                                    });
                                  },
                                  child: Material(
                                    elevation: selectedRole == "Careseeker" ? 10 : 4,
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.blue[300], // Blue color for Careseeker
                                    child: Container(
                                      height: srcheight * 0.135,
                                      width: srcwidth * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Image.asset(
                                        "assets/images/careseeker.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: srcheight * 0.02),
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: textScaleFactor * 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: srcheight * 0.01),
                          Text(
                            'Sign up to get started',
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
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Email is required";
                                    }
                                    return null;
                                  },
                                  controller: emailController,
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
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Password is required";
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
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
                                signUp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: srcwidth * 0.2,
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
                                : Text('Sign Up'),
                          ),
                          SizedBox(height: srcheight * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
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
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: textScaleFactor * 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: srcheight * 0.01),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
