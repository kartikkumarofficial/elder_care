import 'dart:math';
import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CareLinkController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final careIdController = TextEditingController();
  final isLoading = false.obs;

  Future<String> generateAndAssignCareId(String userId) async {
    String careId = '';
    bool isUnique = false;

    while (!isUnique) {
      careId = (100000 + Random().nextInt(900000)).toString();
      final response = await supabase
          .from('users')
          .select('id')
          .eq('care_id', careId)
          .limit(1);

      if ((response as List).isEmpty) {
        isUnique = true;
      }
    }

    await supabase
        .from('users')
        .update({'care_id': careId})
        .eq('id', userId);

    return careId;
  }

  Future<void> linkToReceiver() async {
    final careId = careIdController.text.trim();
    if (careId.isEmpty) {
      Get.snackbar('Error', 'Please enter a Care ID.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final caregiverId = supabase.auth.currentUser?.id;
      if (caregiverId == null) throw "Authentication error. Please log in again.";

      // Step 1: Find the Care Receiver by their care_id
      // SUGGESTION: Renamed linked_care_id to linked_user_id for clarity
      final receiverResponse = await supabase
          .from('users')
          .select('id, linked_user_id')
          .eq('care_id', careId)
          .single();

      final receiverId = receiverResponse['id'];

      // SUGGESTION: Renamed linked_care_id to linked_user_id
      if (receiverResponse['linked_user_id'] != null) {
        throw "This person is already linked to another caregiver.";
      }

      // Step 2: Establish the two-way link
      // SUGGESTION: Renamed linked_care_id to linked_user_id
      await supabase
          .from('users')
          .update({'linked_user_id': receiverId})
          .eq('id', caregiverId);

      // SUGGESTION: Renamed linked_care_id to linked_user_id
      await supabase
          .from('users')
          .update({'linked_user_id': caregiverId})
          .eq('id', receiverId);

      careIdController.clear();
      Get.snackbar('Success!', 'You are now linked.', backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAll(() => MainScaffold());

    } catch (e) {
      String errorMessage = e.toString().contains('PGRST116')
          ? "Invalid Care ID. Please check and try again."
          : e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    careIdController.dispose();
    super.onClose();
  }
}
