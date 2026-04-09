import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'layanan_controller.dart';

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
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();
  final layC = Get.put(LayananController());

  var cart = <Map<String, dynamic>>[].obs;
  var isAntarJemput = false.obs;
  var isPenjemputan = true.obs;
  var isPengantaran = true.obs;
  var deliveryFee = 0.obs;
  var isLoading = false.obs;

  var pelangganDipilih = {}.obs;

  final alamatCtrl = TextEditingController();
  final catatanCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      pelangganDipilih.value = Get.arguments;
    }
  }

  List<Map<String, dynamic>> get listServices => layC.listServices;
  int get totalItem => cart.length;
  int get subtotalPesanan => cart.fold(0, (sum, item) => sum + (item['subtotal_harga'] as int));
  int get totalTagihan => subtotalPesanan + (isAntarJemput.value ? deliveryFee.value : 0);

  // --- FUNGSI BARU UNTUK ONG KIR (BIAR GAK ERROR) ---
  void showOngkirDialog(BuildContext context) {
    final ongkirCtrl = TextEditingController(text: deliveryFee.value.toString());
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Atur Ongkos Kirim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: ongkirCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyFormat()],
                decoration: const InputDecoration(prefixText: "Rp ", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    deliveryFee.value = int.tryParse(ongkirCtrl.text.replaceAll('.', '')) ?? 0;
                    Get.back();
                  },
                  child: const Text("Simpan"),
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  void addOrUpdateCart(Map<String, dynamic> service, double qty, String keterangan) {
    int subtotal = (service['harga'] * qty).toInt();
    int existingIndex = cart.indexWhere((item) => item['service_id'] == service['id']);

    if (existingIndex != -1) {
      cart[existingIndex] = {
        "service_id": service['id'],
        "nama_layanan": service['nama_layanan'],
        "kategori": service['kategori'],
        "harga_satuan": service['harga'],
        "durasi_jam": service['durasi_jam'],
        "kuantitas": qty,
        "subtotal_harga": subtotal,
        "keterangan": keterangan,
      };
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

  void toggleAntarJemput(bool val) {
    isAntarJemput.value = val;
    if (!val) {
      deliveryFee.value = 0;
      alamatCtrl.clear();
    }
  }

  // --- FIX PARAMETER: Dibuat support 3 arguments agar View tidak merah ---
  Future<void> buatTransaksi(String id, String nama, String phone) async {
    if (cart.isEmpty) {
      Get.snackbar("Error", "Pesanan kosong!");
      return;
    }

    try {
      isLoading.value = true;
      String nota = "NOT-${DateTime.now().millisecondsSinceEpoch}";

      final trxRes = await supabase.from('transactions').insert({
        'outlet_id': userC.outletId,
        'customer_id': int.parse(id), // Pakai ID dari parameter
        'user_id': userC.currentUser.value?.id,
        'nomor_nota': nota,
        'total_tagihan': totalTagihan,
        'status_pesanan': 'proses',
        'status_pembayaran': 'Belum Lunas',
        'tipe_logistik': isAntarJemput.value ? 'antar_jemput' : 'none',
        'delivery_fee': deliveryFee.value,
        'estimasi_selesai': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      }).select().single();

      final List<Map<String, dynamic>> details = cart.map((item) => {
        'transaction_id': trxRes['id'],
        'service_id': item['service_id'],
        'kuantitas': item['kuantitas'],
        'subtotal_harga': item['subtotal_harga'],
      }).toList();

      await supabase.from('transaction_details').insert(details);

      Get.defaultDialog(
        title: "Sukses",
        middleText: "Transaksi $nota berhasil!",
        onConfirm: () => Get.offAllNamed('/home'),
        textConfirm: "OK",
      );

      cart.clear();
      catatanCtrl.clear();
      alamatCtrl.clear();

    } catch (e) {
      Get.snackbar("Gagal", "Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    catatanCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}