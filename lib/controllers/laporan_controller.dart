import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/controllers/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import 'user_controller.dart';

class LaporanController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();
  final LocalAuthentication auth = LocalAuthentication();

  var selectedPeriode = "".obs;
  var listPeriode = <String>[].obs;

  var totalPemasukan = 0.obs;
  var totalPesanan = 0.obs;
  var totalPiutang = 0.obs;

  var isLoading = false.obs;

  final List<String> _namaBulan = [
    "", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  @override
  void onInit() {
    super.onInit();
    _generatePeriodeDinamis();
  }

  @override
  void onReady() {
    super.onReady();
    if (userC.outletId != null) {
      prosesLaporan();
    }
  }

  void _generatePeriodeDinamis() {
    DateTime now = DateTime.now();
    List<String> tempPeriode = [];
    for (int i = 0; i < 12; i++) {
      int month = now.month - i;
      int year = now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      tempPeriode.add("${_namaBulan[month]} $year");
    }
    listPeriode.value = tempPeriode;
    selectedPeriode.value = tempPeriode.first;
  }

  void ubahPeriode(String bulan) {
    selectedPeriode.value = bulan;
    Get.back();
    prosesLaporan();
  }

  Future<void> prosesLaporan() async {
    if (userC.outletId == null) return;

    try {
      isLoading.value = true;

      List<String> parts = selectedPeriode.value.split(" ");
      String monthName = parts[0];
      int year = int.parse(parts[1]);
      int monthIndex = _namaBulan.indexOf(monthName);

      DateTime startDateLocal = DateTime(year, monthIndex, 1, 0, 0, 0);
      DateTime endDateLocal = (monthIndex == 12)
          ? DateTime(year + 1, 1, 1, 23, 59, 59).subtract(const Duration(days: 1))
          : DateTime(year, monthIndex + 1, 1, 23, 59, 59).subtract(const Duration(days: 1));

      final cashflowBulanan = await supabase
          .from('cashflows')
          .select('nominal, tipe_arus, waktu_catat, transactions(status_pesanan)')
          .eq('outlet_id', userC.outletId!);

      int masuk = 0;

      for (var item in cashflowBulanan) {
         if (item['waktu_catat'] != null) {
            DateTime tglCatat = DateTime.parse(item['waktu_catat'].toString()).toLocal();
            if (tglCatat.isAfter(startDateLocal) && tglCatat.isBefore(endDateLocal)) {

                bool isBatal = item['transactions'] != null && item['transactions']['status_pesanan']?.toString().toLowerCase() == 'batal';

                if (!isBatal && item['tipe_arus'].toString().toLowerCase() == 'pemasukan') {
                   masuk += (item['nominal'] ?? 0) as int;
                }
            }
         }
      }
      totalPemasukan.value = masuk;

      final allTrx = await supabase
          .from('transactions')
          .select('id, total_tagihan, total_dibayar, status_pembayaran, waktu_masuk, status_pesanan')
          .eq('outlet_id', userC.outletId!);

      int pesanan = 0;
      int piutangBulanIni = 0;

      for (var trx in allTrx) {
         if (trx['waktu_masuk'] != null) {
            DateTime tglTrx = DateTime.parse(trx['waktu_masuk'].toString()).toLocal();
            if (tglTrx.isAfter(startDateLocal) && tglTrx.isBefore(endDateLocal)) {

                String statusBayar = (trx['status_pembayaran'] ?? '').toString();
                String statusPesanan = (trx['status_pesanan'] ?? '').toString().toLowerCase();

                if (statusPesanan != 'batal') {
                   pesanan++;
                }

                if (statusBayar != 'Lunas' && statusPesanan != 'batal') {
                   int tagihan = (trx['total_tagihan'] ?? 0) as int;
                   int dibayar = (trx['total_dibayar'] ?? 0) as int;
                   piutangBulanIni += (tagihan - dibayar);
                }
            }
         }
      }

      totalPesanan.value = pesanan;
      totalPiutang.value = piutangBulanIni;

    } catch (e) {
      debugPrint("Error Laporan: ");
      ErrorHandler.show(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) return true;

      return await auth.authenticate(
        localizedReason: 'Verifikasi identitas untuk mencetak laporan',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Error Biometric: $e");
      return false;
    }
  }

  Future<void> cetakLaporanPDF() async {
    bool isAuthorized = await _authenticateUser();
    if (!isAuthorized) {
      HapticFeedback.heavyImpact();
      Get.snackbar("Akses Ditolak", "Gagal memverifikasi identitas. Laporan tidak dapat dicetak.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      List<String> parts = selectedPeriode.value.split(" ");
      int year = int.parse(parts[1]);
      int monthIndex = _namaBulan.indexOf(parts[0]);
      DateTime startDateLocal = DateTime(year, monthIndex, 1, 0, 0, 0);
      DateTime endDateLocal = (monthIndex == 12)
          ? DateTime(year + 1, 1, 1, 23, 59, 59).subtract(const Duration(days: 1))
          : DateTime(year, monthIndex + 1, 1, 23, 59, 59).subtract(const Duration(days: 1));

      final rawCashflow = await supabase
          .from('cashflows')
          .select('nominal, keterangan, metode_bayar, waktu_catat, transactions(status_pesanan)')
          .eq('outlet_id', userC.outletId)
          .eq('tipe_arus', 'Pemasukan')
          .order('waktu_catat', ascending: true);

      List<Map<String, dynamic>> riwayatPemasukan = [];
      for(var row in rawCashflow) {
         if (row['waktu_catat'] != null) {
            DateTime tglCatat = DateTime.parse(row['waktu_catat'].toString()).toLocal();
            if (tglCatat.isAfter(startDateLocal) && tglCatat.isBefore(endDateLocal)) {

                bool isBatal = row['transactions'] != null && row['transactions']['status_pesanan']?.toString().toLowerCase() == 'batal';

                if (!isBatal) {
                    riwayatPemasukan.add({
                       'tanggal': DateFormat('dd/MM/yyyy HH:mm').format(tglCatat),
                       'nominal': row['nominal'] ?? 0,
                       'keterangan': row['keterangan'] ?? '-',
                       'metode': row['metode_bayar'] ?? 'Tunai',
                    });
                }
            }
         }
      }

      final pdf = pw.Document();
      String formatRp(int amount) {
        return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
      }

      String namaOutlet = "Kiloan Outlet";
      if (userC.outletId != null) {
         final o = await supabase.from('outlets').select('nama_outlet').eq('id', userC.outletId!).maybeSingle();
         if (o != null) namaOutlet = o['nama_outlet'];
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text("LAPORAN KINERJA & ARUS KAS", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(namaOutlet.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text("Periode: ${selectedPeriode.value}", style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 16),

              pw.Text("A. RINGKASAN EKSEKUTIF", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Total Pesanan Layanan (Masuk):"),
                        pw.Text("${totalPesanan.value} Transaksi", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ]
                    ),
                    pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Pendapatan Kas (Uang Beredar):"),
                        pw.Text(formatRp(totalPemasukan.value), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ]
                    ),
                    pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey300),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Piutang Mengendap (Estimasi Kasbon Baru):"),
                        pw.Text(formatRp(totalPiutang.value), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                      ]
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 24),

              pw.Text("B. BUKU KAS (RINCIAN PEMASUKAN)", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),

              if (riwayatPemasukan.isEmpty)
                pw.Center(child: pw.Text("Tidak ada transaksi pemasukan pada periode ini.", style: const pw.TextStyle(color: PdfColors.grey600)))
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  headerAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellPadding: const pw.EdgeInsets.all(6),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  headers: ['Tanggal & Waktu', 'Keterangan', 'Metode', 'Nominal (Rp)'],
                  data: riwayatPemasukan.map((item) {
                    return [
                      item['tanggal'],
                      item['keterangan'],
                      item['metode'],
                      formatRp(item['nominal'] as int),
                    ];
                  }).toList(),
                ),

              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text("Indonesia, ${DateFormat('dd MMMM yyyy').format(DateTime.now())}"),
                    pw.SizedBox(height: 50),
                    pw.Text(userC.currentUser.value?.namaLengkap ?? "Admin", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Manajer / Admin Outlet", style: const pw.TextStyle(fontSize: 10)),
                  ]
                )
              )
            ];
          }
        )
      );

      final bytes = await pdf.save();
      String safeOutletName = namaOutlet.replaceAll(' ', '_');
      String safePeriode = selectedPeriode.value.replaceAll(' ', '_');
      String fileName = 'Laporan_Kinerja_${safeOutletName}_$safePeriode.pdf';

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      HapticFeedback.mediumImpact();
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Kinerja $namaOutlet - Periode $safePeriode'
      );

    } catch (e) {
       ErrorHandler.show(e);
    } finally {
       isLoading.value = false;
    }
  }
}