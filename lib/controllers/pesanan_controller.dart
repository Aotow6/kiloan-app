import 'package:get/get.dart';

class PesananController extends GetxController {

  var selectedTab = 0.obs;

  final List<String> tabs = [
    "Diproses",
    "Selesai",
    "Diambil",
    "Batal"
  ];

  void changeTab(int index) {
    selectedTab.value = index;
  }
}