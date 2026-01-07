import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> getOrCreateChat({
    required String userA,
    required String userB,
  }) async {
    // 1️⃣ Find existing chat
    final existingChats = await _client
        .from('chat_members')
        .select('chat_id')
        .eq('user_id', userA);

    for (final row in existingChats) {
      final members = await _client
          .from('chat_members')
          .select('user_id')
          .eq('chat_id', row['chat_id']);

      final ids = members.map((e) => e['user_id']).toList();
      if (ids.contains(userB)) {
        return row['chat_id'];
      }
    }

    // 2️⃣ Create new chat
    final chat = await _client
        .from('chats')
        .insert({})
        .select()
        .single();

    final chatId = chat['id'];

    // 3️⃣ Insert members
    await _client.from('chat_members').insert([
      {'chat_id': chatId, 'user_id': userA},
      {'chat_id': chatId, 'user_id': userB},
    ]);

    return chatId;
  }
}
