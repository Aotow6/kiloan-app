import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'transaksi_controller.dart'; 
import 'pesanan_controller.dart'; 

import '../views/pilih_layanan_view.dart';

class DetailPesananController extends GetxController {
  final supabase = Supabase.instance.client;

  var isAntarJemputExpanded = false.obs;
  var isDetailTagihanExpanded = true.obs;
  var isDetailPembayaranExpanded = true.obs;

  void toggleDetailTagihan() => isDetailTagihanExpanded.value = !isDetailTagihanExpanded.value;
  void toggleDetailPembayaran() => isDetailPembayaranExpanded.value = !isDetailPembayaranExpanded.value;

  var listItems = <Map<String, dynamic>>[].obs;
  var headerData = <String, dynamic>{}.obs;
  var isLoading = false.obs;

  var ongkir = 0.obs; 
  final ongkirCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  final catatanEditCtrl = TextEditingController(); 

  var isPengantaranSaved = false.obs;
  var isDataChanged = false;

  bool hasEmoji(String text) {
    return RegExp(
            r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
            unicode: true)
        .hasMatch(text);
  }

  Future<void> initData(Map<String, dynamic> initialData) async {
    headerData.value = initialData;
    await fetchDetailItems(initialData['id'], initialData['catatan']);
  }

  Future<void> fetchDetailItems(int transactionId, String? catatanAwal) async {
    try {
      isLoading.value = true;
      catatanEditCtrl.text = catatanAwal ?? "";

      final data = await supabase
          .from('transaction_details')
          .select('*, services(*)')
          .eq('transaction_id', transactionId);

      listItems.assignAll(List<Map<String, dynamic>>.from(data));

      final latestHeader = await supabase.from('transactions').select('*, customers(*)').eq('id', transactionId).single();
      headerData.value = latestHeader;

      if (latestHeader['tipe_logistik'] != 'none' && latestHeader['alamat_layanan'] != null) {
        isPengantaranSaved.value = true;
        alamatCtrl.text = latestHeader['alamat_layanan'];
        ongkir.value = latestHeader['delivery_fee'] ?? 0;
      } else {
        isPengantaranSaved.value = false;
        alamatCtrl.clear();
        ongkir.value = 0;
      }

    } catch (e) {
      print("Error ambil detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToEditLayanan(Map<String, dynamic> transaksiLama) async {
    final trxC = Get.put(TransaksiController());
    trxC.cart.clear();

    for (var item in listItems) {
      trxC.cart.add({
        "service_id": item['service_id'],
        "nama_layanan": item['services']?['nama_layanan'] ?? 'Layanan',
        "kategori": item['services']?['kategori'] ?? '',
        "harga_satuan": item['services']?['harga'] ?? 0,
        "durasi_jam": item['services']?['durasi_jam'] ?? 0,
        "kuantitas": (item['kuantitas'] is int) ? (item['kuantitas'] as int).toDouble() : (item['kuantitas'] ?? 1.0),
        "subtotal_harga": item['subtotal_harga'] ?? 0,
        "keterangan": item['keterangan'] ?? "", 
      });
    }

    if (transaksiLama['tipe_logistik'] != 'none' && transaksiLama['tipe_logistik'] != null) {
      trxC.isAntarJemput.value = true;
      trxC.isPenjemputan.value = transaksiLama['tipe_logistik'] == 'jemput' || transaksiLama['tipe_logistik'] == 'antar_jemput';
      trxC.isPengantaran.value = transaksiLama['tipe_logistik'] == 'antar' || transaksiLama['tipe_logistik'] == 'antar_jemput';
      trxC.deliveryFee.value = transaksiLama['delivery_fee'] ?? 0;
      trxC.alamatCtrl.text = transaksiLama['alamat_layanan'] ?? '';
    } else {
      trxC.isAntarJemput.value = false;
      trxC.deliveryFee.value = 0;
      trxC.alamatCtrl.clear();
    }

    Map<String, dynamic> dataPelanggan = {};
    if (transaksiLama['customers'] != null) {
      dataPelanggan = Map<String, dynamic>.from(transaksiLama['customers']);
    }

    trxC.isEditMode.value = true;
    trxC.idTransaksiEdit.value = transaksiLama['id'];

    await Get.to(() => PilihLayananView(
      namaCustomer: dataPelanggan['nama_pelanggan'] ?? 'Pelanggan',
      idCustomer: transaksiLama['customer_id'] ?? 0,
      noHp: dataPelanggan['no_wa'] ?? '',
    )); 
  }

  Future<void> konfirmasiSimpanPengantaran(int transactionId, int subtotalAwal) async {
    String alamatBaru = alamatCtrl.text.trim();
    int ongkirBaru = ongkir.value;

    if (alamatBaru.isEmpty) {
      Get.snackbar("Error", "Alamat layanan tidak boleh kosong!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (hasEmoji(alamatBaru)) {
      Get.snackbar("Error", "Alamat tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (alamatBaru.length < 5) {
      Get.snackbar("Error", "Alamat terlalu pendek! minimal 5 karakter.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (ongkirBaru <= 0) {
      Get.snackbar("Error", "Ongkos kirim wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      await supabase.from('transactions').update({
        'tipe_logistik': 'antar_jemput', 
        'alamat_layanan': alamatBaru,
        'delivery_fee': ongkirBaru,
        'total_tagihan': subtotalAwal + ongkirBaru, 
      }).eq('id', transactionId);

      isDataChanged = true; 
      Get.back(); 

      await fetchDetailItems(transactionId, catatanEditCtrl.text);

      Get.snackbar("Sukses", "Informasi Logistik berhasil disimpan!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error simpan logistik: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> batalkanPengantaran(int transactionId, int subtotalAwal) async {
    try {
      isLoading.value = true;

      await supabase.from('transactions').update({
        'tipe_logistik': 'none',
        'alamat_layanan': null,
        'delivery_fee': 0,
        'total_tagihan': subtotalAwal, 
      }).eq('id', transactionId);

      isDataChanged = true; 
      Get.back(); 

      await fetchDetailItems(transactionId, catatanEditCtrl.text);

      Get.snackbar("Info", "Informasi Logistik dibatalkan", backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error batal logistik: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> simpanCatatan(int transactionId) async {
    String catatanBaru = catatanEditCtrl.text.trim();
    if (catatanBaru.isNotEmpty && hasEmoji(catatanBaru)) {
      Get.snackbar("Error", "Catatan tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await supabase.from('transactions').update({'catatan': catatanBaru.isEmpty ? null : catatanBaru}).eq('id', transactionId);
      isDataChanged = true;

      await fetchDetailItems(transactionId, catatanBaru);

      Get.snackbar("Sukses", "Catatan berhasil diperbarui!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menyimpan catatan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      isLoading.value = true;
      await supabase.from('transactions').update({'status_pesanan': status}).eq('id', id);
      isDataChanged = true;

      if (status == 'diambil') {
        Get.back(result: true); 
        Get.snackbar("Sukses", "Pesanan telah diambil pelanggan", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await fetchDetailItems(id, catatanEditCtrl.text); 
        Get.snackbar("Berhasil", "Status diperbarui jadi ${status.toUpperCase()}", backgroundColor: Colors.blue, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> prosesJadikanBon(int trxId, int custId, int nominal) async {
    try {
      isLoading.value = true;
      final cust = await supabase.from('customers').select('total_kasbon').eq('id', custId).single();
      int currentBon = cust['total_kasbon'] ?? 0;

      await supabase.from('transactions').update({'status_pembayaran': 'Bon'}).eq('id', trxId);
      await supabase.from('customers').update({'total_kasbon': currentBon + nominal}).eq('id', custId);

      isDataChanged = true;

      Get.close(2);

      await fetchDetailItems(trxId, catatanEditCtrl.text); 

      Get.snackbar("Sukses", "Masuk ke catatan Kasbon Pelanggan", backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> kirimNotaWA({required Map<String, dynamic> transaksi, required String namaCustomer, required String noWa}) async {
    if (noWa.isEmpty || noWa.toLowerCase() == "tanpa nomor") {
      Get.snackbar("Gagal", "Pelanggan ini tidak memiliki nomor WhatsApp", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    String phone = noWa.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) phone = '62${phone.substring(1)}';

    StringBuffer pesan = StringBuffer();
    pesan.writeln("*NOTA LAUNDRY* 💧\n-----------------------------------\nHalo kak *$namaCustomer*,\nBerikut rincian pesananmu:\n\n📋 *No. Nota:* ${transaksi['nomor_nota']}\n⏳ *Status Pesanan:* ${transaksi['status_pesanan'].toString().toUpperCase()}\n💳 *Pembayaran:* ${transaksi['status_pembayaran']}\n\n*Rincian Cucian:*");
    for (var item in listItems) {
      String namaLayanan = item['services'] != null ? item['services']['nama_layanan'] : 'Layanan';
      pesan.writeln("- $namaLayanan (${item['kuantitas']}) : Rp ${item['subtotal_harga']}");
    }
    pesan.writeln("-----------------------------------\n💰 *TOTAL TAGIHAN: Rp ${transaksi['total_tagihan']}*\n\nTerima kasih 🙏");

    final Uri waUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(pesan.toString())}");
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

  @override
  void onClose() {
    ongkirCtrl.dispose();
    alamatCtrl.dispose();
    catatanEditCtrl.dispose();

    if (isDataChanged) {
      if (Get.isRegistered<PesananController>()) {
        Get.find<PesananController>().fetchPesanan();
      }
    }

    super.onClose();
  }
}