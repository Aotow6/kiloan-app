import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaporanController extends GetxController {

  var selectedPeriode = "".obs;
  var listPeriode = <String>[].obs;

  final List<String> _namaBulan = [
    "", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  @override
  void onInit() {
    super.onInit();
    _generatePeriodeDinamis();
  }

  void _generatePeriodeDinamis() {
    DateTime now = DateTime.now();
    List<String> tempPeriode = [];

    for (int i = 0; i < 12; i++) {
      int month = now.month - i;
      int year = now.year;

      if (month <= 0) {
        month += 12;
        year -= 1;
      }

      tempPeriode.add("${_namaBulan[month]} $year");
    }

    listPeriode.value = tempPeriode;
    selectedPeriode.value = tempPeriode.first; 

  }

  void ubahPeriode(String bulan) {
    selectedPeriode.value = bulan;
    Get.back(); 

  }

  void prosesLaporan() {
    Get.snackbar(
      "Memproses Data", 
      "Menarik data laporan untuk ${selectedPeriode.value}...",
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}