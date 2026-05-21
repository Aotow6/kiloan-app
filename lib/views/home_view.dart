import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 

import 'package:intl/intl.dart'; 

import '../controllers/home_controller.dart';
import '../controllers/pesanan_controller.dart';
import 'pesanan_view.dart';
import 'widgets/navbar.dart';
import 'laporan_view.dart';

class HomeView extends StatelessWidget {
  final HomeController homeC = Get.find<HomeController>();

  HomeView({super.key}) {
    homeC.refreshDashboard();
  }

  String formatRupiah(int angka) {
    return "Rp ${angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}";
  }

  @override
  Widget build(BuildContext context) {
    bool isKasir = homeC.userC.currentUser.value?.role?.toLowerCase() == 'kasir';

    String tanggalHariIni = DateFormat('dd MMM yyyy').format(DateTime.now());

    return WillPopScope(
      onWillPop: () async {
        if (homeC.bottomNavIndex.value != 0) {
          homeC.changeBottomNav(0);
          return false; 
        }
        return true; 
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        bottomNavigationBar: CustomBottomNav(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [

                        Image.asset(
                          'assets/images/app.png',
                          height: 36,
                          width: 36,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "kiloan",
                          style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)
                        ),
                      ],
                    ),

                    IconButton(
                      icon: FaIcon(
                        isKasir ? FontAwesomeIcons.userTie : FontAwesomeIcons.userGear, 
                        color: const Color(0xFF2196F3), 
                        size: 26
                      ),
                      onPressed: () {
                        Get.snackbar(
                          "Info Akun",
                          "Anda sedang login sebagai ${isKasir ? 'Kasir' : 'Owner'}.",
                          backgroundColor: Colors.white,
                          colorText: Colors.black87,
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hai, ${homeC.userC.currentUser.value?.namaLengkap ?? ''}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text("Selamat datang kembali", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100)
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFF2196F3), size: 18),
                          const SizedBox(height: 4),
                          Text(
                            tanggalHariIni, 
                            style: const TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (!isKasir)
                  Obx(() {
                    if (homeC.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Omzet Cashflow Hari Ini", style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(homeC.omzetHariIni.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                if (!isKasir) const SizedBox(height: 16),

                Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            if (!isKasir)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => homeC.isTabTransaksi.value = false,
                                  child: Column(
                                    children: [
                                      Text(
                                        "KEUANGAN",
                                        style: TextStyle(
                                          color: !homeC.isTabTransaksi.value
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (!homeC.isTabTransaksi.value)
                                        Container(height: 2, width: double.infinity, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => homeC.isTabTransaksi.value = true,
                                child: Column(
                                  children: [
                                    Text(
                                      isKasir ? "TINDAKAN CEPAT" : "TRANSAKSI",
                                      style: TextStyle(
                                        color: homeC.isTabTransaksi.value
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (homeC.isTabTransaksi.value)
                                      Container(height: 2, width: double.infinity, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      homeC.isTabTransaksi.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBlueCardItem(Icons.download, "${homeC.countMasukHariIni.value} Masuk", () async {
                                  Get.put(PesananController()).changeTab(0);
                                  homeC.changeBottomNav(1);
                                  await Get.to(() => PesananView());
                                  homeC.changeBottomNav(0); 
                                }),
                                _buildBlueCardItem(Icons.push_pin_outlined, "${homeC.countHarusSelesai.value} Deadline", () async {
                                  Get.put(PesananController()).changeTab(0); 

                                  homeC.changeBottomNav(1);
                                  await Get.to(() => PesananView());
                                  homeC.changeBottomNav(0); 
                                }),
                                _buildBlueCardItem(Icons.sync_problem, "${homeC.countTerlambat.value} Telat", () async {
                                  Get.put(PesananController()).changeTab(0); 

                                  homeC.changeBottomNav(1);
                                  await Get.to(() => PesananView());
                                  homeC.changeBottomNav(0); 
                                }),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBlueCardItem(
                                  Icons.money_off,
                                  formatRupiah(homeC.nominalPiutang.value),
                                  () {
                                    Get.snackbar(
                                      "Total Piutang Berjalan",
                                      "Ada ${homeC.countBelumLunas.value} pesanan yang belum lunas (Bukan Bon).",
                                      backgroundColor: Colors.white,
                                    );
                                  },
                                ),
                                _buildBlueCardItem(
                                  Icons.library_books,
                                  formatRupiah(homeC.totalKasbonSemuaPelanggan.value),
                                  () {
                                    Get.snackbar(
                                      "Total Kasbon",
                                      "Total seluruh hutang pelanggan yang tercatat di Bon.",
                                      backgroundColor: Colors.white,
                                    );
                                  },
                                ),
                                _buildBlueCardItem(
                                  Icons.account_balance_wallet,
                                  "Kas Tunai",
                                  () {
                                    homeC.changeBottomNav(2);
                                    Get.to(() => LaporanView()); 
                                    homeC.changeBottomNav(0); 
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                )),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pesananC = Get.put(PesananController());
                        pesananC.changeTab(0);
                        homeC.changeBottomNav(1);
                        await Get.to(() => PesananView());
                        homeC.changeBottomNav(0); 
                      },
                      child: _statusMenu(
                        icon: Icons.local_laundry_service,
                        label: "Diproses",
                        count: homeC.countProses,
                        color: Colors.blue.shade700,
                        bgColor: Colors.blue.shade50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pesananC = Get.put(PesananController());
                        pesananC.changeTab(1);
                        homeC.changeBottomNav(1);
                        await Get.to(() => PesananView());
                        homeC.changeBottomNav(0); 
                      },
                      child: _statusMenu(
                        icon: Icons.check_circle,
                        label: "Selesai",
                        count: homeC.countSelesai,
                        color: Colors.green.shade700,
                        bgColor: Colors.green.shade50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pesananC = Get.put(PesananController());
                        pesananC.changeTab(2);
                        homeC.changeBottomNav(1);
                        await Get.to(() => PesananView());
                        homeC.changeBottomNav(0); 
                      },
                      child: _statusMenu(
                        icon: Icons.inventory_2,
                        label: "Diambil",
                        count: homeC.countDiambil,
                        color: Colors.orange.shade700,
                        bgColor: Colors.orange.shade50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pesananC = Get.put(PesananController());
                        pesananC.changeTab(3);
                        homeC.changeBottomNav(1);
                        await Get.to(() => PesananView());
                        homeC.changeBottomNav(0); 
                      },
                      child: _statusMenu(
                        icon: Icons.cancel,
                        label: "Batal",
                        count: homeC.countBatal,
                        color: Colors.red.shade700,
                        bgColor: Colors.red.shade50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlueCardItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statusMenu({
    required IconData icon,
    required String label,
    required RxInt count,
    required Color color,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Obx(() => Text(
                      "${count.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}