import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart'; 

class LayananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listServices = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final kategoriCtrl = TextEditingController();
  final namaLayananCtrl = TextEditingController();
  final hargaCtrl = TextEditingController();
  final durasiCtrl = TextEditingController();

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs;
  var selectedFilter = "Semua".obs;

  @override
  void onInit() {
    super.onInit();
    if (userC.outletId != null) {
      fetchServices(); 
    }
  }

  Future<void> fetchServices() async {
    if (userC.outletId == null) return;
    try {
      isLoading.value = true;
      final data = await supabase
          .from('services')
          .select()
          .eq('outlet_id', userC.outletId) 
          .order('kategori', ascending: true);
      
      listServices.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> simpanLayanan() async {
    if (kategoriCtrl.text.isEmpty || namaLayananCtrl.text.isEmpty || hargaCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Kolom kategori, nama, dan harga wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('services').insert({
        'outlet_id': userC.outletId, 
        'kategori': kategoriCtrl.text.trim(),
        'nama_layanan': namaLayananCtrl.text.trim(),
        'harga': int.parse(hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'durasi_jam': int.tryParse(durasiCtrl.text) ?? 0,
        'satuan': kategoriCtrl.text.toLowerCase().contains('kiloan') ? 'Kg' : 'Pcs',
      });

      await fetchServices(); 
      Get.back(); 
      Get.snackbar(
        "Sukses",
        "Layanan berhasil disimpan",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      kategoriCtrl.clear();
      namaLayananCtrl.clear();
      hargaCtrl.clear();
      durasiCtrl.clear();
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menyimpan layanan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void siapkanEdit(Map<String, dynamic> service) {
    kategoriCtrl.text = service['kategori']?.toString() ?? '';
    namaLayananCtrl.text = service['nama_layanan']?.toString() ?? '';
    hargaCtrl.text = service['harga']?.toString() ?? '';
    durasiCtrl.text = service['durasi_jam']?.toString() ?? '0';
  }

  Future<void> updateLayanan(int id) async {
    if (namaLayananCtrl.text.isEmpty || hargaCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Nama dan harga tidak boleh kosong!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('services').update({
        'nama_layanan': namaLayananCtrl.text.trim(),
        'harga': int.parse(hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'durasi_jam': int.tryParse(durasiCtrl.text) ?? 0,
      }).eq('id', id);

      await fetchServices(); 
      Get.back(); 
      Get.snackbar(
        "Sukses",
        "Layanan berhasil diupdate!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Gagal", "Gagal update: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void hapusLayanan(int id, String nama) {
    Get.defaultDialog(
      title: "Hapus Layanan",
      middleText: "Yakin hapus $nama?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          await supabase.from('services').delete().eq('id', id);
          fetchServices(); 
          Get.back(); 
          Get.snackbar("Berhasil", "$nama telah dihapus");
        } catch (e) {
          Get.snackbar("Error", "Gagal menghapus: $e");
        }
      },
    );
  }
 
  List<String> get filterOptions {
    var categories = listServices
        .map((e) => e['kategori'].toString())
        .toSet()
        .toList();
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
      bool matchesFilter =
          selectedFilter.value == "Semua" ||
          service['kategori'] == selectedFilter.value;

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