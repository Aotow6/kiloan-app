import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PembayaranController extends GetxController {

  var totalTagihan = 30080.obs; 

  var selectedTab = 0.obs;

  var uangDiterima = 0.obs;
  final uangDiterimaCtrl = TextEditingController();

  var selectedMethod = "".obs; 

  int get kembalian {
    int sisa = uangDiterima.value - totalTagihan.value;
    return sisa < 0 ? 0 : sisa;
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedMethod.value = ""; 
  }

  void updateUangDiterima(String val) {
    if (val.isEmpty) {
      uangDiterima.value = 0;
    } else {

      String cleanText = val.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanText.isEmpty) {
        uangDiterima.value = 0;
      } else {
        uangDiterima.value = int.parse(cleanText);
      }
    }

    uangDiterima.refresh(); 
  }

  void setUangCepat(int nominal) {
    uangDiterima.value = nominal;

    uangDiterimaCtrl.text = formatRupiah(nominal);
    uangDiterima.refresh();
  }

  void jadikanBon() {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Catat transaksi ini sebagai BON?",
      textCancel: "Batal",
      textConfirm: "Ya, Bon",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back();
        Get.back();
        Get.snackbar("Berhasil", "Transaksi dicatat sebagai Belum Lunas", 
          backgroundColor: Colors.orange, colorText: Colors.white);
      }
    );
  }

  void prosesBayar() {
    String metode = selectedTab.value == 0 ? "Tunai" : selectedMethod.value;
    Get.back();
    Get.snackbar(
      "Sukses", 
      "Pembayaran Lunas via $metode", 
      backgroundColor: Colors.green, 
      colorText: Colors.white
    );
  }

  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  void onClose() {
    uangDiterimaCtrl.dispose();
    super.onClose();
  }
}