import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'transaksi_controller.dart'; 
import 'pesanan_controller.dart'; 
import 'user_controller.dart';
import '../views/pilih_layanan_view.dart';

class DetailPesananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

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
      debugPrint("Error ambil detail: $e");
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
      } else if (status == 'selesai') { 
        await fetchDetailItems(id, catatanEditCtrl.text); 

        String noWa = headerData['customers']?['no_wa'] ?? '';
        String nama = headerData['customers']?['nama_pelanggan'] ?? '';
        if (noWa.isNotEmpty && noWa != "tanpa nomor") {
             String phone = noWa.replaceAll(RegExp(r'[^0-9]'), '');
             if (phone.startsWith('0')) phone = '62${phone.substring(1)}';
             String pesan = "Halo kak *$nama*,\nCucian dengan nota *${headerData['nomor_nota']}* sudah *SELESAI* dan siap diambil ya kak! Terima kasih. 💧";

             Get.snackbar("Berhasil", "Status Selesai. Silakan klik ikon WhatsApp untuk kirimi nota ke $nama", backgroundColor: Colors.blue, colorText: Colors.white, duration: const Duration(seconds: 4));
        } else {
             Get.snackbar("Berhasil", "Status diperbarui jadi SELESAI", backgroundColor: Colors.blue, colorText: Colors.white);      
        }
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

  Future<Uint8List> _generateNotaBytes(Map<String, dynamic> h) async {
    final pdf = pw.Document();

    String noNota = h['nomor_nota'] ?? "-";
    String namaPelanggan = h['customers']?['nama_pelanggan'] ?? "Pelanggan";
    String kasir = userC.currentUser.value?.namaLengkap ?? "Admin"; 

    String tglPesan = h['waktu_masuk'] != null ? DateFormat('dd-MM-yy HH:mm').format(DateTime.parse(h['waktu_masuk'])) : "-";
    String estSelesai = h['estimasi_selesai'] != null ? DateFormat('dd-MM-yy HH:mm').format(DateTime.parse(h['estimasi_selesai'])) : "-";
    int totalTagihan = h['total_tagihan'] ?? 0;
    int dibayar = h['total_dibayar'] ?? 0;
    int kembalian = dibayar - totalTagihan > 0 ? dibayar - totalTagihan : 0;
    String catatan = h['catatan'] ?? "-";

    String namaOutlet = "Laundry Outlet";
    String alamatOutlet = "Alamat tidak tersedia";
    try {
      if (userC.outletId != null && (userC.outletId ?? 0) > 0) {
        final outletData = await supabase.from('outlets').select('nama_outlet, alamat').eq('id', userC.outletId).single();
        namaOutlet = outletData['nama_outlet'] ?? "Laundry Outlet";
        alamatOutlet = outletData['alamat'] ?? "Alamat tidak tersedia";
      }
    } catch (e) {
      debugPrint("Gagal narik data outlet: $e");
    }

    int totalItemLayanan = listItems.length;
    double totalQty = 0;
    for (var item in listItems) {
      totalQty += double.tryParse(item['kuantitas'].toString()) ?? 0.0;
    }

    String formatRp(num val) {
      return val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, 
        margin: pw.EdgeInsets.zero, 

        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white, 

            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(namaOutlet, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(alamatOutlet, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                    ]
                  )
                ),
                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Order ID", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(noNota, style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Pelanggan", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(namaPelanggan, style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Kasir", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(kasir, style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Tgl Pesan", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(tglPesan, style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Est Selesai", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(estSelesai, style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                ...listItems.map((item) {
                  String namaLayanan = item['services']?['nama_layanan'] ?? 'Layanan';
                  String satuan = item['services']?['satuan'] ?? 'Pcs';
                  int hargaSatuan = item['services']?['harga'] ?? 0;
                  int subtotal = item['subtotal_harga'] ?? 0;
                  double qty = double.tryParse(item['kuantitas'].toString()) ?? 0;

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(namaLayanan, style: const pw.TextStyle(fontSize: 10)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1)} $satuan X ${formatRp(hargaSatuan)}", style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(formatRp(subtotal), style: const pw.TextStyle(fontSize: 10)),
                        ]
                      ),
                      pw.SizedBox(height: 4),
                    ]
                  );
                }),

                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total Tagihan", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(formatRp(totalTagihan), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Dibayar", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(formatRp(dibayar), style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Kembalian", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(formatRp(kembalian), style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),

                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                pw.Text("Item: ${totalQty.toStringAsFixed(totalQty.truncateToDouble() == totalQty ? 0 : 1)} ($totalItemLayanan Layanan)", style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text("Catatan: $catatan", style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 15),

                pw.Center(
                  child: pw.Text("Terima Kasih", style: const pw.TextStyle(fontSize: 10))
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text("Powered by kiloan", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))
                ),
              ],
            )
          );
        },
      ),
    );

    return pdf.save(); 
  }

  Future<void> cetakNotaPDF(Map<String, dynamic> h) async {
    try {
      isLoading.value = true;

      final bytes = await _generateNotaBytes(h);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Nota_${h['nomor_nota']}',
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal mencetak nota: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> kirimNotaWA({required Map<String, dynamic> transaksi, required String namaCustomer, required String noWa}) async {
    if (noWa.isEmpty || noWa.toLowerCase() == "tanpa nomor") {
      Get.snackbar("Gagal", "Pelanggan ini tidak memiliki nomor WhatsApp", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      String statusP = transaksi['status_pesanan'].toString().toLowerCase();
      String nota = transaksi['nomor_nota'] ?? "-";
      StringBuffer pesan = StringBuffer();

      if (statusP == 'proses') {
        pesan.writeln("*NOTA LAUNDRY* 💧\n-----------------------------------");
        pesan.writeln("Halo kak *$namaCustomer*,\nBerikut adalah nota pesanan cucian kakak:\n");
        pesan.writeln("⏳ *Status Pesanan:* PROSES");
        pesan.writeln("💳 *Status Bayar:* ${transaksi['status_pembayaran']}\n");
        pesan.writeln("💰 *TOTAL TAGIHAN: Rp ${transaksi['total_tagihan']}*");
        pesan.writeln("\nCucian kakak akan segera kami selesaikan. Terima kasih! 🙏");
      } else if (statusP == 'selesai') {
        pesan.writeln("*INFO LAUNDRY* 💧\n-----------------------------------");
        pesan.writeln("Halo kak *$namaCustomer*,\nKabar gembira! Cucian kakak dengan nota *$nota* sudah *SELESAI* diproses dan *SIAP DIAMBIL* ya kak.");
        if (transaksi['status_pembayaran'].toString().toLowerCase() != 'lunas') {
          pesan.writeln("\nTotal tagihan kakak: *Rp ${transaksi['total_tagihan']}* (${transaksi['status_pembayaran']})");
        }
        pesan.writeln("\nDitunggu kedatangannya. Terima kasih! 🙏");
      } else if (statusP == 'diambil') {
        pesan.writeln("*TERIMA KASIH* 💧\n-----------------------------------");
        pesan.writeln("Halo kak *$namaCustomer*,\nCucian dengan nota *$nota* sudah diambil. Terima kasih telah mempercayakan laundry pakaian kakak kepada kami. Kami tunggu kedatangannya kembali! 🙏");
      } else if (statusP == 'batal') {
        pesan.writeln("*PEMBATALAN PESANAN* 💧\n-----------------------------------");
        pesan.writeln("Mohon maaf kak *$namaCustomer*,\nCucian dengan nota *$nota* telah *DIBATALKAN*. Jika ada pertanyaan, silakan hubungi kami. 🙏");
      }

      final pdfBytes = await _generateNotaBytes(transaksi);
      final raster = await Printing.raster(pdfBytes, pages: [0], dpi: 200).first;
      final imageBytes = await raster.toPng();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Nota_$nota.png');
      await file.writeAsBytes(imageBytes);

      String phone = noWa.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.startsWith('0')) phone = '62${phone.substring(1)}';

      await Clipboard.setData(ClipboardData(text: phone)); 

      Get.snackbar(
        "Trik Cepat!", 
        "Nomor HP $phone berhasil dicopy. Tinggal PASTE di pencarian kontak WhatsApp!", 
        backgroundColor: Colors.blue.shade800, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );

      await Future.delayed(const Duration(milliseconds: 800));

      await Share.shareXFiles(
        [XFile(file.path)],
        text: pesan.toString(), 

      );

    } catch (e) {
      Get.snackbar("Error", "Gagal menyiapkan nota WA: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}