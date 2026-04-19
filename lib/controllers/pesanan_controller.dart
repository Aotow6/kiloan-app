import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/controllers/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class PesananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var selectedTab = 0.obs;
  var listPesanan = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  final int limit = 10;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

  final List<String> tabs = ["Diproses", "Selesai", "Diambil", "Batal"];

  bool get isOwner => userC.isOwner;

  @override
  void onInit() {
    super.onInit();
    fetchPesanan();
  }

  Future<void> pilihTanggal(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
      helpText: "Pilih Rentang Tanggal Pesanan",
      saveText: "TERAPKAN",
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      fetchPesanan(); 
    }
  }

  void resetFilterTanggal() {
    startDate.value = null;
    endDate.value = null;
    fetchPesanan();
  }

  Future<void> fetchPesanan() async {
    try {
      isLoading.value = true;
      hasMore.value = true;

      String statusFilter = tabs[selectedTab.value].toLowerCase();
      if (statusFilter == "diproses") statusFilter = "proses";

      var query = supabase
          .from('transactions')
          .select('*, customers(nama_pelanggan, no_wa)')
          .eq('outlet_id', userC.outletId!)
          .eq('status_pesanan', statusFilter);

      if (startDate.value != null && endDate.value != null) {
        query = query
            .gte('waktu_masuk', startDate.value!.toIso8601String())
            .lte('waktu_masuk', endDate.value!.toIso8601String());
      }

      final data = await query.order('waktu_masuk', ascending: false).range(0, limit - 1);

      if (data.length < limit) hasMore.value = false;
      listPesanan.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      ErrorHandler.show(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePesanan() async {
    if (isLoadingMore.value || !hasMore.value) return;
    try {
      isLoadingMore.value = true;
      String statusFilter = tabs[selectedTab.value].toLowerCase();
      if (statusFilter == "diproses") statusFilter = "proses";

      int start = listPesanan.length;
      int end = start + limit - 1;

      var query = supabase
          .from('transactions')
          .select('*, customers(nama_pelanggan, no_wa)')
          .eq('outlet_id', userC.outletId!)
          .eq('status_pesanan', statusFilter);

      if (startDate.value != null && endDate.value != null) {
        query = query
            .gte('waktu_masuk', startDate.value!.toIso8601String())
            .lte('waktu_masuk', endDate.value!.toIso8601String());
      }

      final data = await query.order('waktu_masuk', ascending: false).range(start, end);

      if (data.length < limit) hasMore.value = false;
      listPesanan.addAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint("Error load more: ");
    } finally {
      isLoadingMore.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    fetchPesanan();
  }

  Future<void> updateStatusPesanan(int id, String statusBaru) async {
    try {
      await supabase.from('transactions').update({'status_pesanan': statusBaru.toLowerCase()}).eq('id', id);
      fetchPesanan(); 
      Get.back(); 
      Get.snackbar("Berhasil", "Status pesanan telah diubah", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) { Get.snackbar("Error", "Terjadi kesalahan"); }
  }

  Future<void> lunasiPembayaran(int idTransaksi) async {
    try {
      await supabase.from('transactions').update({'status_pembayaran': 'Lunas'}).eq('id', idTransaksi);
      await fetchPesanan(); 
      Get.back();
      Get.snackbar("Lunas!", "Pembayaran diterima", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) { Get.snackbar("Error", "Terjadi kesalahan"); }
  }

  Future<Map<String, dynamic>?> fetchDetailPesanan(int transactionId) async {
    try {
      return await supabase.from('transactions').select('*, customers(*)').eq('id', transactionId).single();
    } catch (e) { return null; }
  }

  Future<void> batalkanPesanan(int transactionId, bool isLunas, int totalDibayar) async {
    try {
      await supabase.from('transactions').update({'status_pesanan': 'batal'}).eq('id', transactionId);
      if (isLunas && totalDibayar > 0) {
        await supabase.from('cashflows').insert({
          'outlet_id': userC.outletId,
          'user_id': userC.currentUser.value?.id,
          'transaction_id': transactionId,
          'tipe_arus': 'Pengeluaran',
          'nominal': totalDibayar, 
          'metode_bayar': 'Tunai', 
          'keterangan': 'Refund Batal',
        });
      }
      Get.back(); 
      fetchPesanan(); 
      Get.snackbar("Dibatalkan", "Pesanan batal", backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) { Get.snackbar("Error", "Terjadi kesalahan"); }
  }

  Future<void> hapusTransaksiPermanen(int transactionId) async {
    Get.defaultDialog(
      title: "Hapus Transaksi",
      middleText: "Hapus permanen?",
      textConfirm: "Ya", textCancel: "Batal",
      onConfirm: () async {
        Get.back(); 
        try {
          isLoading.value = true;
          await supabase.from('transaction_details').delete().eq('transaction_id', transactionId);
          await supabase.from('cashflows').delete().eq('transaction_id', transactionId);
          await supabase.from('transactions').delete().eq('id', transactionId);
          await fetchPesanan(); 
          Get.back(); 
        } catch (e) { Get.snackbar("Error", "Terjadi kesalahan"); }
        finally { isLoading.value = false; }
      }
    );
  }
}