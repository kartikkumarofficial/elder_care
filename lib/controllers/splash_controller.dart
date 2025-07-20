import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_controller.dart';
import '../presentation/screens/auth/login_screen.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  @override
  void onReady() {
    super.onReady();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // A short delay to allow the splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // If a session exists, the user is already logged in.
        // We can use your existing function to fetch their data and navigate.
        print('[SPLASH] Session found. Fetching user profile...');
        await authController.fetchRoleAndNavigate(session.user.id);
      } else {
        // If no session, send them to the login screen.
        print('[SPLASH] No session. Navigating to LoginScreen.');
        Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      // In case of any error, default to the login screen.
      print('[SPLASH] Error during session check: $e');
      Get.offAll(() => LoginScreen());
    }
  }
}
