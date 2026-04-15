import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'detail_pesanan_controller.dart'; 

class PembayaranController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var totalTagihan = 0.obs;
  var idTransaksi = 0.obs;
  var idCustomer = 0.obs;

  var selectedTab = 0.obs;
  var uangDiterima = 0.obs;
  final uangDiterimaCtrl = TextEditingController();
  var selectedMethod = "".obs;

  var isLoading = false.obs; 

  int get kembalian {
    int sisa = uangDiterima.value - totalTagihan.value;
    return sisa < 0 ? 0 : sisa;
  }

  void updateUangDiterima(String val) {
    String cleanText = val.replaceAll(RegExp(r'[^0-9]'), '');
    uangDiterima.value = cleanText.isEmpty ? 0 : int.parse(cleanText);
  }

  void setUangCepat(int nominal) {
    uangDiterima.value = nominal;
    uangDiterimaCtrl.text = formatRupiah(nominal);
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedMethod.value = "";
  }

  String formatRupiah(int val) {
    return val.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future<void> prosesBayar() async {
    try {
      isLoading.value = true;
      String metode = selectedTab.value == 0 ? "Tunai" : selectedMethod.value;

      final trxData = await supabase.from('transactions').select('status_pembayaran').eq('id', idTransaksi.value).single();
      bool wasBon = trxData['status_pembayaran'] == 'Bon';

      if (wasBon) {

        final customerData = await supabase.from('customers').select('total_kasbon').eq('id', idCustomer.value).single();
        int kasbonLama = customerData['total_kasbon'] ?? 0;
        int kasbonBaru = kasbonLama - totalTagihan.value;

        if (kasbonBaru < 0) kasbonBaru = 0; 

        await supabase.from('customers').update({
          'total_kasbon': kasbonBaru
        }).eq('id', idCustomer.value);
      }

      await supabase.from('transactions').update({
        'total_dibayar': totalTagihan.value,
        'status_pembayaran': 'Lunas',
      }).eq('id', idTransaksi.value);

      await supabase.from('cashflows').insert({
        'outlet_id': userC.outletId,
        'user_id': userC.currentUser.value?.id,
        'transaction_id': idTransaksi.value,
        'tipe_arus': 'Pemasukan',
        'nominal': totalTagihan.value,
        'metode_bayar': metode,
        'keterangan': wasBon ? 'Pelunasan Bon' : 'Pelunasan Nota', 

      });

      Get.back(result: true); 
      Get.snackbar("Sukses", "Pembayaran Berhasil", backgroundColor: Colors.green, colorText: Colors.white);

      if(Get.isRegistered<DetailPesananController>()) {
        final detailC = Get.find<DetailPesananController>();
        await detailC.fetchDetailItems(idTransaksi.value, "");
        final latestHeader = await supabase.from('transactions').select('*, customers(*)').eq('id', idTransaksi.value).single();
        detailC.headerData.value = latestHeader;
        detailC.isDataChanged = true;
      }

    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> jadikanBon() async {
    try {
      isLoading.value = true;

      final customerData = await supabase
          .from('customers')
          .select('total_kasbon')
          .eq('id', idCustomer.value)
          .single();

      int kasbonLama = customerData['total_kasbon'] ?? 0;
      int kasbonBaru = kasbonLama + totalTagihan.value;

      await supabase.from('transactions').update({
        'status_pembayaran': 'Bon',
      }).eq('id', idTransaksi.value);

      await supabase.from('customers').update({
        'total_kasbon': kasbonBaru,
      }).eq('id', idCustomer.value);

      Get.back(result: true); 
      Get.snackbar(
        "Berhasil",
        "Transaksi dicatat sebagai BON. Kasbon pelanggan bertambah.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      if(Get.isRegistered<DetailPesananController>()) {
        final detailC = Get.find<DetailPesananController>();
        await detailC.fetchDetailItems(idTransaksi.value, "");
        final latestHeader = await supabase.from('transactions').select('*, customers(*)').eq('id', idTransaksi.value).single();
        detailC.headerData.value = latestHeader;
        detailC.isDataChanged = true;
      }

    } catch (e) {
      Get.snackbar("Error", "Gagal mencatat BON: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    uangDiterimaCtrl.dispose();
    super.onClose();
  }
}