import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailPesananController extends GetxController {

  var isAntarJemputExpanded = false.obs;

  var isDetailTagihanExpanded = true.obs;
  var isDetailPembayaranExpanded = true.obs;

  void toggleDetailTagihan() => isDetailTagihanExpanded.value = !isDetailTagihanExpanded.value;
  void toggleDetailPembayaran() => isDetailPembayaranExpanded.value = !isDetailPembayaranExpanded.value;

  var ongkir = 0.obs; 
  final ongkirCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  var isPengantaranSaved = false.obs;

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
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Yakin ingin menyimpan data pengantaran ini?",
      textCancel: "Batal",
      textConfirm: "Simpan",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2196F3),
      onConfirm: () {
        isPengantaranSaved.value = true;
        Get.back(); 

        Get.back(); 

        Get.snackbar("Sukses", "Data berhasil disimpan!", backgroundColor: Colors.green, colorText: Colors.white);
      },
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