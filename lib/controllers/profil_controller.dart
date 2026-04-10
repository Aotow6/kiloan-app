import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class ProfilController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final teleponCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  void loadCurrentUserData() {
    final user = userC.currentUser.value;
    if (user != null) {
      namaCtrl.text = user.namaLengkap;
      emailCtrl.text = supabase.auth.currentUser?.email ?? "";
      teleponCtrl.text = user.noHp ?? "";
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> simpanProfil() async {
    if (namaCtrl.text.isEmpty || teleponCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      Get.snackbar("Error", "Nama, Email, dan Telepon wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String inputEmail = emailCtrl.text.trim();
    if (!GetUtils.isEmail(inputEmail)) {
      Get.snackbar("Error", "Format email tidak valid!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final currentUser = supabase.auth.currentUser;
      final currentEmail = currentUser?.email ?? "";

      if (inputEmail != currentEmail) {
        await supabase.auth.updateUser(
          UserAttributes(email: inputEmail),
        );
      }

      final userId = currentUser?.id;
      if (userId != null) {
        await supabase.from('users').update({
          'nama_lengkap': namaCtrl.text.trim(),
          'no_hp': teleponCtrl.text.trim(),
        }).eq('id', userId);
      }

      if (passwordCtrl.text.isNotEmpty) {
        if (passwordCtrl.text.length < 6) {
           throw const AuthException("Password minimal 6 karakter");
        }
        await supabase.auth.updateUser(
          UserAttributes(password: passwordCtrl.text),
        );
      }

      Get.back();
      Get.snackbar("Sukses", "Profil berhasil diperbarui", backgroundColor: Colors.green, colorText: Colors.white);

    } on AuthException catch (e) {
      Get.snackbar("Gagal (Auth)", e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      passwordCtrl.clear();
    }
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