import 'package:elder_care/modules/caregiver/controllers/care_link_controller.dart';
import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/care_receiver/controllers/schedule_controller.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../modules/caregiver/controllers/caregiver_dashboard_controller.dart';
import '../../modules/dashboard/controllers/nav_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(NavController());
    Get.put(CareLinkController(),permanent: true);
    Get.put(() => CaregiverDashboardController(),permanent: true);
    Get.lazyPut(() => DashboardController());
    Get.lazyPut<ScheduleController>(() => ScheduleController(), fenix: true);


  }
}
