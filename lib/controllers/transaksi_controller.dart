import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundry_app/services/sensor_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'user_controller.dart';
import 'layanan_controller.dart';
import 'pesanan_controller.dart';
import '../views/detail_pesanan_view.dart';
import '../views/pesanan_view.dart';

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
  var isListening = false.obs;
  late stt.SpeechToText _speech;
  var isEditMode = false.obs;
  var idTransaksiEdit = 0.obs;

  var fotoBukti = Rxn<XFile>();

  final alamatCtrl = TextEditingController();
  final catatanCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _speech = stt.SpeechToText();
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Atur Ongkos Kirim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF102A43))),
              const SizedBox(height: 20),
              TextField(
                controller: ongkirCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyFormat()],
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                  hintText: "Contoh: 5.000",
                  hintStyle: TextStyle(color: Colors.grey.shade400)
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    deliveryFee.value = int.tryParse(ongkirCtrl.text.replaceAll('.', '')) ?? 0;
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Future<void> ambilFotoBaju() async {
    final sensorS = Get.find<SensorService>();
    final foto = await sensorS.ambilFoto();
    if (foto != null) {
      fotoBukti.value = foto;
    }
  }

  Future<void> tarikAlamatPelanggan(String idCustomer) async {
    if (idCustomer.isEmpty || idCustomer == "0") return;

    try {
      final data = await supabase
          .from('customers')
          .select('alamat')
          .eq('id', int.parse(idCustomer))
          .maybeSingle();

      if (data != null && data['alamat'] != null) {
        alamatCtrl.text = data['alamat'].toString();
      }
    } catch (e) {
      debugPrint("Gagal mengambil alamat pelanggan: $e");
    }
  }

  Future<void> buatTransaksi(String id, String nama, String phone) async {
    if (cart.isEmpty) {
      HapticFeedback.heavyImpact();
      Get.snackbar("Error", "Pesanan tidak boleh kosong!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    String logistikType = 'none';

    if (isAntarJemput.value) {
      String alamat = alamatCtrl.text.trim();

      if (alamat.isEmpty) {
        HapticFeedback.heavyImpact();
        Get.snackbar("Error", "Alamat antar jemput wajib diisi!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (hasEmoji(alamat)) {
        HapticFeedback.heavyImpact();
        Get.snackbar("Error", "Alamat tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (alamat.length < 5) {
        HapticFeedback.heavyImpact();
        Get.snackbar("Error", "Alamat terlalu pendek! Minimal 5 karakter.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (!isPenjemputan.value && !isPengantaran.value) {
        HapticFeedback.heavyImpact();
        Get.snackbar("Error", "Pilih minimal satu: Penjemputan atau Pengantaran!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (deliveryFee.value <= 0) {
        HapticFeedback.heavyImpact();
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
      HapticFeedback.heavyImpact();
      Get.snackbar("Error", "Catatan tidak boleh mengandung emoji!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      String? urlFotoBukti;
      if (fotoBukti.value != null) {
        try {
          final file = File(fotoBukti.value!.path);
          final fileExt = fotoBukti.value!.path.split('.').last;
          final fileName = 'nota_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

          await supabase.storage.from('foto_baju').upload(fileName, file);

          urlFotoBukti = supabase.storage.from('foto_baju').getPublicUrl(fileName);
        } catch (e) {
          debugPrint("Gagal upload foto ke Bucket: $e");
        }
      }

      if (isEditMode.value) {
        int trkId = idTransaksiEdit.value;

        final Map<String, dynamic> updateData = {
          'total_tagihan': totalTagihan,
          'tipe_logistik': logistikType,
          'delivery_fee': deliveryFee.value,
          'alamat_layanan': isAntarJemput.value ? alamatCtrl.text : null,
          'catatan': catatan.isNotEmpty ? catatan : null,
        };

        if (urlFotoBukti != null) {
          updateData['foto_bukti'] = urlFotoBukti;
        }

        await supabase.from('transactions').update(updateData).eq('id', trkId);

        await supabase.from('transaction_details').delete().eq('transaction_id', trkId);

        final List<Map<String, dynamic>> details = cart.map((item) => {
              'transaction_id': trkId,
              'service_id': item['service_id'],
              'kuantitas': item['kuantitas'],
              'subtotal_harga': item['subtotal_harga'],
            }).toList();
        await supabase.from('transaction_details').insert(details);

        isEditMode.value = false;
        idTransaksiEdit.value = 0;

        HapticFeedback.mediumImpact();
        Get.back(result: true);

        Get.snackbar("Sukses", "Transaksi berhasil diperbarui!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
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
          'foto_bukti': urlFotoBukti,
        }).select().single();

        final List<Map<String, dynamic>> details = cart.map((item) => {
              'transaction_id': trxRes['id'],
              'service_id': item['service_id'],
              'kuantitas': item['kuantitas'],
              'subtotal_harga': item['subtotal_harga'],
            }).toList();

        await supabase.from('transaction_details').insert(details);

        HapticFeedback.mediumImpact();

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
                Get.back();

                Get.showOverlay(
                  asyncFunction: () async {
                    try {
                      final PesananController pesananC = Get.put(PesananController());
                      final detailData = await pesananC.fetchDetailPesanan(trxRes['id']);
                      if (detailData != null) {
                        Get.offAll(() => const PesananView());
                        await Future.delayed(const Duration(milliseconds: 300));
                        Get.to(() => DetailPesananView(data: detailData));
                      } else {
                        Get.snackbar("Waduh", "Gagal ngambil detail pesanan nih");
                      }
                    } catch (e) {
                      Get.snackbar("Error", "Terjadi kesalahan");
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
      }

      cart.clear();
      catatanCtrl.clear();
      alamatCtrl.clear();
      deliveryFee.value = 0;
      isAntarJemput.value = false;
      fotoBukti.value = null;

    } catch (e) {
      HapticFeedback.vibrate();
      Get.snackbar("Gagal", "Terjadi kesalahan: ", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMic() async {
  if (isListening.value) {
    isListening.value = false;
    await _speech.stop();
    HapticFeedback.lightImpact();
    return;
  }

  bool available = await _speech.initialize(
    onStatus: (val) {
      if (val == 'done' || val == 'notListening') {
        isListening.value = false;
        _speech.stop();
      }
    },
    onError: (val) {
      isListening.value = false;
      _speech.stop();
    },
  );

  if (available) {
    isListening.value = true;
    HapticFeedback.lightImpact();

    final String existingText = catatanCtrl.text.trimRight();
    final String prefix = existingText.isEmpty ? '' : '$existingText ';

    _speech.listen(
      localeId: 'id_ID',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (val) {
        catatanCtrl.value = TextEditingValue(
          text: prefix + val.recognizedWords,
          selection: TextSelection.collapsed(
            offset: (prefix + val.recognizedWords).length,
          ),
        );
      },
    );
  } else {
    Get.snackbar(
      "Izin Ditolak",
      "Aplikasi tidak mendapat izin Microphone.",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}

void clearAll() {
  cart.clear();
  catatanCtrl.clear();
  alamatCtrl.clear();
  deliveryFee.value = 0;
  isAntarJemput.value = false;
  isPenjemputan.value = true;
  isPengantaran.value = true;
  fotoBukti.value = null;
  isListening.value = false;
  if (_speech.isListening) _speech.stop();
}

  @override

  void onClose() {
      if (isListening.value) _speech.stop();
    catatanCtrl.dispose();
    alamatCtrl.dispose();
    super.onClose();
  }
}