import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/screens/carelink_screen.dart';
import '../presentation/screens/carereciever_dashboard.dart';


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
