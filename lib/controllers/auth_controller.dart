import 'dart:async';
import 'dart:io';

import 'package:elder_care/presentation/screens/auth/login_screen.dart';
import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../presentation/caregiver_dashboard.dart';
import '../presentation/screens/care_id_display_screen.dart';
import '../presentation/screens/care_link_screen.dart';
import '../presentation/screens/carereciever_dashboard.dart';
import 'care_link_controller.dart';
import '../presentation/screens/auth/role_selection_screen.dart';

class AuthController extends GetxController {

  final SupabaseClient supabase = Supabase.instance.client;

  final Rx<UserModel?> user = Rx<UserModel?>(null);


  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


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

      final careLinkController = Get.find<CareLinkController>();
      await careLinkController.generateAndAssignCareId(response.user!.id);

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

  /// Fetches FULL user profile, stores it in the observable 'user' property, and navigates to the correct dashboard.
  Future<void> fetchRoleAndNavigate(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      user.value = UserModel.fromJson(response);

      final role = user.value?.role;

      if (role == null) {
        Get.offAll(() => RoleSelectionView());
        return;
      }

      if (role == "caregiver") {
        // Fetch all receivers linked to this caregiver
        final links = await supabase
            .from('care_links')
            .select('receiver_id')
            .eq('caregiver_id', userId);

        if (links.isEmpty) {
          Get.offAll(() => CareLinkScreen());
        } else {
          Get.offAll(() => MainScaffold()); // Caregiver dashboard
        }
      } else if (role == "receiver") {
        final careId = user.value?.careId;

        // Show the receiver their care ID screen if not connected
        final links = await supabase
            .from('care_links')
            .select('caregiver_id')
            .eq('receiver_id', userId);

        if (links.isEmpty) {
          Get.offAll(() => CareIdDisplayScreen(careId: careId!));
        } else {
          Get.offAll(() => CareReceiverDashboard());
        }
      }

    } catch (e) {
      Get.snackbar('Error', 'Could not load user data.',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAll(() => LoginScreen());
    }
  }



  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      supabase.auth.onAuthStateChange.listen((event) async {
        final session = event.session;

        if (session != null) {
          print("Google Login Success: ${session.user.id}");

          // Insert user if first time → generate care ID inside this call
          await insertUserIfNew(session.user);

          // Navigate properly
          await fetchRoleAndNavigate(session.user.id);
        }
      });
    } catch (e) {
      print("Google error: $e");
    }
  }







  /// Helper function to insert new users into Supabase
  Future<void> insertUserIfNew(User user) async {
    final existing = await supabase.from('users').select().eq('id', user.id).maybeSingle();

    if (existing == null) {
      // Insert new Google user
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? 'Anonymous',
        'profile_image': user.userMetadata?['avatar_url'] ??
            'https://api.dicebear.com/6.x/pixel-art/png?seed=${user.email}',
      });

      //  Generate Care ID ONLY for new Google user
      final careLinkController = Get.find<CareLinkController>();

      await careLinkController.generateAndAssignCareId(user.id);
    }
  }




  /// Logs out the user from Supabase and clears local session data.
  Future<void> logOut() async {
    try {
      isLoading.value = true;

      // Sign out from Supabase
      await supabase.auth.signOut();

      print('✅ User signed out successfully');

      // Optionally navigate to login, but keep local data intact
      Get.offAll(() => LoginScreen());

    } catch (e) {
      print('❌ Error signing out: $e');
      Get.snackbar(
        'Logout Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


}
