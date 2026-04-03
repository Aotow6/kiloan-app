import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LayananController extends GetxController {

  var listServices = [
    {"id": 1, "kategori": "Bed Cover", "nama_layanan": "King", "harga": 25000, "durasi_jam": 72},
    {"id": 2, "kategori": "Bed Cover", "nama_layanan": "Queen", "harga": 18000, "durasi_jam": 72},
    {"id": 3, "kategori": "Kiloan", "nama_layanan": "Express", "harga": 15000, "durasi_jam": 8},
    {"id": 4, "kategori": "Kiloan", "nama_layanan": "Reguler", "harga": 5000, "durasi_jam": 72},
    {"id": 5, "kategori": "Sepatu", "nama_layanan": "Deep Clean", "harga": 35000, "durasi_jam": 72},
  ].obs;

  final kategoriCtrl = TextEditingController();
  final namaLayananCtrl = TextEditingController();
  final hargaCtrl = TextEditingController();
  final durasiCtrl = TextEditingController();

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs;
  var selectedFilter = "Semua".obs;

  List<String> get filterOptions {
    var categories = listServices.map((e) => e['kategori'].toString()).toSet().toList();
    categories.insert(0, "Semua"); 

    return categories;
  }

  Map<String, List<Map<String, dynamic>>> get groupedServices {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    var filteredList = listServices.where((service) {
      String nama = service['nama_layanan'].toString().toLowerCase();
      String kategori = service['kategori'].toString().toLowerCase();
      String query = searchQuery.value.toLowerCase();

      bool matchesSearch = nama.contains(query) || kategori.contains(query);
      bool matchesFilter = selectedFilter.value == "Semua" || service['kategori'] == selectedFilter.value;

      return matchesSearch && matchesFilter;
    }).toList();

    for (var service in filteredList) {
      String kat = service['kategori'] as String;
      if (!grouped.containsKey(kat)) {
        grouped[kat] = [];
      }
      grouped[kat]!.add(service);
    }
    return grouped;
  }

  void simpanLayanan() {
    if (kategoriCtrl.text.isEmpty || namaLayananCtrl.text.isEmpty || hargaCtrl.text.isEmpty || durasiCtrl.text.isEmpty) {
      Get.snackbar("Error", "Semua kolom wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    int hargaInt = int.parse(hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    int durasiInt = int.parse(durasiCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));

    listServices.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "kategori": kategoriCtrl.text,
      "nama_layanan": namaLayananCtrl.text,
      "harga": hargaInt,
      "durasi_jam": durasiInt,
    });

    Get.back();
    Get.snackbar("Sukses", "Layanan berhasil ditambahkan", backgroundColor: Colors.green, colorText: Colors.white);

    kategoriCtrl.clear();
    namaLayananCtrl.clear();
    hargaCtrl.clear();
    durasiCtrl.clear();
  }

  void hapusLayanan(int id, String nama) {
    Get.defaultDialog(
      title: "Hapus Layanan",
      middleText: "Yakin hapus $nama?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        listServices.removeWhere((item) => item['id'] == id);
        Get.back();
      }
    );
  }

  @override
  void onClose() {
    kategoriCtrl.dispose();
    namaLayananCtrl.dispose();
    hargaCtrl.dispose();
    durasiCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}