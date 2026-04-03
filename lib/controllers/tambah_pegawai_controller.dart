import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TambahPegawaiController extends GetxController {
  final namaCtrl = TextEditingController();
  final teleponCtrl = TextEditingController();
  final usernameCtrl = TextEditingController(); 

  final passwordCtrl = TextEditingController();

  var isPasswordHidden = true.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;

  void simpanData() {
    if (namaCtrl.text.isEmpty || usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar("Error", "Semua kolom wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.back(); 

    Get.snackbar("Berhasil", "Pegawai baru telah ditambahkan", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    teleponCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}