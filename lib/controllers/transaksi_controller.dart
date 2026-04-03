import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    String formatted = cleanText.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
class TransaksiController extends GetxController {

  var listServices = [
    {"id": 1, "kategori": "Bed Cover", "nama_layanan": "King", "harga": 25000, "durasi_jam": 72},
    {"id": 2, "kategori": "Bed Cover", "nama_layanan": "Queen", "harga": 18000, "durasi_jam": 72},
    {"id": 3, "kategori": "Bed Cover", "nama_layanan": "Single", "harga": 15000, "durasi_jam": 72},
    {"id": 4, "kategori": "Kiloan", "nama_layanan": "Express", "harga": 15000, "durasi_jam": 8},
  ];

  var cart = <Map<String, dynamic>>[].obs;

  var isAntarJemput = false.obs;
  var isPenjemputan = true.obs;
  var isPengantaran = true.obs;
  var deliveryFee = 0.obs;
  final alamatCtrl = TextEditingController();

  final catatanCtrl = TextEditingController();

  int get totalItem => cart.length;

  int get subtotalPesanan {
    int total = 0;
    for (var item in cart) {
      total += (item['subtotal_harga'] as int);
    }
    return total;
  }

  int get totalTagihan => subtotalPesanan + (isAntarJemput.value ? deliveryFee.value : 0);

  Map<String, dynamic>? getCartItem(int serviceId) {
    int index = cart.indexWhere((item) => item['service_id'] == serviceId);
    return index != -1 ? cart[index] : null;
  }

  void addOrUpdateCart(Map<String, dynamic> service, double qty, String keterangan) {
    int subtotal = (service['harga'] * qty).toInt();
    int existingIndex = cart.indexWhere((item) => item['service_id'] == service['id']);

    if (existingIndex != -1) {
      cart[existingIndex]['kuantitas'] = qty;
      cart[existingIndex]['subtotal_harga'] = subtotal;
      cart[existingIndex]['keterangan'] = keterangan;
    } else {
      cart.add({
        "service_id": service['id'],
        "nama_layanan": service['nama_layanan'],
        "kategori": service['kategori'],
        "harga_satuan": service['harga'],
        "durasi_jam": service['durasi_jam'],
        "kuantitas": qty,
        "subtotal_harga": subtotal,
        "keterangan": keterangan,
      });
    }
    cart.refresh();
  }

  void ubahQtyCart(int index, double newQty) {
    if (newQty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index]['kuantitas'] = newQty;
      cart[index]['subtotal_harga'] = (cart[index]['harga_satuan'] * newQty).toInt();
    }
    cart.refresh();
  }

  void removeCartItemByServiceId(int serviceId) {
    cart.removeWhere((item) => item['service_id'] == serviceId);
    cart.refresh();
  }

  void toggleAntarJemput(bool val) {
    isAntarJemput.value = val;
    if (!val) {
      deliveryFee.value = 0;
      isPenjemputan.value = true;
      isPengantaran.value = true;
      alamatCtrl.clear();
    }
  }

  void hapusOngkir() {
    deliveryFee.value = 0;
  }

void showOngkirDialog(BuildContext context) {

    String initialOngkir = deliveryFee.value > 0 
        ? deliveryFee.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.') 
        : "";

    final ongkirCtrl = TextEditingController(text: initialOngkir);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF3EDF7),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Atur Ongkos Kirim", style: TextStyle(fontSize: 18, color: Color(0xFF102A43))),
              const SizedBox(height: 20),

              TextField(
                controller: ongkirCtrl,
                keyboardType: TextInputType.number,

                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), 

                  CurrencyFormat(), 

                  LengthLimitingTextInputFormatter(11), 

                ],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: const InputDecoration(
                  prefixText: "Rp ",
                  prefixStyle: TextStyle(color: Colors.black87, fontSize: 16),
                  isDense: true, 
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 1.5)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 1.5)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2.5)),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Batal", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {

                      String cleanAngka = ongkirCtrl.text.replaceAll('.', '');
                      deliveryFee.value = int.tryParse(cleanAngka) ?? 0;
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0
                    ),
                    child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
  void buatTransaksi(String customerId) {
    if (cart.isEmpty) {
      Get.snackbar("Error", "Pesanan kosong!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    String tipeLogistik = "Bawa Sendiri";
    if (isAntarJemput.value) {
      if (isPenjemputan.value && isPengantaran.value) tipeLogistik = "Jemput & Antar";
      else if (isPenjemputan.value) tipeLogistik = "Jemput Saja";
      else if (isPengantaran.value) tipeLogistik = "Antar Saja";
    }

    Get.snackbar("Sukses", "Transaksi $tipeLogistik berhasil dibuat!", backgroundColor: Colors.green, colorText: Colors.white);
    cart.clear();
    catatanCtrl.clear();
    alamatCtrl.clear();
    toggleAntarJemput(false);
    Get.offAllNamed('/home'); 
  }

  @override
  void onClose() {
    catatanCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}