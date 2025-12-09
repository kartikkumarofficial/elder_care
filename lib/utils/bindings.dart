import 'package:elder_care/controllers/care_link_controller.dart';
import 'package:elder_care/controllers/caregiver_dashboard_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/nav_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(NavController());
    Get.put(CareLinkController(),permanent: true);
    Get.put(() => CaregiverDashboardController(),permanent: true);
    Get.lazyPut(() => DashboardController());

  }
}
