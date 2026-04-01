import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {

  var isPemilik = true.obs;

  final emailLoginCtrl = TextEditingController();
  final passwordLoginCtrl = TextEditingController();

  final namaLengkapCtrl = TextEditingController();
  final namaLaundryCtrl = TextEditingController();
  final emailRegisCtrl = TextEditingController();
  final passwordRegisCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  void login() {
    print("Email: ${emailLoginCtrl.text}");
    print("Password: ${passwordLoginCtrl.text}");

  }

  void register() {
    print("Daftar: ${namaLengkapCtrl.text} - ${namaLaundryCtrl.text}");

  }

  @override
  void onClose() {

    emailLoginCtrl.dispose();
    passwordLoginCtrl.dispose();
    namaLengkapCtrl.dispose();
    namaLaundryCtrl.dispose();
    emailRegisCtrl.dispose();
    passwordRegisCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}