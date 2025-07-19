import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RoleController extends GetxController {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> setRole(String userId, String role) async {
    await client.from('users').update({'role': role}).eq('id', userId);

    if (role == 'caregiver') {
      Get.offAll(() => CareLinkScreen(userId: userId));
    } else {
      Get.offAll(() => CareReceiverDashboard());
    }
  }
}
