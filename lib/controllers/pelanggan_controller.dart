import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class PelangganController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listPelanggan = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs;

  final namaCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var isTanpaNomor = false.obs;

  var sortType = 'Terbaru'.obs;

  void changeSort(String val) {
    sortType.value = val;
    if (val == 'Abjad') {
      listPelanggan.sort((a, b) => (a['nama_pelanggan'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b['nama_pelanggan'] ?? '')
              .toString()
              .toLowerCase()));
    } else {
      listPelanggan.sort((a, b) => b['id'].compareTo(a['id']));
    }
  }

  void goToDetail(String nama, String noHp) {
    Get.snackbar("Info", "Membuka profil $nama");
  }

  @override
  void onInit() {
    super.onInit();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    try {
      isLoading.value = true;

      final data = await supabase
          .from('customers')
          .select()
          .eq('outlet_id', userC.outletId)
          .order('created_at', ascending: false);

      listPelanggan.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> simpanPelanggan() async {
    if (namaCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Gagal",
        "Nama wajib diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await supabase.from('customers').insert({
        'outlet_id': userC.outletId,
        'nama_pelanggan': namaCtrl.text.trim(),
        'no_wa': isTanpaNomor.value ? null : phoneCtrl.text.trim(),
        'total_kasbon': 0,
      });

      namaCtrl.clear();
      phoneCtrl.clear();
      isTanpaNomor.value = false;

      await fetchPelanggan();

      Get.back();
      Get.snackbar(
        "Sukses",
        "Pelanggan berhasil ditambahkan",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal simpan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hapusPelanggan(int id) async {
    try {
      await supabase.from('customers').delete().eq('id', id);
      await fetchPelanggan();
      Get.snackbar("Sukses", "Data berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal hapus: $e");
    }
  }

  List<Map<String, dynamic>> get filteredPelanggan {
    if (searchQuery.value.isEmpty) return listPelanggan;

    return listPelanggan.where((p) {
      return p['nama_pelanggan']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          (p['no_wa'] ?? '').toString().contains(searchQuery.value);
    }).toList();
  }

  void toggleTanpaNomor(bool? val) {
    isTanpaNomor.value = val ?? false;
    if (isTanpaNomor.value) {
      phoneCtrl.clear();
    }
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    namaCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}