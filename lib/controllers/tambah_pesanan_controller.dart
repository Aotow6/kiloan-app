import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'pesanan_controller.dart';

class TambahPesananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var isLoading = false.obs;

  // Data Input
  var selectedPelangganId = Rxn<int>();
  var selectedLayananId = Rxn<int>();
  
  final beratCtrl = TextEditingController(text: "1");
  final catatanCtrl = TextEditingController();
  
  var hargaLayanan = 0.obs;
  var totalHarga = 0.obs;

  // List untuk Dropdown (diambil dari DB)
  var listPelanggan = <Map<String, dynamic>>[].obs;
  var listLayanan = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      // Ambil data pelanggan & layanan sesuai outlet_id user
      final pelanggan = await supabase.from('customers').select().eq('outlet_id', userC.outletId);
      final layanan = await supabase.from('services').select().eq('outlet_id', userC.outletId);
      
      listPelanggan.assignAll(List<Map<String, dynamic>>.from(pelanggan));
      listLayanan.assignAll(List<Map<String, dynamic>>.from(layanan));
    } finally {
      isLoading.value = false;
    }
  }

  void hitungTotal() {
    double berat = double.tryParse(beratCtrl.text) ?? 0;
    totalHarga.value = (berat * hargaLayanan.value).toInt();
  }

  Future<void> simpanPesanan() async {
    if (selectedPelangganId.value == null || selectedLayananId.value == null) {
      Get.snackbar("Error", "Pilih pelanggan dan layanan dulu!");
      return;
    }

    try {
      isLoading.value = true;
      
      // 1. Insert ke Transactions
      final transaction = await supabase.from('transactions').insert({
        'outlet_id': userC.outletId,
        'customer_id': selectedPelangganId.value,
        'user_id': supabase.auth.currentUser!.id,
        'nomor_nota': "TRX-${DateTime.now().millisecondsSinceEpoch}",
        'total_tagihan': totalHarga.value,
        'status_pesanan': 'proses',
        'status_pembayaran': 'Belum Lunas',
        'waktu_masuk': DateTime.now().toIso8601String(),
      }).select().single();

      // 2. Insert ke Transaction Details
      await supabase.from('transaction_details').insert({
        'transaction_id': transaction['id'],
        'service_id': selectedLayananId.value,
        'kuantitas': double.parse(beratCtrl.text),
        'subtotal_harga': totalHarga.value,
      });

      Get.back(); // Tutup halaman tambah
      Get.find<PesananController>().fetchPesanan(); // Refresh list pesanan
      Get.snackbar("Sukses", "Pesanan berhasil dibuat!");
      
    } catch (e) {
      Get.snackbar("Error", "Gagal simpan: ");
    } finally {
      isLoading.value = false;
    }
  }
}