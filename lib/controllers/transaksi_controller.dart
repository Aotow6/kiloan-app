import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';
import 'layanan_controller.dart';
import 'pesanan_controller.dart'; 
import '../views/detail_pesanan_view.dart';

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

  bool hasEmoji(String text) {
    return RegExp(
            r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
            unicode: true)
        .hasMatch(text);
  }

  List<Map<String, dynamic>> get listServices => layC.listServices;
  int get totalItem => cart.length;
  int get subtotalPesanan => cart.fold(0, (sum, item) => sum + (item['subtotal_harga'] as int));
  int get totalTagihan => subtotalPesanan + (isAntarJemput.value ? deliveryFee.value : 0);

  void showOngkirDialog(BuildContext context) {
    final ongkirCtrl = TextEditingController(text: deliveryFee.value == 0 ? "" : deliveryFee.value.toString());
    Get.dialog(Dialog(
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
                decoration: const InputDecoration(prefixText: "Rp ", border: OutlineInputBorder(), hintText: "Contoh: 5.000"),
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
        )));
  }

  void hapusOngkir() {
    deliveryFee.value = 0;
  }

  void removeCartItemByServiceId(int serviceId) {
    cart.removeWhere((item) {
      if (item['service_id'] == null) return false;
      return int.tryParse(item['service_id'].toString()) == serviceId;
    });
    cart.refresh();
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

  Future<void> buatTransaksi(String id, String nama, String phone) async {

    if (cart.isEmpty) {
      Get.snackbar("Error", "Pesanan tidak boleh kosong!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String logistikType = 'none';

    if (isAntarJemput.value) {
      String alamat = alamatCtrl.text.trim();

      if (alamat.isEmpty) {
        Get.snackbar("Error", "Alamat antar jemput wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (hasEmoji(alamat)) {
        Get.snackbar("Error", "Alamat tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (!isPenjemputan.value && !isPengantaran.value) {
        Get.snackbar("Error", "Pilih minimal satu: Penjemputan atau Pengantaran!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (deliveryFee.value <= 0) {
        Get.snackbar("Error", "Ongkos kirim wajib diisi jika antar jemput aktif!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (isPenjemputan.value && isPengantaran.value) {
        logistikType = 'antar_jemput';
      } else if (isPenjemputan.value) {
        logistikType = 'jemput';
      } else if (isPengantaran.value) {
        logistikType = 'antar';
      }
    }

    String catatan = catatanCtrl.text.trim();
    if (catatan.isNotEmpty && hasEmoji(catatan)) {
      Get.snackbar("Error", "Catatan tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String nota = "NOT-${DateTime.now().millisecondsSinceEpoch}";

      final trxRes = await supabase.from('transactions').insert({
        'outlet_id': userC.outletId,
        'customer_id': int.parse(id),
        'user_id': userC.currentUser.value?.id,
        'nomor_nota': nota,
        'total_tagihan': totalTagihan,
        'total_dibayar': 0,
        'status_pesanan': 'proses',
        'status_pembayaran': 'Belum Lunas',
        'tipe_logistik': logistikType,
        'delivery_fee': deliveryFee.value,
        'waktu_masuk': DateTime.now().toIso8601String(),
        'estimasi_selesai': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'alamat_layanan': isAntarJemput.value ? alamatCtrl.text : null,
        'catatan': catatan.isNotEmpty ? catatan : null,
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
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        middleText: "Transaksi $nota berhasil dibuat!",
        barrierDismissible: false,
        actions: [
          OutlinedButton(
            onPressed: () => Get.offAllNamed('/home'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Beranda", style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.showOverlay(
                asyncFunction: () async {
                  try {

                    final PesananController pesananC = Get.put(PesananController());
                    final detailData = await pesananC.fetchDetailPesanan(trxRes['id']);
                    if (detailData != null) {
                      Get.offAll(() => DetailPesananView(data: detailData));
                    } else {
                      Get.snackbar("Waduh", "Gagal ngambil detail pesanan nih");
                    }
                  } catch (e) {
                    Get.snackbar("Error", e.toString());
                  }
                },
                loadingWidget: const Center(child: CircularProgressIndicator()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Lihat Detail", style: TextStyle(color: Colors.white)),
          ),
        ],
      );

      cart.clear();
      catatanCtrl.clear();
      alamatCtrl.clear();
      deliveryFee.value = 0;
      isAntarJemput.value = false;
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e", backgroundColor: Colors.red, colorText: Colors.white);
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