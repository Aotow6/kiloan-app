import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/detail_pelanggan_view.dart';

class PelangganController extends GetxController {

  var listPelanggan = [
    {"id": 1, "nama": "ggg", "telepon": "+6285753556422"},
    {"id": 2, "nama": "ajang", "telepon": ""},
    {"id": 3, "nama": "Budi Santoso", "telepon": "081234567890"},
  ].obs;

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs; 

  var sortType = 'Terbaru'.obs; 

  List<Map<String, dynamic>> get filteredPelanggan {
    if (searchQuery.value.isEmpty) {
      return listPelanggan;
    }
    return listPelanggan.where((p) {
      return p['nama'].toString().toLowerCase().contains(searchQuery.value.toLowerCase()) || 
             p['telepon'].toString().contains(searchQuery.value);
    }).toList();
  }

  void changeSort(String val) {
    sortType.value = val;
  }

  void hapusPelanggan(int id, String nama) {
    Get.defaultDialog(
      title: "Hapus Pelanggan?",
      middleText: "Yakin ingin menghapus data $nama?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () {
        listPelanggan.removeWhere((pelanggan) => pelanggan['id'] == id);
        Get.back(); 
        Get.snackbar("Berhasil", "Data $nama telah dihapus", backgroundColor: Colors.red.shade600, colorText: Colors.white);
      }
    );
  }

  final namaCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var isTanpaNomor = false.obs; 

  void toggleTanpaNomor(bool? val) {
    isTanpaNomor.value = val ?? false;
    if (isTanpaNomor.value) {
      phoneCtrl.clear(); 
    }
  }

  void goToDetail(String nama, String phone) {
    Get.to(() => DetailPelangganView(nama: nama, phone: phone));
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    namaCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}