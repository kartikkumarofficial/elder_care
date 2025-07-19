
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main_scaffold.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match', colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          "name": nameController.text.trim(),
        }, //final name = Supabase.instance.client.auth.currentUser?.userMetadata?['name']; - can be accessed by this
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'username': name,
          'profile_image':
          'https://api.dicebear.com/6.x/pixel-art/svg?seed=$email',
        });
        Get.snackbar(
          'Success',
          'Signed up as ${response.user!.email}, Confirm your email via the link in your inbox',
          colorText: Colors.white,
        );
        Get.offAll(LoginScreen());
      } else {
        Get.snackbar(
          'Sign Up Failed',
          'Something went wrong. Try again.',
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        colorText: Colors.white,
        e.toString().replaceAll('Exception: ', ''),
      ); //just to make error snack bar smaller and more readable
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email and password cannot be empty',
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.snackbar(
          'Welcome',
          'Logged in as ${response.user!.email} ',
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(MainScaffold());
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid Credentials',
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception', ''),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
