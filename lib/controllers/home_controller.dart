import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var activeTab = 1.obs; 
  var bottomNavIndex = 0.obs;

  var isTabTransaksi = true.obs;

  var omzetHariIni = 0.obs;
  var pesananAktif = 0.obs;
  var pelangganBaru = 0.obs;
  var isLoading = false.obs;

  var countProses = 0.obs;
  var countSelesai = 0.obs;
  var countDiambil = 0.obs;
  var countBatal = 0.obs;

  var countMasukHariIni = 0.obs;
  var countHarusSelesai = 0.obs; 

  var countTerlambat = 0.obs;    

  var countBelumLunas = 0.obs;
  var nominalPiutang = 0.obs;
  var totalKasbonSemuaPelanggan = 0.obs; 

  @override
  void onInit() {
    super.onInit();
    if (userC.currentUser.value?.role?.toLowerCase() == 'kasir') {
       isTabTransaksi.value = true;
    }
  }

  void changeTab(int index) => activeTab.value = index;

  void changeBottomNav(int index) {
    bottomNavIndex.value = index;
    if (index == 0) {
      refreshDashboard(); 
    }
  }

  Future<void> refreshDashboard() async {

    if (userC.outletId == null) return;

    try {
      isLoading.value = true;

      final now = DateTime.now();
      final startOfDayLocal = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDayLocal = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final cashflowData = await supabase
          .from('cashflows') 
          .select('nominal, tipe_arus, waktu_catat') 
          .eq('outlet_id', userC.outletId); 

      int totalOmzet = 0;
      for (var item in cashflowData) {
        if (item['waktu_catat'] != null && item['tipe_arus']?.toString().toLowerCase() == 'pemasukan') {
          DateTime tglCatat = DateTime.parse(item['waktu_catat'].toString()).toLocal();
          if (tglCatat.isAfter(startOfDayLocal) && tglCatat.isBefore(endOfDayLocal)) {
             totalOmzet += (item['nominal'] ?? 0) as int;
          }
        }
      }
      omzetHariIni.value = totalOmzet;

      final allCustomers = await supabase
          .from('customers')
          .select('total_kasbon')
          .eq('outlet_id', userC.outletId);

      int totalBon = 0;
      for (var c in allCustomers) {
          totalBon += (c['total_kasbon'] ?? 0) as int;
      }
      totalKasbonSemuaPelanggan.value = totalBon;

      final allTrx = await supabase
          .from('transactions')
          .select()
          .eq('outlet_id', userC.outletId);

      int cProses = 0, cSelesai = 0, cDiambil = 0, cBatal = 0;
      int cMasuk = 0, cDeadline = 0, cTelat = 0, cBelumLunas = 0;
      int totalUtang = 0;

      for (var item in allTrx) {
        String status = (item['status_pesanan'] ?? '').toString().toLowerCase();
        String statusBayar = (item['status_pembayaran'] ?? '').toString();

        if (status == 'proses') {
            cProses++;

            if (item['estimasi_selesai'] != null) {
              DateTime estimasi = DateTime.parse(item['estimasi_selesai'].toString()).toLocal();
              if (estimasi.isBefore(now)) {
                cTelat++; 

              } else {
                cDeadline++; 

              }
            }
        }
        else if (status == 'selesai') cSelesai++;
        else if (status == 'diambil') cDiambil++;
        else if (status == 'batal') cBatal++;

        if (statusBayar != 'Lunas' && status != 'batal' && statusBayar != 'Bon') {
          cBelumLunas++;
          int tagihan = (item['total_tagihan'] ?? 0) as int;
          int dibayar = (item['total_dibayar'] ?? 0) as int;
          totalUtang += (tagihan - dibayar);
        }

        if (item['waktu_masuk'] != null) {
          DateTime waktuMasuk = DateTime.parse(item['waktu_masuk'].toString()).toLocal();
          if (waktuMasuk.isAfter(startOfDayLocal) && waktuMasuk.isBefore(endOfDayLocal)) {
            cMasuk++;
          }
        }
      }

      countProses.value = cProses;
      countSelesai.value = cSelesai;
      countDiambil.value = cDiambil;
      countBatal.value = cBatal;
      pesananAktif.value = cProses + cSelesai;

      countMasukHariIni.value = cMasuk;
      countHarusSelesai.value = cDeadline; 
      countTerlambat.value = cTelat;

      countBelumLunas.value = cBelumLunas;
      nominalPiutang.value = totalUtang;

      final custBaru = await supabase
          .from('customers')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .gte('created_at', startOfDayLocal.toUtc().toIso8601String());

      pelangganBaru.value = custBaru.length;

    } catch (e) {
      debugPrint("Error Refresh: $e"); 
    } finally {
      isLoading.value = false;
    }
  }
}