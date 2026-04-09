import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔥 Tambahan Import WA

class DetailPesananController extends GetxController {
  final supabase = Supabase.instance.client;

  var isAntarJemputExpanded = false.obs;
  var isDetailTagihanExpanded = true.obs;
  var isDetailPembayaranExpanded = true.obs;

  void toggleDetailTagihan() => isDetailTagihanExpanded.value = !isDetailTagihanExpanded.value;
  void toggleDetailPembayaran() => isDetailPembayaranExpanded.value = !isDetailPembayaranExpanded.value;

  var listItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  var ongkir = 0.obs; 
  final ongkirCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  var isPengantaranSaved = false.obs;

  Future<void> fetchDetailItems(int transactionId) async {
    try {
      isLoading.value = true;
      final data = await supabase
          .from('transaction_details')
          .select('*, services(*)')
          .eq('transaction_id', transactionId);
      
      listItems.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      print("Error ambil detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 FITUR BARU: KIRIM NOTA KE WHATSAPP 🔥
  // ==========================================
  Future<void> kirimNotaWA({
    required Map<String, dynamic> transaksi,
    required String namaCustomer,
    required String noWa,
  }) async {
    // 1. Validasi Nomor
    if (noWa.isEmpty || noWa.toLowerCase() == "tanpa nomor") {
      Get.snackbar("Gagal", "Pelanggan ini tidak memiliki nomor WhatsApp", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // 2. Format Nomor HP (Ubah awalan 0 jadi 62 untuk format internasional WA)
    String phone = noWa.replaceAll(RegExp(r'[^0-9]'), ''); // Bersihkan karakter aneh
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    // 3. Merangkai Teks Nota
    StringBuffer pesan = StringBuffer();
    pesan.writeln("*NOTA RUTARO LAUNDRY* 💧");
    pesan.writeln("-----------------------------------");
    pesan.writeln("Halo kak *$namaCustomer*,");
    pesan.writeln("Terima kasih sudah mempercayakan cucianmu! Berikut rinciannya:");
    pesan.writeln("");
    pesan.writeln("📋 *No. Nota:* ${transaksi['nomor_nota']}");
    pesan.writeln("⏳ *Status:* ${transaksi['status_pesanan'].toString().toUpperCase()}");
    pesan.writeln("💳 *Pembayaran:* ${transaksi['status_pembayaran']}");
    pesan.writeln("");
    pesan.writeln("*Rincian Cucian:*");
    
    // Looping daftar cucian yang diambil dari database
    for (var item in listItems) {
      String namaLayanan = item['services'] != null ? item['services']['nama_layanan'] : 'Layanan';
      var qty = item['kuantitas'];
      var sub = item['subtotal_harga'];
      pesan.writeln("- $namaLayanan ($qty) : Rp $sub");
    }
    
    pesan.writeln("-----------------------------------");
    pesan.writeln("💰 *TOTAL TAGIHAN: Rp ${transaksi['total_tagihan']}*");
    pesan.writeln("");
    pesan.writeln("Kami akan mengabari kakak jika cucian sudah selesai. 🙏");

    // 4. Buka Aplikasi WhatsApp
    final String urlText = Uri.encodeComponent(pesan.toString());
    final Uri waUrl = Uri.parse("https://wa.me/$phone?text=$urlText");

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Tidak dapat membuka WhatsApp", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka WA: $e");
    }
  }
  // ==========================================

  void simpanOngkir() {
    if (ongkirCtrl.text.isNotEmpty) {
      String cleanText = ongkirCtrl.text.replaceAll('.', '');
      ongkir.value = int.parse(cleanText);
    }
    Get.back(); 
  }

  void hapusOngkir() {
    ongkir.value = 0;
    ongkirCtrl.clear();
  }

  void konfirmasiSimpanPengantaran() {
    // ... [Kode konfirmasi pengantaran tetap sama]
        isPengantaranSaved.value = true;
        Get.back();
        Get.back();
        Get.snackbar(
          "Sukses",
          "Data berhasil disimpan!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
  }

  void batalkanPengantaran() {
    isPengantaranSaved.value = false;
    alamatCtrl.clear();
    hapusOngkir();
    Get.back();
  }

  @override
  void onClose() {
    ongkirCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}