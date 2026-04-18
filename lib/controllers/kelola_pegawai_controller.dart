import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'tambah_pegawai_controller.dart';
import '../views/tambah_pegawai_view.dart';

class KelolaPegawaiController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listPegawai = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSearching = false.obs;
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (userC.outletId != null) fetchPegawai();
  }

  List<Map<String, dynamic>> get filteredPegawai {
    if (searchQuery.value.isEmpty) return listPegawai;
    return listPegawai.where((p) {
      return (p['nama_lengkap'] ?? '').toString().toLowerCase().contains(searchQuery.value.toLowerCase()) || 
             (p['no_hp'] ?? '').toString().contains(searchQuery.value);
    }).toList();
  }

  Future<void> fetchPegawai() async {
    if (userC.outletId == null) return;
    try {
      isLoading.value = true;
      final data = await supabase
          .from('users')
          .select()
          .eq('outlet_id', userC.outletId!)
          .neq('role', 'owner') 

          .order('created_at', ascending: false);

      listPegawai.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data pegawai: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(String id, bool currentStatus, String nama) async {
    try {
      bool newStatus = !currentStatus;

      await supabase
          .from('users')
          .update({'status_aktif': newStatus})
          .eq('id', id);

      await fetchPegawai(); 

      String statusText = newStatus ? "Aktif" : "Nonaktif";
      Get.snackbar("Status Diperbarui", "Akses $nama sekarang $statusText", 
          backgroundColor: newStatus ? Colors.green : Colors.orange, 
          colorText: Colors.white, 
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah status: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void hapusPegawai(String id, String nama) {
    Get.defaultDialog(
      title: "Hapus Pegawai?",
      middleText: "Yakin ingin menghapus $nama dari sistem?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        try {
          await supabase.from('users').delete().eq('id', id);

          await fetchPegawai(); 
          Get.back(); 

          Get.snackbar("Berhasil", "Data $nama telah dihapus", 
              backgroundColor: Colors.red.shade600, colorText: Colors.white);
        } catch (e) {
          Get.back();
          Get.snackbar("Error", "Gagal menghapus pegawai: $e", 
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }

  void goToEdit(Map<String, dynamic> pegawai) {
    final tamC = Get.put(TambahPegawaiController());
    tamC.setEditMode(pegawai); 

    Get.to(() => TambahPegawaiView());
  }
}