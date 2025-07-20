// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ConnectReceiverController extends GetxController {
//   final SupabaseClient supabase = Supabase.instance.client;
//
//   var careReceiverEmail = ''.obs;
//   var statusMessage = ''.obs;
//
//   Future<void> connectToReceiver() async {
//     final caregiverId = supabase.auth.currentUser?.id;
//     if (caregiverId == null) {
//       statusMessage.value = 'User not logged in';
//       return;
//     }
//
//     try {
//       // Step 1: Find receiver by email
//       final receiverData = await supabase
//           .from('users')
//           .select('id')
//           .eq('email', careReceiverEmail.value)
//           .eq('role', 'receiver')
//           .maybeSingle();
//
//       if (receiverData == null) {
//         statusMessage.value = 'Receiver not found';
//         return;
//       }
//
//       final receiverId = receiverData['id'];
//
//       // Step 2: Check if already connected
//       final existing = await supabase
//           .from('care_connections')
//           .select()
//           .eq('caregiver_id', caregiverId)
//           .eq('receiver_id', receiverId);
//
//       if (existing.isNotEmpty) {
//         statusMessage.value = 'Already connected!';
//         return;
//       }
//
//       // Step 3: Insert connection
//       await supabase.from('care_connections').insert({
//         'caregiver_id': caregiverId,
//         'receiver_id': receiverId,
//       });
//
//       statusMessage.value = 'Connection successful!';
//
//     } catch (e) {
//       statusMessage.value = 'Error: $e';
//     }
//   }
// }
