import 'package:get/get.dart';

class NavController extends GetxController {
  var selectedIndex = 0.obs;


  var linkedReceiverId = "".obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
