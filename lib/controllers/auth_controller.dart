import 'dart:async';
import 'dart:io';
import 'package:elder_care/presentation/screens/auth/login_screen.dart';
import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../presentation/caregiver_dashboard.dart';
import '../presentation/screens/care_id_display_screen.dart';
import '../presentation/screens/care_link_screen.dart';
import '../presentation/screens/carereciever_dashboard.dart';
import '../presentation/screens/auth/new_password_screen.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import 'care_link_controller.dart';

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
    initAuthListener();   // This handles password reset deep links
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

  // -----------------------------
  // 🔥 AUTH STATE LISTENER
  // -----------------------------
  void initAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final authEvent = event.event;
      final session = event.session;

      print("🔥 Auth Event: $authEvent");

      // When user clicks reset link from email:
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        print("🔐 Password recovery deep link detected!");
        Get.to(() => NewPasswordScreen());
      }
    });
  }

  // -----------------------------
  // 👤 SIGN UP
  // -----------------------------
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

  // -----------------------------
  // 🔐 LOGIN (EMAIL + PASSWORD)
  // -----------------------------
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

      await fetchRoleAndNavigate(response.user!.id);
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

  // -----------------------------
  // 🤳 GOOGLE LOGIN
  // -----------------------------
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
          await insertUserIfNew(session.user);
          await fetchRoleAndNavigate(session.user.id);
        }
      });
    } catch (e) {
      print("Google Login Error: $e");
    }
  }

  // -----------------------------
  // 📘 FACEBOOK LOGIN
  // -----------------------------
  Future<void> signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      supabase.auth.onAuthStateChange.listen((event) async {
        final session = event.session;

        if (session != null) {
          await insertUserIfNew(session.user);
          await fetchRoleAndNavigate(session.user.id);
        }
      });
    } catch (e) {
      Get.snackbar("Login Error", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }


  // -----------------------------
  // 🔧 Insert user in DB if it's first login via OAuth
  // -----------------------------
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

  // -----------------------------
  // 🚪 LOGOUT
  // -----------------------------
  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await supabase.auth.signOut();
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------
  // 🔄 RESET PASSWORD (EMAIL)
  // -----------------------------
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

  // -----------------------------
  // 🆕 SET NEW PASSWORD (after clicking email link)
  // -----------------------------
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

  // -----------------------------
  // 🎯 FETCH USER ROLE + REDIRECT
  // -----------------------------
  Future<void> fetchRoleAndNavigate(String userId) async {
    try {
      final response =
      await supabase.from('users').select().eq('id', userId).single();

      user.value = UserModel.fromJson(response);
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
          Get.offAll(() => CareReceiverDashboard());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load user data.',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAll(() => LoginScreen());
    }
  }
}
