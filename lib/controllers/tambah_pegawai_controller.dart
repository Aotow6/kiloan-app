import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'kelola_pegawai_controller.dart';

class TambahPegawaiController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();
  
  final namaCtrl = TextEditingController();
  final teleponCtrl = TextEditingController();
  final emailCtrl = TextEditingController(); 
  final passwordCtrl = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> simpanData() async {
    if (namaCtrl.text.isEmpty || teleponCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar("Error", "Semua kolom wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (passwordCtrl.text.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (userC.outletId == null) {
      Get.snackbar("Error", "Outlet ID tidak ditemukan", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final AuthResponse res = await supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );

      final User? user = res.user;

      if (user != null) {
        await supabase.from('users').insert({
          'id': user.id,
          'outlet_id': userC.outletId,
          'nama_lengkap': namaCtrl.text.trim(),
          'role': 'Kasir',
          'no_hp': teleponCtrl.text.trim(),
          'status_aktif': true,
        });

        if (Get.isRegistered<KelolaPegawaiController>()) {
          Get.find<KelolaPegawaiController>().fetchPegawai();
        }

        Get.back();
        Get.snackbar("Sukses", "Akun kasir berhasil dibuat", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } on AuthException catch (e) {
      Get.snackbar("Gagal", e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    teleponCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}