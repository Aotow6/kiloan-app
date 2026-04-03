import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KelolaPegawaiController extends GetxController {

  var listPegawai = [
    {"id": 1, "nama": "Satria Rajawali", "telepon": "081234567890", "username": "satria_admin", "isActive": true},
  ].obs;

  void toggleStatus(int index, bool value) {
    listPegawai[index]['isActive'] = value;
    listPegawai.refresh(); 

    String status = value ? "Aktif" : "Nonaktif";
    Get.snackbar("Status Diperbarui", "${listPegawai[index]['nama']} sekarang $status", backgroundColor: Colors.blue.shade600, colorText: Colors.white, duration: const Duration(seconds: 1));
  }

  void hapusPegawai(int id, String nama) {
    Get.defaultDialog(
      title: "Hapus Pegawai?",
      middleText: "Yakin ingin menghapus $nama dari sistem?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () {
        listPegawai.removeWhere((pegawai) => pegawai['id'] == id);
        Get.back(); 

        Get.snackbar("Berhasil", "Data $nama telah dihapus", backgroundColor: Colors.red.shade600, colorText: Colors.white);
      }
    );
  }
}