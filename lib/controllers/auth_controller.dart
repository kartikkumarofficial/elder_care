// controllers/auth_controller.dart

import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screen files
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
// import '../presentation/screens/caregiver_dashboard.dart'; // Assuming this is your caregiver dashboard
import '../presentation/screens/carereciever_dashboard.dart';
import '../presentation/screens/dashboard_screen.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable properties for UI reactivity
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Handles the entire user sign-up process.
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    isLoading.value = true;
    try {
      // Step 1: Sign up the user with Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Sign up failed. Please try again.';
      }

      // Step 2: Insert user details into the public 'users' table
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        // FIX: Use 'full_name' to match your AppUser model
        'username': name,
        // Role will be updated in the next step
        'profile_image': 'https://api.dicebear.com/6.x/pixel-art/png?seed=$email',
      });

      // Clear text fields after successful signup
      nameController.clear();
      emailController.clear();
      passwordController.clear();

      // Step 3: Navigate to Role Selection Screen
      Get.offAll(() => RoleSelectionView());

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the user's role and navigates to the correct dashboard.
  Future<void> updateUserRoleAndNavigate(String role) async {
    isLoading.value = true;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw "User not found. Please log in again.";

      // Step 1: Update the user's role in the database
      await supabase
          .from('users')
          .update({'role': role})
          .eq('id', userId);

      // Step 2: Navigate to the correct dashboard based on the role
      _navigateToDashboard(role);

    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  /// Handles the user login process and redirects based on role.
  Future<void> logIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    isLoading.value = true;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Login failed. Invalid credentials.';
      }

      // Clear fields after successful login
      emailController.clear();
      passwordController.clear();

      // Fetch user role and redirect
      await _fetchRoleAndNavigate(response.user!.id);

    } catch (e) {
      Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches user role from the database and navigates to the dashboard.
  Future<void> _fetchRoleAndNavigate(String userId) async {
    final response = await supabase
        .from('users')
        .select('role')
        .eq('id', userId)
        .single(); // Use .single() for efficiency

    final role = response['role'];

    if (role == null) {
      // If role is not set, send them to the role selection screen
      Get.offAll(() => RoleSelectionView());
    } else {
      _navigateToDashboard(role as String);
    }
  }

  /// Centralized navigation logic.
  void _navigateToDashboard(String role) {
    if (role == 'caregiver') {
      // NOTE: Make sure you have a `DashboardScreen` for caregivers
      Get.offAll(() => MainScaffold());
    } else {
      Get.offAll(() => CareReceiverDashboard());
    }
  }
}