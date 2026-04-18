import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class PesananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var selectedTab = 0.obs;
  var listPesanan = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  final List<String> tabs = [
    "Diproses",
    "Selesai",
    "Diambil",
    "Batal"
  ];

  bool get isOwner {
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    fetchPesanan();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    fetchPesanan();
  }

  Future<void> fetchPesanan() async {
    try {
      isLoading.value = true;

      String statusFilter = tabs[selectedTab.value].toLowerCase();
      if (statusFilter == "diproses") statusFilter = "proses";

      final data = await supabase
          .from('transactions')
          .select('*, customers(nama_pelanggan, no_wa)')
          .eq('outlet_id', userC.outletId!)
          .eq('status_pesanan', statusFilter)
          .order('waktu_masuk', ascending: false);

      listPesanan.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data pesanan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPesanan(int id, String statusBaru) async {
  try {
    await supabase
        .from('transactions')
        .update({'status_pesanan': statusBaru.toLowerCase()})
        .eq('id', id);

    fetchPesanan(); 

    Get.back(); 

    Get.snackbar(
      "Berhasil", 
      "Status pesanan telah diubah menjadi $statusBaru",
      backgroundColor: Colors.green,
      colorText: Colors.white
    );
  } catch (e) {
    Get.snackbar("Error", "Gagal memperbarui status: $e");
  }
}

Future<void> lunasiPembayaran(int idTransaksi) async {
    try {

      await supabase
          .from('transactions')
          .update({'status_pembayaran': 'Lunas'})
          .eq('id', idTransaksi);

      await fetchPesanan(); 

      Get.back();
      Get.snackbar(
        "Lunas!", 
        "Pembayaran berhasil diterima", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal melunasi pembayaran: $e", 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  Future<Map<String, dynamic>?> fetchDetailPesanan(int transactionId) async {
  try {
    final data = await supabase
        .from('transactions')
        .select('*, customers(*)') 

        .eq('id', transactionId)
        .single();
    return data;
  } catch (e) {
    print("Error fetch detail pesanan: $e");
    return null;
  }
}
Future<void> batalkanPesanan(int transactionId, bool isLunas, int totalDibayar) async {
    try {

      await supabase.from('transactions').update({
        'status_pesanan': 'batal',
      }).eq('id', transactionId);

      if (isLunas && totalDibayar > 0) {
        final userC = Get.find<UserController>();
        await supabase.from('cashflows').insert({
          'outlet_id': userC.outletId,
          'user_id': userC.currentUser.value?.id,
          'transaction_id': transactionId,
          'tipe_arus': 'Pengeluaran',
          'nominal': totalDibayar, 

          'metode_bayar': 'Tunai', 

          'keterangan': 'Refund Pembatalan Pesanan',
        });
      }

      Get.back(); 

      fetchPesanan(); 

      Get.snackbar("Dibatalkan", "Pesanan berhasil dibatalkan", backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal membatalkan pesanan: $e");
    }
  }

  Future<void> hapusTransaksiPermanen(int transactionId) async {
    Get.defaultDialog(
      title: "Hapus Transaksi",
      middleText: "Apakah Anda yakin ingin menghapus transaksi ini secara permanen? Data tidak dapat dikembalikan.",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      cancelTextColor: Colors.blue,
      onConfirm: () async {
        Get.back(); 
        try {
          isLoading.value = true;

          await supabase.from('transaction_details').delete().eq('transaction_id', transactionId);
          await supabase.from('cashflows').delete().eq('transaction_id', transactionId);

          await supabase.from('transactions').delete().eq('id', transactionId);

          await fetchPesanan(); 
          Get.back(); 
          Get.snackbar("Terhapus", "Transaksi berhasil dihapus secara permanen", backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar("Error", "Gagal menghapus transaksi: $e", backgroundColor: Colors.red, colorText: Colors.white);
        } finally {
          isLoading.value = false;
        }
      }
    );
  }
}
