import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screen files, models, and other controllers
import '../models/user_model.dart'; // <-- IMPORT THE NEW MODEL
import '../presentation/caregiver_dashboard.dart';
import '../presentation/screens/care_id_display_screen.dart';
import '../presentation/screens/care_link_screen.dart';
import '../presentation/screens/carereciever_dashboard.dart';
import 'care_link_controller.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/auth/login_screen.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Observable property to hold the current user's data
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable properties for UI reactivity
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Handles the entire user sign-up process.
  Future<void> signUp() async {
    isLoading.value = true;
    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        throw 'Sign up failed. Please try again.';
      }

      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'profile_image': 'https://api.dicebear.com/6.x/pixel-art/png?seed=${emailController.text.trim()}',
      });

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Get.offAll(() => RoleSelectionView());

    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigates user to the correct linking flow after role selection.
  Future<void> updateUserRoleAndNavigate(String role) async {
    isLoading.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User not found. Please log in again.";

      await supabase.from('users').update({'role': role}).eq('id', userId);

      // After updating the role, fetch all user data to update our state
      await fetchRoleAndNavigate(userId);

    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles the user login process and redirects based on role and link status.
  Future<void> logIn() async {
    isLoading.value = true;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) throw 'Login failed. Invalid credentials.';

      emailController.clear();
      passwordController.clear();

      await fetchRoleAndNavigate(response.user!.id);

    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches FULL user profile, stores it in the observable 'user' property,
  /// and navigates to the correct dashboard.
  Future<void> fetchRoleAndNavigate(String userId) async {
    try {
      print('[DEBUG] Fetching user data for ID: $userId');

      final response = await supabase
          .from('users')
          .select() // Select all columns
          .eq('id', userId)
          .single();

      print('[DEBUG] Supabase response: $response');

      // Create a UserModel instance and update the observable
      user.value = UserModel.fromJson(response);

      final role = user.value?.role;
      final linkedUserId = user.value?.linkedUserId;

      if (role == null) {
        print('[DEBUG] Role is null');
        Get.offAll(() => RoleSelectionView());
      } else if (role == 'caregiver') {
        if (linkedUserId == null) {
          print('[DEBUG] Caregiver not linked');
          Get.offAll(() => CareLinkScreen());
        } else {
          print('[DEBUG] Caregiver linked → navigating to MainScaffold');
          Get.offAll(() => MainScaffold());
        }
      } else { // Role is 'receiver'
        print('[DEBUG] Receiver → navigating to CareReceiverDashboard');
        // This part of your logic might need adjustment based on receiver flow
        // For now, assuming it's correct.
        final careLinkController = Get.put(CareLinkController());
        final careId = await careLinkController.generateAndAssignCareId(userId);
        Get.offAll(() => CareIdDisplayScreen(careId: careId));
      }
    } catch (e) {
      print('[ERROR] fetchRoleAndNavigate failed: $e');

      Get.snackbar(
        'Error',
        'Could not retrieve user details. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      Get.offAll(() => LoginScreen());
    }
  }
}
