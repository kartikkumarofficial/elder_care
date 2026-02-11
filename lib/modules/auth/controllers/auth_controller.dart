import 'dart:async';
import 'dart:io';

import 'package:elder_care/modules/dashboard/views/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_model.dart';

import '../../care_receiver/controllers/carereceiver_dashboard_controller.dart';

import '../../caregiver/controllers/caregiver_dashboard_controller.dart';
import '../../caregiver/views/caregiver_dashboard.dart';
import '../../care_receiver/views/care_id_display_screen.dart';
import '../../caregiver/views/care_link_screen.dart';
import '../../care_receiver/views/carereciever_dashboard.dart';

import '../../caregiver/controllers/care_link_controller.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../views/login_screen.dart';
import '../views/new_password_screen.dart';
import '../views/role_selection_screen.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Observables
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final wrongPassword = false.obs;
  final isPasswordVisible = false.obs;

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    initAuthListener(); // This handles password reset deep links and centralizes auth handling
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  
  // AUTH STATE LISTENER
  
  void initAuthListener() {
    // Ensure we don't attach multiple listeners accidentally
    _authSubscription?.cancel();

    _authSubscription = supabase.auth.onAuthStateChange.listen((event) async {
      final authEvent = event.event;
      final session = event.session;

      print("🔥 Auth Event: $authEvent");

      // When user clicks reset link from email:
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        print("🔐 Password recovery deep link detected!");
        // Use Get.to so user can set new password
        Get.to(NewPasswordScreen());
        return;
      }

      // Handle sign in centrally (email/password and OAuth will both trigger this)
      if (authEvent == AuthChangeEvent.signedIn && session != null) {
        try {
          // Ensure user exists in users table for first-time OAuth logins
          await insertUserIfNew(session.user);
          // fetch role and navigate
          await fetchRoleAndNavigate(session.user.id);
        } catch (e) {
          print("Error handling signedIn event: $e");
        }
        return;
      }

      // Handle sign out
      if (authEvent == AuthChangeEvent.signedOut) {
        print("User signed out via listener");
        user.value = null;
        // Navigate to login screen if needed
        Get.offAll(() => LoginScreen());
      }
    });
  }

  
  // 👤 SIGN UP
  
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
        'profile_image':
        'https://api.dicebear.com/6.x/pixel-art/png?seed=${emailController.text.trim()}',
      });

      // Generate Care ID for new user
      final careLinkController = Get.find<CareLinkController>();
      await careLinkController.generateAndAssignCareId(response.user!.id);

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Get.offAll(() => RoleSelectionView());
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  
  // 🔐 LOGIN (EMAIL + PASSWORD)
  
  Future<void> logIn() async {
    isLoading.value = true;
    wrongPassword.value = false;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        wrongPassword.value = true;
        throw 'Invalid email or password.';
      }

      wrongPassword.value = false;
      emailController.clear();
      passwordController.clear();

      // Navigation and user insertion handled by the central auth listener (onAuthStateChange)
    } catch (e) {
      final message = e.toString();

      if (message.contains("Invalid login credentials") ||
          message.contains("Invalid email or password")) {
        wrongPassword.value = true;
      }

      Get.snackbar('Error', message.replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  
  // 🤳 GOOGLE LOGIN
  
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // DO NOT create a new onAuthStateChange listener here.
      // The central listener (initAuthListener) will handle signedIn events,
      // insert the user if new, and navigate appropriately.
    } catch (e) {
      print("Google Login Error: $e");
      Get.snackbar("Login Error", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  
  // 📘 FACEBOOK LOGIN
  
  Future<void> signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Central listener will pick up the signedIn event and handle DB + navigation.
    } catch (e) {
      Get.snackbar("Login Error", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  
  // 🔧 Insert user in DB if it's first login via OAuth
  
  Future<void> insertUserIfNew(User user) async {
    final existing = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? "Anonymous",
        'profile_image': user.userMetadata?['avatar_url'] ??
            'https://api.dicebear.com/6.x/pixel-art/png?seed=${user.email}',
      });

      final careLinkController = Get.find<CareLinkController>();
      await careLinkController.generateAndAssignCareId(user.id);
    }
  }

  
  // 🚪 LOGOUT (FIXED & PROPER)
  
  Future<void> logOut() async {
    try {
      isLoading.value = true;

      // 1. Supabase Logout
      await supabase.auth.signOut();

      // 2. DELETE ALL USER-SPECIFIC CONTROLLERS
      // Delete Dashboard + CareLink
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
      }
      if (Get.isRegistered<CareLinkController>()) {
        Get.delete<CareLinkController>(force: true);
      }

      // If using caregiver dashboard
      if (Get.isRegistered<CaregiverDashboardController>()) {
        Get.delete<CaregiverDashboardController>(force: true);
      }

      // If using care receiver dashboard
      if (Get.isRegistered<ReceiverDashboardController>()) {
        Get.delete<ReceiverDashboardController>(force: true);
      }

      // 3. Clear AuthController user data
      user.value = null;

      // 4. Navigate to Login
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔄 RESET PASSWORD (EMAIL)
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: "io.supabase.flutter://reset-callback/",
      );

      Get.snackbar("Success", "A reset link has been sent to your email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  ///setting new password
  Future<void> setNewPassword(String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw "Session expired. Please try again.";
      }

      Get.snackbar("Success", "Password updated successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      await supabase.auth.signOut();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates user role (caregiver / receiver) and redirects them
  Future<void> updateUserRoleAndNavigate(String role) async {
    isLoading.value = true;

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw "User not found. Please log in again.";
      }

      // Update role in database
      await supabase.from('users').update({'role': role}).eq('id', userId);

      // After updating, fetch full user data + navigate
      await fetchRoleAndNavigate(userId);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  
  // 🎯 FETCH USER ROLE + REDIRECT
  
  Future<void> fetchRoleAndNavigate(String userId) async {
    try {
      // Fetch fresh user row from DB
      final response =
      await supabase.from('users').select().eq('id', userId).single();

      // Set user model (fresh)
      user.value = UserModel.fromJson(response);

      // Delete any user-specific controllers to avoid stale state
      // (they will be recreated by bindings or when needed)
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
      }
      if (Get.isRegistered<CareLinkController>()) {
        Get.delete<CareLinkController>(force: true);
      }
      if (Get.isRegistered<CaregiverDashboardController>()) {
        Get.delete<CaregiverDashboardController>(force: true);
      }
      if (Get.isRegistered<ReceiverDashboardController>()) {
        Get.delete<ReceiverDashboardController>(force: true);
      }

      final role = user.value?.role;

      if (role == null) {
        Get.offAll(() => RoleSelectionView());
        return;
      }

      if (role == "caregiver") {
        final links = await supabase
            .from('care_links')
            .select('receiver_id')
            .eq('caregiver_id', userId);

        if (links.isEmpty) {
          Get.offAll(() => CareLinkScreen());
        } else {
          // ensure NavController / bindings are ready (InitialBinding should lazyPut them)
          Get.offAll(() => MainScaffold());
        }
      } else if (role == "receiver") {
        final careId = user.value?.careId;

        final links = await supabase
            .from('care_links')
            .select('caregiver_id')
            .eq('receiver_id', userId);

        if (links.isEmpty) {
          Get.offAll(() => CareIdDisplayScreen(careId: careId!));
        } else {
          Get.offAll(() => MainScaffold());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load user data.',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAll(() => LoginScreen());
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    final userId = user.value?.id;
    if (userId == null) return false;

    final response = await supabase.from("users").update(data).eq("id", userId);

    return response.error == null;
  }

}
