import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PengaturanController extends GetxController {

  void konfirmasiLogout() {
    Get.defaultDialog(
      title: "Keluar Akun",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "Apakah Anda yakin ingin keluar dari aplikasi?",
      textCancel: "Batal",
      textConfirm: "Keluar",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFB71C1C), 

      cancelTextColor: const Color(0xFF102A43),
      onConfirm: () {
        Get.back(); 

        Get.snackbar(
          "Logout Berhasil", 
          "Anda telah keluar dari akun.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }
}