import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OutletController extends GetxController {

  final namaCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();

  var jamBuka = "08:00".obs;
  var jamTutup = "20:00".obs;

  Future<void> pilihJam(BuildContext context, bool isBuka) async {

    String currentTime = isBuka ? jamBuka.value : jamTutup.value;
    int currentHour = int.parse(currentTime.split(":")[0]);
    int currentMin = int.parse(currentTime.split(":")[1]);

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

  void simpanProfil() {
    if (namaCtrl.text.trim().isEmpty || alamatCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Gagal", "Nama Outlet dan Alamat wajib diisi!", 
        backgroundColor: Colors.red.shade600, colorText: Colors.white,
      );
      return;
    }

    Get.back();
    Get.snackbar(
      "Sukses", "Profil Outlet berhasil diperbarui!", 
      backgroundColor: Colors.green, colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    namaCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}