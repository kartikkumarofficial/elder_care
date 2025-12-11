import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiverService {
  static Future<String?> getLinkedReceiverId() async {
    final supabase = Supabase.instance.client;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final row = await supabase
          .from("care_connections")
          .select("receiver_id")
          .eq("caregiver_id", uid)
          .maybeSingle();

      if (row == null) return null;

      return row["receiver_id"]?.toString();
    } catch (e) {
      print("getLinkedReceiverId ERROR: $e");
      return null;
    }
  }
}
