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

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  void changeTab(int index) => activeTab.value = index;
  void changeBottomNav(int index) => bottomNavIndex.value = index;

  Future<void> refreshDashboard() async {
    try {
      isLoading.value = true;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();

      final trxLunas = await supabase
          .from('transactions')
          .select('total_tagihan')
          .eq('outlet_id', userC.outletId)
          .eq('status_pembayaran', 'Lunas')
          .gte('waktu_masuk', startOfDay);
      
      int totalCash = 0;
      for (var item in trxLunas) {
        totalCash += (item['total_tagihan'] ?? 0) as int;
      }
      omzetHariIni.value = totalCash;

      final allTrx = await supabase
          .from('transactions')
          .select()
          .eq('outlet_id', userC.outletId);
      
      int cProses = 0, cSelesai = 0, cDiambil = 0, cBatal = 0;
      int cMasuk = 0, cHarusSelesai = 0, cTerlambat = 0, cBelumLunas = 0;
      
      for (var item in allTrx) {
        String status = (item['status_pesanan'] ?? '').toString().toLowerCase();
        String statusBayar = (item['status_pembayaran'] ?? '').toString();
        
        if (status == 'proses') cProses++;
        else if (status == 'selesai') cSelesai++;
        else if (status == 'diambil') cDiambil++;
        else if (status == 'batal') cBatal++;

        if (statusBayar == 'Belum Lunas' && status != 'batal') cBelumLunas++;

        if (item['waktu_masuk'] != null) {
          DateTime waktuMasuk = DateTime.parse(item['waktu_masuk'].toString()).toLocal();
          if (waktuMasuk.year == today.year && waktuMasuk.month == today.month && waktuMasuk.day == today.day) {
            cMasuk++;
          }
        }

        if (item['estimasi_selesai'] != null && status == 'proses') {
          DateTime estimasi = DateTime.parse(item['estimasi_selesai'].toString()).toLocal();
          
          DateTime dateOnlyEstimasi = DateTime(estimasi.year, estimasi.month, estimasi.day);
          DateTime dateOnlyToday = DateTime(today.year, today.month, today.day);

          if (dateOnlyEstimasi.isBefore(dateOnlyToday)) {
            cTerlambat++;
          } else if (dateOnlyEstimasi.isAtSameMomentAs(dateOnlyToday)) {
            cHarusSelesai++;
          }
        }
      }

      countProses.value = cProses;
      countSelesai.value = cSelesai;
      countDiambil.value = cDiambil;
      countBatal.value = cBatal;
      pesananAktif.value = cProses + cSelesai;

      countMasukHariIni.value = cMasuk;
      countHarusSelesai.value = cHarusSelesai;
      countTerlambat.value = cTerlambat;
      countBelumLunas.value = cBelumLunas;

      final custBaru = await supabase
          .from('customers')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .gte('created_at', startOfDay);
      
      pelangganBaru.value = custBaru.length;

    } catch (e) {
      print("Error ambil data Dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }
}