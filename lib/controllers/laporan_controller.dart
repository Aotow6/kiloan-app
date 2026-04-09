import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class LaporanController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var selectedPeriode = "".obs;
  var listPeriode = <String>[].obs;
  
  var totalPemasukan = 0.obs;
  var totalPesanan = 0.obs; // 🔥 Kita ganti jadi Total Pesanan ya, Fan
  var isLoading = false.obs;

  final List<String> _namaBulan = [
    "", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];

  @override
  void onInit() {
    super.onInit();
    _generatePeriodeDinamis();
    if (userC.outletId != null) {
      prosesLaporan();
    }
  }

  // Bikin list bulan 1 tahun ke belakang (Contoh: April 2026)
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

  // 🔥 MESIN AKUNTANNYA DI SINI
  Future<void> prosesLaporan() async {
    if (userC.outletId == null) return;
    
    try {
      isLoading.value = true;
      
      // 1. Pecah teks "April 2026" jadi Angka
      List<String> parts = selectedPeriode.value.split(" ");
      String monthName = parts[0];
      int year = int.parse(parts[1]);
      int monthIndex = _namaBulan.indexOf(monthName);

      // 2. Tentukan Tanggal Awal & Akhir Bulan (Pakai UTC biar aman)
      DateTime startDate = DateTime(year, monthIndex, 1).toUtc();
      DateTime endDate = (monthIndex == 12) 
          ? DateTime(year + 1, 1, 1).toUtc() 
          : DateTime(year, monthIndex + 1, 1).toUtc();

      // 3. HITUNG TOTAL OMZET (Hanya yang berstatus 'Lunas')
      final trxLunas = await supabase
          .from('transactions')
          .select('total_tagihan')
          .eq('outlet_id', userC.outletId!)
          .eq('status_pembayaran', 'Lunas')
          .gte('waktu_masuk', startDate.toIso8601String())
          .lt('waktu_masuk', endDate.toIso8601String());

      int masuk = 0;
      for (var item in trxLunas) {
        masuk += (item['total_tagihan'] ?? 0) as int;
      }
      totalPemasukan.value = masuk;

      // 4. HITUNG TOTAL JUMLAH PESANAN (Semua Status)
      final allTrx = await supabase
          .from('transactions')
          .select('id')
          .eq('outlet_id', userC.outletId!)
          .gte('waktu_masuk', startDate.toIso8601String())
          .lt('waktu_masuk', endDate.toIso8601String());

      totalPesanan.value = allTrx.length;

    } catch (e) {
      print("Error Laporan: $e");
      Get.snackbar("Error", "Gagal memuat laporan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}