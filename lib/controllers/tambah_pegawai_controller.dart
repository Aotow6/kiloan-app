import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/controllers/error_handler.dart';
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

  var isEdit = false.obs;
  var idEdit = "".obs;

  var errNama = RxnString();
  var errTelepon = RxnString();
  var errEmail = RxnString();
  var errPassword = RxnString();

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool hasEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true).hasMatch(text);
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void clearErrors() {
    errNama.value = null;
    errTelepon.value = null;
    errEmail.value = null;
    errPassword.value = null;
  }

  void clearForm() {
    isEdit.value = false;
    idEdit.value = "";
    namaCtrl.clear();
    teleponCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    clearErrors();
  }

  void setEditMode(Map<String, dynamic> data) {
    isEdit.value = true;
    idEdit.value = data['id'].toString();
    namaCtrl.text = data['nama_lengkap']?.toString() ?? "";
    teleponCtrl.text = data['no_hp']?.toString() ?? "";
    clearErrors();
  }

  Future<void> simpanData() async {
    clearErrors();
    bool isValid = true;

    String nama = namaCtrl.text.trim();
    String telepon = teleponCtrl.text.trim();
    String email = emailCtrl.text.trim();
    String password = passwordCtrl.text;

    if (nama.isEmpty) {
      errNama.value = "Nama wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) {
      errNama.value = "Tidak boleh mengandung emoji";
      isValid = false;
    }

    if (telepon.isEmpty) {
      errTelepon.value = "No HP wajib diisi";
      isValid = false;
    } else if (!telepon.startsWith('08')) {
      errTelepon.value = "No HP harus diawali '08'";
      isValid = false;
    } else if (telepon.length < 10 || telepon.length > 13) {
      errTelepon.value = "No HP tidak valid (10-13 digit)";
      isValid = false;
    }

    if (!isEdit.value) {
      if (email.isEmpty) {
        errEmail.value = "Email wajib diisi";
        isValid = false;
      } else if (!isValidEmail(email)) {
        errEmail.value = "Format email salah";
        isValid = false;
      }

      if (password.isEmpty) {
        errPassword.value = "Password wajib diisi";
        isValid = false;
      } else if (password.length < 6) {
        errPassword.value = "Minimal 6 karakter";
        isValid = false;
      }
    }

    if (!isValid) return;
    if (userC.outletId == null) return;

    try {
      isLoading.value = true;

      if (isEdit.value) {

        await supabase.from('users').update({
          'nama_lengkap': nama,
          'no_hp': telepon,
        }).eq('id', idEdit.value);

        Get.back();
        Get.snackbar("Sukses", "Data pegawai berhasil diupdate", backgroundColor: Colors.green, colorText: Colors.white);
      } else {

        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final User? user = res.user;

        if (user != null) {
          await supabase.from('users').insert({
            'id': user.id,
            'outlet_id': userC.outletId,
            'nama_lengkap': nama,
            'role': 'Kasir', 

            'no_hp': telepon,
            'status_aktif': true,
          });

          Get.back();
          Get.snackbar("Sukses", "Akun kasir berhasil dibuat", backgroundColor: Colors.green, colorText: Colors.white);
        }
      }

      if (Get.isRegistered<KelolaPegawaiController>()) {
        Get.find<KelolaPegawaiController>().fetchPegawai();
      }

    } on AuthException catch (e) {
      Get.snackbar("Gagal", e.message, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      ErrorHandler.show(e);
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