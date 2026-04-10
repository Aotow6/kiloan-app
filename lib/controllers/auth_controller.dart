import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/user_controller.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  var isPemilik = true.obs;
  var isLoading = false.obs;

  final emailLoginCtrl = TextEditingController();
  final passwordLoginCtrl = TextEditingController();
  final resetEmailCtrl = TextEditingController();

  final namaLengkapCtrl = TextEditingController();
  final namaLaundryCtrl = TextEditingController();
  final emailRegisCtrl = TextEditingController();
  final passwordRegisCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  Future<void> login() async {
    // 1. VALIDASI KETAT: trim() digunakan untuk hapus spasi kosong
    if (emailLoginCtrl.text.trim().isEmpty || passwordLoginCtrl.text.trim().isEmpty) {
      Get.snackbar("Peringatan", "Email dan Password tidak boleh kosong!", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return; 
    }

    try {
      isLoading.value = true;
      
      final response = await supabase.auth.signInWithPassword(
        email: emailLoginCtrl.text.trim(),
        password: passwordLoginCtrl.text.trim(),
      );

      // 2. PASTIKAN USER TIDAK NULL
      if (response.user != null) {
        // Ambil profil dulu sebelum pindah halaman
        final userC = Get.find<UserController>();
        await userC.getUserProfile();
        
        // Pastikan outlet_id ada (User terdaftar di tabel public.users)
        if (userC.outletId != null) {
          Get.offAllNamed('/home');
        } else {
          await supabase.auth.signOut();
          Get.snackbar("Error", "Data profil user tidak ditemukan");
        }
      } 
    } catch (e) {
      Get.snackbar("Login Gagal", "Email atau Password salah");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    // 1. VALIDASI INPUT LENGKAP
    if (emailRegisCtrl.text.trim().isEmpty || 
        passwordRegisCtrl.text.trim().isEmpty ||
        namaLaundryCtrl.text.trim().isEmpty || 
        namaLengkapCtrl.text.trim().isEmpty) {
      Get.snackbar("Gagal", "Semua kolom wajib diisi!", 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (passwordRegisCtrl.text != confirmPasswordCtrl.text) {
      Get.snackbar("Gagal", "Konfirmasi password tidak cocok", 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 2. SignUp ke Auth Supabase
      final authRes = await supabase.auth.signUp(
        email: emailRegisCtrl.text.trim(),
        password: passwordRegisCtrl.text.trim(),
      );

      if (authRes.user != null) {
        // 3. Simpan Data ke Tabel outlets
        final outletRes = await supabase.from('outlets').insert({
          'nama_outlet': namaLaundryCtrl.text.trim(),
        }).select().single();

        // 4. Simpan Data ke Tabel users (Role: Owner)
        await supabase.from('users').insert({
          'id': authRes.user!.id,
          'outlet_id': outletRes['id'],
          'nama_lengkap': namaLengkapCtrl.text.trim(),
          'role': 'owner',
          'status_aktif': true,
        });

        // 5. Inisialisasi profil user di UserController
        final userC = Get.find<UserController>();
        await userC.getUserProfile();

        Get.offAllNamed('/home');
        Get.snackbar("Sukses", "Toko & Akun Berhasil Dibuat!", 
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Registrasi Gagal", "Email sudah terdaftar atau server sibuk.");
      print("Detail Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> kirimResetPassword() async {
  if (resetEmailCtrl.text.isEmpty) {
    Get.snackbar(
      "Error",
      "Masukkan email kamu dulu",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  try {
    isLoading.value = true;

    await supabase.auth.resetPasswordForEmail(
      resetEmailCtrl.text.trim(),
    );

    Get.back();

    Get.snackbar(
      "Berhasil",
      "Cek email kamu untuk reset password",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  } catch (e) {
    Get.snackbar(
      "Gagal",
      "Email tidak ditemukan atau error",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
    resetEmailCtrl.clear();
  }
}

  @override
  void onClose() {
    emailLoginCtrl.dispose();
    passwordLoginCtrl.dispose();
    resetEmailCtrl.dispose();
    namaLengkapCtrl.dispose();
    namaLaundryCtrl.dispose();
    emailRegisCtrl.dispose();
    passwordRegisCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}