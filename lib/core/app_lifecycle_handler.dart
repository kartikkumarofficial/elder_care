import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../modules/care_receiver/controllers/activity_controller.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      if (Get.isRegistered<ActivityController>()) {
        Get.find<ActivityController>().markActive();
      }
    }
  }
}
