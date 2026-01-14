import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/controllers/auth_controller.dart';
import 'chat_screen.dart';

class DirectChatScreen extends StatelessWidget {
  const DirectChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DirectChatResolverController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null) {
        return Center(child: Text(controller.error.value!));
      }

      return ChatScreen(
        chatId: controller.chatId!,
        partnerId: controller.partnerId!,
        partnerName: controller.partnerName!,
        partnerImage: controller.partnerImage,
      );

    });
  }
}


class DirectChatResolverController extends GetxController {
  final supabase = Supabase.instance.client;
  final auth = Get.find<AuthController>();

  final isLoading = true.obs;
  final error = RxnString();

  String? partnerName;
  String? partnerImage;
  String? chatId;
  String? partnerId;

  @override
  void onInit() {
    super.onInit();
    resolve();
  }


  Future<void> resolve() async {
    try {
      final me = auth.user.value!;
      final myId = me.id;

      // 1️⃣ Fetch care link
      final link = me.role == 'receiver'
          ? await supabase
          .from('care_links')
          .select('caregiver_id')
          .eq('receiver_id', myId)
          .maybeSingle()
          : await supabase
          .from('care_links')
          .select('receiver_id')
          .eq('caregiver_id', myId)
          .maybeSingle();

      if (link == null) {
        error.value = "No care partner linked yet.";
        return;
      }

      // 2️⃣ SET partnerId FIRST ✅
      partnerId = me.role == 'receiver'
          ? link['caregiver_id']
          : link['receiver_id'];

      // 3️⃣ Fetch partner user data ✅
      final partner = await supabase
          .from('users')
          .select('full_name, profile_image')
          .eq('id', partnerId!)
          .single();

      partnerName = partner['full_name'];
      partnerImage = partner['profile_image'];

      print('Partner ID: $partnerId');
      print('Partner Name: $partnerName');

      // 4️⃣ Find existing chat
      final existing = await supabase.rpc(
        'get_direct_chat',
        params: {
          'user_a': myId,
          'user_b': partnerId,
        },
      );

      if (existing != null && existing.isNotEmpty) {
        chatId = existing.first['chat_id'];
        return;
      }

      // 5️⃣ Create new chat
      final chat =
      await supabase.from('chats').insert({}).select().single();

      await supabase.from('chat_members').insert([
        {'chat_id': chat['id'], 'user_id': myId},
        {'chat_id': chat['id'], 'user_id': partnerId},
      ]);

      chatId = chat['id'];
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

}
