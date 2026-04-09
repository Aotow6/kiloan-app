import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class KelolaPegawaiController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listPegawai = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (userC.outletId != null) fetchPegawai();
  }

  // --- 1. AMBIL DATA PEGAWAI (KASIR) ---
  Future<void> fetchPegawai() async {
    if (userC.outletId == null) return;
    try {
      isLoading.value = true;
      final data = await supabase
          .from('users')
          .select()
          .eq('outlet_id', userC.outletId!)
          .neq('role', 'Owner') // Sembunyikan akun Owner biar aman
          .order('created_at', ascending: false);

      listPegawai.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data pegawai: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. UBAH STATUS AKTIF/NONAKTIF ---
  Future<void> toggleStatus(String id, bool currentStatus, String nama) async {
    try {
      bool newStatus = !currentStatus;
      
      // Update ke database
      await supabase
          .from('users')
          .update({'status_aktif': newStatus})
          .eq('id', id);

      // Refresh list
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

  // --- 3. HAPUS PEGAWAI ---
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
          // Hapus dari database
          await supabase.from('users').delete().eq('id', id);
          
          await fetchPegawai(); // Refresh data
          Get.back(); // Tutup dialog

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
}