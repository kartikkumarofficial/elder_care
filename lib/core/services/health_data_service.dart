// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class HealthDataService {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   /// Fetches the single latest health vital for a specific user and type.
//   Future<Map<String, dynamic>?> getLatestVital(String vitalType, String userId) async {
//     if (userId.isEmpty) return null;
//
//     try {
//       // .maybeSingle() is used to safely return null if no record is found,
//       // preventing crashes.
//       final response = await _supabase
//           .from('health_vitals')
//           .select()
//           .eq('user_id', userId)
//           .eq('type', vitalType)
//           .order('timestamp', ascending: false) // Order by most recent
//           .limit(1) // Get only one
//           .maybeSingle(); // Use maybeSingle() to avoid errors
//
//       return response;
//     } catch (e) {
//       print('[HealthDataService] Error fetching latest vital for $vitalType: $e');
//       return null;
//     }
//   }
// }
