import 'package:elder_care/modules/care_receiver/controllers/activity_controller.dart';
import 'package:elder_care/modules/caregiver/controllers/care_link_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/care_receiver/controllers/schedule_controller.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../modules/caregiver/controllers/caregiver_dashboard_controller.dart';
import '../../modules/dashboard/controllers/nav_controller.dart';
import '../../modules/tasks/controllers/task_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint("[InitialBinding] start");

    Get.put(AuthController(), permanent: true);
    debugPrint("[InitialBinding] AuthController registered");

    Get.put(NavController());
    debugPrint("[InitialBinding] NavController registered");

    Get.put(CareLinkController(), permanent: true);
    debugPrint("[InitialBinding] CareLinkController registered");

    Get.lazyPut(() => DashboardController());
    debugPrint("[InitialBinding] DashboardController registered");

    Get.lazyPut<ScheduleController>(() => ScheduleController(), fenix: true);
    debugPrint("[InitialBinding] ScheduleController registered");

    Get.put(TaskController(), permanent: true);
    debugPrint("[InitialBinding] TaskController registered");
    Get.put(ActivityController(), permanent: true);

    debugPrint("[InitialBinding] end");
  }
}
