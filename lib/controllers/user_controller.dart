import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  var currentUser = Rxn<AppUser>();

  Future<void> fetchCurrentUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    currentUser.value = AppUser.fromJson(response);
  }

  Future<void> updateRole(String role) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('users').update({'role': role}).eq('id', userId);
    await fetchCurrentUser(); // refresh
  }
}
