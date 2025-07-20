import 'package:elder_care/presentation/screens/dashboard_screen.dart';
import 'package:elder_care/presentation/screens/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CareLinkScreen extends StatelessWidget {
  final String userId;
  final SupabaseClient client = Supabase.instance.client;

  CareLinkScreen({required this.userId});

  final TextEditingController _careIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter Care Receiver ID", style: TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 16),
            TextField(
              controller: _careIdController,
              decoration: InputDecoration(
                hintText: "Care Receiver UUID",
                fillColor: const Color(0xFF4A4E6C),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final careId = _careIdController.text;
                final match = await client.from('users').select().eq('id', careId).eq('role', 'care_receiver');
                if (match.isNotEmpty) {
                  await client.from('users').update({'care_id': careId}).eq('id', userId);
                  Get.offAll(() => MainScaffold());
                } else {
                  Get.snackbar("Error", "Invalid care receiver ID");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4A4E6C)),
              child: Text("Link", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
