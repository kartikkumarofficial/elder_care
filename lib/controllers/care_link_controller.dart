import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class CareLinkController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final careIdController = TextEditingController();
  final isLoading = false.obs;


  ///generating and assigning a care id to user (during sign up)


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

    // assigning care id to care receiver
    await supabase
        .from('users')
        .update({'care_id': careId})
        .eq('id', userId);

    return careId;
  }

 ///linking , multi caregiver to care receiver arch

  Future<void> linkToReceiver() async {
    final careIdInput = careIdController.text.trim();

    if (careIdInput.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a Care ID.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final caregiverId = supabase.auth.currentUser?.id;
      if (caregiverId == null) throw "Authentication error. Please log in again.";

      // Find receiver using care ID
      final receiverResponse = await supabase
          .from('users')
          .select('id')
          .eq('care_id', careIdInput)
          .maybeSingle();

      if (receiverResponse == null) {
        throw "Invalid Care ID. No such care receiver found.";
      }

      final receiverId = receiverResponse['id'];

     //checking duplicate entries
      final existing = await supabase
          .from('care_links')
          .select()
          .eq('caregiver_id', caregiverId)
          .eq('receiver_id', receiverId)
          .maybeSingle();

      if (existing != null) {
        throw "You are already linked with this person.";
      }

   //inserting into care_links table form multi care giver arch
      await supabase.from('care_links').insert({
        'caregiver_id': caregiverId,
        'receiver_id': receiverId,
      });

      careIdController.clear();

      Get.snackbar(
        'Success!',
        'You are now connected.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => MainScaffold());

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

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
