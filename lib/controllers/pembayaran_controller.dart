import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

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
      String metode = selectedTab.value == 0 ? "Tunai" : selectedMethod.value;

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
        'keterangan': 'Pelunasan Nota',
      });

      Get.offAllNamed('/home');
      Get.snackbar(
        "Sukses",
        "Pembayaran Lunas via $metode",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memproses pembayaran: $e");
    }
  }

  Future<void> jadikanBon() async {
    try {
      await supabase.from('transactions').update({
        'status_pembayaran': 'Belum Lunas',
      }).eq('id', idTransaksi.value);

      await supabase.rpc('increment_customer_kasbon', params: {
        'row_id': idCustomer.value,
        'amount': totalTagihan.value,
      });

      Get.offAllNamed('/home');
      Get.snackbar(
        "Info",
        "Transaksi dicatat sebagai BON",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal mencatat BON: $e");
    }
  }

  @override
  void onClose() {
    uangDiterimaCtrl.dispose();
    super.onClose();
  }
}