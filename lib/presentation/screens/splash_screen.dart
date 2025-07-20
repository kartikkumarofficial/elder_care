// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../controllers/auth_controller.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    _authController = Get.find<AuthController>();
    _navigateBasedOnSession();
  }

  Future<void> _navigateBasedOnSession() async {
    await Future.delayed(Duration(seconds: 1));

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      await _authController.fetchRoleAndNavigate(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
