import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SensorService extends GetxService {
  final ImagePicker _picker = ImagePicker();
  final LocalAuthentication _auth = LocalAuthentication();

  // SENSOR 1: KAMERA
  Future<XFile?> ambilFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Kompresi agar tidak berat saat upload ke database
      );
      return image;
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka kamera: $e", 
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  // SENSOR 2: BIOMETRIK
  Future<bool> validasiUser(String pesan) async {
    try {
      bool bisaBiometrik = await _auth.canCheckBiometrics;
      bool perangkatSupport = await _auth.isDeviceSupported();

      if (!bisaBiometrik || !perangkatSupport) return true;

      return await _auth.authenticate(
        localizedReason: pesan,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint("Error Biometrik: $e");
      return false;
    }
  }
}