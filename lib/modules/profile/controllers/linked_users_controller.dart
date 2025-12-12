import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class LinkedUsersController extends GetxController {
  final AuthController auth = Get.find<AuthController>();
  final SupabaseClient supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxList<UserModel> linkedUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLinkedUsers();
  }

  // ----------------------------------------------------------
  // SHOW ADD CARE RECEIVER DIALOG
  // ----------------------------------------------------------
  void showAddDialog() {
    final TextEditingController careIdController = TextEditingController();
    final RxString errorText = "".obs;

    final h = Get.height;
    final w = Get.width;

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: w * 0.85,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.06,
              vertical: h * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.06),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Text(
                  "Add Care Receiver",
                  style: GoogleFonts.nunito(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: h * 0.015),

                Text(
                  "Enter the 6-digit Care ID of the person you want to link.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: w * 0.039,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: h * 0.028),

                /// Text field
                TextField(
                  controller: careIdController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: "Care ID",
                    counterText: "",
                    prefixIcon: Icon(Icons.person_search, color: Colors.teal.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(w * 0.05),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(w * 0.05),
                      borderSide: BorderSide(color: Colors.teal.shade300, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length < 6) {
                      errorText.value = "Care ID must be exactly 6 digits.";
                    } else {
                      errorText.value = "";
                    }
                  },
                ),

                SizedBox(height: h * 0.005),

                /// ONLY this part is reactive
                Obx(() => errorText.value.isNotEmpty
                    ? Text(
                  errorText.value,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: w * 0.035,
                  ),
                )
                    : SizedBox()),

                SizedBox(height: h * 0.03),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.nunito(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        final enteredId = careIdController.text.trim();

                        // Validation
                        if (enteredId.length != 6) {
                          errorText.value = "Care ID must be 6 digits.";
                          return;
                        }

                        final exists = linkedUsers.any((u) => u.careId == enteredId);
                        if (exists) {
                          errorText.value = "This Care ID is already linked.";
                          return;
                        }

                        addLinkedUser(enteredId);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7AB7A7),
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.09,
                          vertical: h * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        "Add",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.35),
    );
  }




  // ----------------------------------------------------------
  // ADD LINKED USER BASED ON CARE ID
  // ----------------------------------------------------------
  Future<void> addLinkedUser(String careId) async {
    try {
      isLoading.value = true;

      final currentUser = auth.user.value;
      if (currentUser == null) return;

      // Check if user exists by care_id
      final userRow = await supabase
          .from('users')
          .select()
          .eq('care_id', careId)
          .maybeSingle();

      if (userRow == null) {
        Get.snackbar("Not Found", "No user found with this Care ID.");
        return;
      }

      final receiver = UserModel.fromJson(userRow);

      // Prevent linking yourself
      if (receiver.id == currentUser.id) {
        Get.snackbar("Error", "You cannot link yourself.");
        return;
      }

      // Insert into care_links
      await supabase.from('care_links').insert({
        "caregiver_id": currentUser.id,
        "receiver_id": receiver.id,
      });

      Get.snackbar("Success", "User linked successfully.");

      await fetchLinkedUsers();

    } catch (e) {
      print("addLinkedUser error: $e");
      Get.snackbar("Error", "Could not link user.");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // FETCH LINKED USERS
  // ----------------------------------------------------------
  Future<void> fetchLinkedUsers() async {
    try {
      isLoading.value = true;
      final currentUser = auth.user.value;
      if (currentUser == null) return;

      if (currentUser.role == "caregiver") {
        final link = await supabase
            .from('care_links')
            .select('receiver_id')
            .eq('caregiver_id', currentUser.id)
            .maybeSingle();

        if (link == null || link['receiver_id'] == null) {
          linkedUsers.clear();
          return;
        }

        final receiver = await supabase
            .from('users')
            .select()
            .eq('id', link['receiver_id'])
            .single();

        linkedUsers.assignAll([UserModel.fromJson(receiver)]);
      } else {
        final linkRows = await supabase
            .from('care_links')
            .select('caregiver_id')
            .eq('receiver_id', currentUser.id);

        if (linkRows.isEmpty) {
          linkedUsers.clear();
          return;
        }

        final caregiverIds =
        linkRows.map((row) => row['caregiver_id']).toList();

        final caregivers = await supabase
            .from('users')
            .select()
            .inFilter('id', caregiverIds);

        linkedUsers.assignAll(
            caregivers.map((e) => UserModel.fromJson(e)).toList());
      }
    } catch (e) {
      print("fetchLinkedUsers error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // REMOVE LINK
  // ----------------------------------------------------------
  Future<void> removeLink(UserModel user) async {
    try {
      final currentUser = auth.user.value;
      if (currentUser == null) return;

      isLoading.value = true;

      if (currentUser.role == "caregiver") {
        await supabase
            .from('care_links')
            .delete()
            .eq('caregiver_id', currentUser.id)
            .eq('receiver_id', user.id)
            .select();
      } else {
        await supabase
            .from('care_links')
            .delete()
            .eq('receiver_id', currentUser.id)
            .eq('caregiver_id', user.id)
            .select();
      }

      await fetchLinkedUsers();
      Get.snackbar("Removed", "User unlinked successfully.");

    } catch (e) {
      print("removeLink error: $e");
      Get.snackbar("Error", "Could not remove link.");
    } finally {
      isLoading.value = false;
    }
  }
}
