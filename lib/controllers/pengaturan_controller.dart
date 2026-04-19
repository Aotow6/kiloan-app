import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengaturanController extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;

  void konfirmasiLogout() {
    Get.defaultDialog(
      title: "Keluar Akun",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Color(0xFF102A43),
      ),
      middleText: "Apakah Anda yakin ingin keluar dari aplikasi?",
      textCancel: "Batal",
      textConfirm: "Keluar",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFB71C1C),
      cancelTextColor: const Color(0xFF102A43),
      onConfirm: () {
        Get.back();
        prosesLogout();
      },
    );
  }

  Future<void> prosesLogout() async {
    try {
      isLoading.value = true;

      await supabase.auth.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal keluar akun: ",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}