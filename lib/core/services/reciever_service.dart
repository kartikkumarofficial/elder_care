import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiverService {
  /// Returns the ID of the receiver linked to the currently logged-in caregiver.
  static Future<String?> getLinkedReceiverId() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final row = await supabase
          .from("care_links") // Corrected table name
          .select("receiver_id")
          .eq("caregiver_id", uid)
          .maybeSingle();

      return row?["receiver_id"]?.toString();
    } catch (e) {
      print("getLinkedReceiverId ERROR: $e");
      return null;
    }
  }

  /// Returns the ID of the caregiver linked to the currently logged-in receiver.
  static Future<String?> getLinkedCaregiverId() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final row = await supabase
          .from("care_links")
          .select("caregiver_id")
          .eq("receiver_id", uid)
          .maybeSingle();

      return row?["caregiver_id"]?.toString();
    } catch (e) {
      print("getLinkedCaregiverId ERROR: $e");
      return null;
    }
  }
}
