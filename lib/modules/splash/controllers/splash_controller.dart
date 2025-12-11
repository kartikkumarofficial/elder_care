import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/login_screen.dart';

class SplashController extends GetxController {
  final supabase = Supabase.instance.client;
  final AuthController authController = Get.find<AuthController>();

  @override
  void onReady() {
    super.onReady();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Show logo nicely

    try {
      // Try to recover the stored session safely
      print("[SPLASH] Checking saved session...");
      final session = supabase.auth.currentSession;

      if (session == null) {
        print("[SPLASH] No session found → go to Login");
        return Get.offAll(() => LoginScreen());
      }

      print("[SPLASH] Session found. Validating session…");

      // Manually validate / refresh the session
      await supabase.auth.refreshSession();

      // If refresh works → continue
      await authController.fetchRoleAndNavigate(session.user.id);
    } catch (e) {
      print("[SPLASH] Session invalid or refresh failed: $e");

      // Clear corrupted session (FIX for oauth_client_id error)
      try {
        await supabase.auth.signOut();
      } catch (_) {}

      Get.offAll(() => LoginScreen());
    }
  }
}
