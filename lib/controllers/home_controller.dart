import 'package:get/get.dart';

class HomeController extends GetxController {

  var activeTab = 1.obs; 

  var bottomNavIndex = 0.obs;

  void changeTab(int index) {
    activeTab.value = index;
  }

  void changeBottomNav(int index) {
    bottomNavIndex.value = index;
  }
}