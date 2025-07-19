import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(),permanent: true);
    Get.put(NavController());


  }
}
