import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/controllers/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import 'user_controller.dart';
import '../models/outlet_model.dart';

class OutletController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();
  final LocalAuthentication auth = LocalAuthentication();

  final namaCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();

  var jamBuka = "08:00".obs;
  var jamTutup = "20:00".obs;

  var isAllowKasbon = true.obs;

  var isLoading = false.obs;

  var errNama = RxnString();
  var errAlamat = RxnString();

  static OutletModel? cachedOutlet;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    if (cachedOutlet != null) {
      _populateForm(cachedOutlet!);
      isFirstLoad = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    fetchOutletData(showLoading: isFirstLoad);
  }

  void _populateForm(OutletModel outlet) {
    namaCtrl.text = outlet.namaOutlet;
    alamatCtrl.text = outlet.alamat ?? "";
    jamBuka.value = outlet.jamBuka ?? "08:00";
    jamTutup.value = outlet.jamTutup ?? "20:00";
    isAllowKasbon.value = outlet.allowKasbon;
  }

  void clearErrors() {
    errNama.value = null;
    errAlamat.value = null;
  }

  bool hasEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true).hasMatch(text);
  }

  Future<void> fetchOutletData({bool showLoading = true}) async {
    final outletId = userC.outletId;
    if (outletId == null) return;

    try {
      if (showLoading) isLoading.value = true;

      final data = await supabase
          .from('outlets')
          .select()
          .eq('id', outletId)
          .maybeSingle();

      if (data != null) {
        final outlet = OutletModel.fromMap(data);
        cachedOutlet = outlet;
        _populateForm(outlet);
      }
    } catch (e) {
      if (showLoading) Get.snackbar("Error", "Gagal mengambil data outlet", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> pilihJam(BuildContext context, bool isBuka) async {
    String currentTime = isBuka ? jamBuka.value : jamTutup.value;
    int currentHour = 8;
    int currentMin = 0;

    if (currentTime.contains(":")) {
       currentHour = int.tryParse(currentTime.split(":")[0]) ?? 8;
       currentMin = int.tryParse(currentTime.split(":")[1]) ?? 0;
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMin),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2196F3)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      String formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (isBuka) {
        jamBuka.value = formattedTime;
      } else {
        jamTutup.value = formattedTime;
      }
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        return true;
      }

      return await auth.authenticate(
        localizedReason: 'Verifikasi identitas untuk mengubah profil outlet',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Error Biometric: $e");
      return false;
    }
  }

  Future<void> simpanProfil() async {
    clearErrors();
    bool isValid = true;
    final outletId = userC.outletId;

    String nama = namaCtrl.text.trim();
    String alamat = alamatCtrl.text.trim();

    if (nama.isEmpty) {
      errNama.value = "Nama Outlet wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) {
      errNama.value = "Tidak boleh ada emoji";
      isValid = false;
    }

    if (alamat.isEmpty) {
      errAlamat.value = "Alamat wajib diisi";
      isValid = false;
    } else if (alamat.length < 5) {
      errAlamat.value = "Alamat terlalu pendek";
      isValid = false;
    }

    if (!isValid) return;
    if (outletId == null) {
       Get.snackbar("Error", "Akses ditolak. ID Outlet tidak valid.", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    bool isAuthorized = await _authenticateUser();
    if (!isAuthorized) {
      HapticFeedback.heavyImpact();
      Get.snackbar("Akses Ditolak", "Gagal memverifikasi identitas. Perubahan dibatalkan.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      await supabase.from('outlets').update({
        'nama_outlet': nama,
        'alamat': alamat,
        'jam_buka': jamBuka.value,
        'jam_tutup': jamTutup.value,
        'allow_kasbon': isAllowKasbon.value,
      }).eq('id', outletId);

      cachedOutlet = OutletModel(
         id: outletId,
         namaOutlet: nama,
         alamat: alamat,
         jamBuka: jamBuka.value,
         jamTutup: jamTutup.value,
         allowKasbon: isAllowKasbon.value,
      );

      HapticFeedback.mediumImpact();
      Get.back();
      Get.snackbar(
        "Sukses", "Profil Outlet berhasil diperbarui!",
        backgroundColor: Colors.green, colorText: Colors.white,
      );

    } catch (e) {
      ErrorHandler.show(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}