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

  var errNama = RxnString();
  var errTelepon = RxnString();
  var errEmail = RxnString();
  var errPassword = RxnString();

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

  void clearErrors() {
    errNama.value = null;
    errTelepon.value = null;
    errEmail.value = null;
    errPassword.value = null;
  }

  bool hasEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true).hasMatch(text);
  }

  Future<void> simpanProfil() async {
    clearErrors();
    bool isValid = true;

    String nama = namaCtrl.text.trim();
    String telepon = teleponCtrl.text.trim();
    String inputEmail = emailCtrl.text.trim();
    String pass = passwordCtrl.text;

    if (nama.isEmpty) {
      errNama.value = "Nama wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Nama minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) {
      errNama.value = "Tidak boleh menggunakan emoji";
      isValid = false;
    }

    if (inputEmail.isEmpty) {
      errEmail.value = "Email wajib diisi";
      isValid = false;
    } else if (!GetUtils.isEmail(inputEmail)) {
      errEmail.value = "Format email tidak valid";
      isValid = false;
    }

    if (telepon.isEmpty) {
      errTelepon.value = "Nomor HP wajib diisi";
      isValid = false;
    } else if (!telepon.startsWith('08')) {
      errTelepon.value = "Nomor HP harus diawali '08'";
      isValid = false;
    } else if (telepon.length < 10 || telepon.length > 13) {
      errTelepon.value = "Nomor HP tidak valid (10-13 digit)";
      isValid = false;
    }

    if (pass.isNotEmpty) {
      if (pass.length < 6) {
        errPassword.value = "Password minimal 6 karakter";
        isValid = false;
      }
    }

    if (!isValid) return;

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
          'nama_lengkap': nama,
          'no_hp': telepon,
        }).eq('id', userId);
      }

      if (pass.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: pass),
        );
      }

      await userC.getUserProfile();

      Get.back();
      Get.snackbar("Sukses", "Profil berhasil diperbarui", backgroundColor: Colors.green, colorText: Colors.white);

    } on AuthException catch (e) {
      Get.snackbar("Gagal", "Email ini sudah dipakai atau password sama.", backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan data ke server", backgroundColor: Colors.red, colorText: Colors.white);
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