import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/user_controller.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  var isPemilik = true.obs;
  var isLoading = false.obs;

  // --- CONTROLLER INPUT ---
  final emailLoginCtrl = TextEditingController();
  final passwordLoginCtrl = TextEditingController();
  final resetEmailCtrl = TextEditingController();

  final namaLengkapCtrl = TextEditingController();
  final namaLaundryCtrl = TextEditingController();
  final emailRegisCtrl = TextEditingController();
  final passwordRegisCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // --- STATE PESAN ERROR REGISTRASI ---
  var errNamaLengkap = RxnString();
  var errNamaLaundry = RxnString();
  var errEmailRegis = RxnString();
  var errPasswordRegis = RxnString();
  var errConfirmPassword = RxnString();

  // --- STATE PESAN ERROR LOGIN ---
  var errEmailLogin = RxnString();
  var errPasswordLogin = RxnString();

  bool hasEmoji(String text) {
    final RegExp emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true);
    return emojiRegex.hasMatch(text);
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void clearErrors() {
    errNamaLengkap.value = null;
    errNamaLaundry.value = null;
    errEmailRegis.value = null;
    errPasswordRegis.value = null;
    errConfirmPassword.value = null;
    errEmailLogin.value = null; 
    errPasswordLogin.value = null; 
  }

  // ================= LOGIN =================
   Future<void> login() async {
    clearErrors();
    bool isValid = true;
    String email = emailLoginCtrl.text.trim();
    String pass = passwordLoginCtrl.text.trim();

    if (email.isEmpty) {
      errEmailLogin.value = "Email wajib diisi";
      isValid = false;
    } else if (!isValidEmail(email)) {
      errEmailLogin.value = "Format email tidak valid";
      isValid = false;
    }

    if (pass.isEmpty) {
      errPasswordLogin.value = "Kata sandi wajib diisi";
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      if (response.user != null) {

        final userData = await supabase
            .from('users')
            .select('role, status_aktif')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userData == null) {
          await supabase.auth.signOut();
          throw Exception("Data tidak valid");
        }

        bool isAktif = userData['status_aktif'] ?? false;
        String role = userData['role']?.toString().toLowerCase().trim() ?? '';

        bool salahKamarOwner = isPemilik.value && role != 'owner';
        bool salahKamarKasir = !isPemilik.value && role == 'owner';

        if (salahKamarOwner || salahKamarKasir) {
          await supabase.auth.signOut(); 
          throw Exception("Akses ditolak karena salah kamar"); 
        }

        if (!isAktif) {
          await supabase.auth.signOut(); 
          Get.snackbar("Akses Ditolak", "Akun Anda telah dinonaktifkan oleh Pemilik.", 
              backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
          return; 
        }

        final userC = Get.find<UserController>();
        await userC.getUserProfile();

        if (userC.outletId != null) {

          Get.snackbar("Sukses", "Selamat datang kembali!", 
              backgroundColor: Colors.green, colorText: Colors.white);

          Get.offAllNamed('/home');
        } else {
          await supabase.auth.signOut();
          throw Exception("Outlet tidak ditemukan");
        }
      } 
    } catch (e) {
      errPasswordLogin.value = "";
      errEmailLogin.value = "";
      Get.snackbar("Login Gagal", "Email, Kata Sandi salah, atau Akun tidak ditemukan.", 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  // ================= REGISTER =================
  Future<void> register() async {
    clearErrors(); 
    bool isValid = true;

    String nama = namaLengkapCtrl.text.trim();
    String laundry = namaLaundryCtrl.text.trim();
    String email = emailRegisCtrl.text.trim();
    String pass = passwordRegisCtrl.text.trim();
    String confirmPass = confirmPasswordCtrl.text.trim();

    if (nama.isEmpty) {
      errNamaLengkap.value = "Nama lengkap wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNamaLengkap.value = "Nama minimal 3 karakter";
      isValid = false;
    } else if (nama.length > 50) {
      errNamaLengkap.value = "Nama maksimal 50 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) {
      errNamaLengkap.value = "Nama tidak boleh menggunakan karakter aneh/emoji";
      isValid = false;
    }

    if (laundry.isEmpty) {
      errNamaLaundry.value = "Nama laundry wajib diisi";
      isValid = false;
    } else if (laundry.length < 3) {
      errNamaLaundry.value = "Nama laundry minimal 3 karakter";
      isValid = false;
    } else if (laundry.length > 30) {
      errNamaLaundry.value = "Nama laundry maksimal 30 karakter";
      isValid = false;
    } else if (hasEmoji(laundry)) {
      errNamaLaundry.value = "Nama laundry tidak boleh menggunakan emoji";
      isValid = false;
    }

    if (email.isEmpty) {
      errEmailRegis.value = "Email wajib diisi";
      isValid = false;
    } else if (!isValidEmail(email)) {
      errEmailRegis.value = "Format email tidak valid (contoh: budi@gmail.com)";
      isValid = false;
    }

    if (pass.isEmpty) {
      errPasswordRegis.value = "Password wajib diisi";
      isValid = false;
    } else if (pass.length < 6) {
      errPasswordRegis.value = "Password minimal 6 karakter";
      isValid = false;
    }

    if (confirmPass.isEmpty) {
      errConfirmPassword.value = "Konfirmasi password wajib diisi";
      isValid = false;
    } else if (pass != confirmPass) {
      errConfirmPassword.value = "Konfirmasi password tidak cocok";
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;

      final authRes = await supabase.auth.signUp(
        email: email,
        password: pass,
      );

      if (authRes.user != null) {
        final outletRes = await supabase.from('outlets').insert({
          'nama_outlet': laundry,
        }).select().single();

        await supabase.from('users').insert({
          'id': authRes.user!.id,
          'outlet_id': outletRes['id'],
          'nama_lengkap': nama,
          'role': 'owner',
          'status_aktif': true,
        });

        final userC = Get.find<UserController>();
        await userC.getUserProfile();

        Get.offAllNamed('/home');
        Get.snackbar("Sukses", "Toko & Akun Berhasil Dibuat!", 
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Registrasi Gagal", "Email sudah terdaftar atau server sibuk.",
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint("Detail Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= RESET PASSWORD =================
  Future<void> kirimResetPassword() async {
    if (resetEmailCtrl.text.isEmpty) {
      Get.snackbar("Error", "Masukkan email kamu dulu", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await supabase.auth.resetPasswordForEmail(resetEmailCtrl.text.trim());
      Get.back();
      Get.snackbar("Berhasil", "Cek email kamu untuk reset password",
        backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar("Gagal", "Email tidak ditemukan atau error", backgroundColor: Colors.red, colorText: Colors.white);
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