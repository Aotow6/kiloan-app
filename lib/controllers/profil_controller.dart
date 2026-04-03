import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilController extends GetxController {

  final namaCtrl = TextEditingController(text: "Satria"); 
  final emailCtrl = TextEditingController(text: "satria@gmail.com");
  final teleponCtrl = TextEditingController(text: "083141535335");
  final passwordCtrl = TextEditingController();

  var isPasswordHidden = true.obs;

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void simpanProfil() {
    if (namaCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Gagal", "Nama tidak boleh kosong!", 
        backgroundColor: Colors.red.shade600, colorText: Colors.white,
      );
      return;
    }

    if (teleponCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Gagal", "Nomor Telepon wajib diisi!", 
        backgroundColor: Colors.red.shade600, colorText: Colors.white,
      );
      return;
    }

    Get.back();
    Get.snackbar(
      "Sukses", "Profil berhasil diperbarui!", 
      backgroundColor: Colors.green, colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    emailCtrl.dispose();
    teleponCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}