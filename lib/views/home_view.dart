import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/pesanan_controller.dart';
import 'pesanan_view.dart';
import 'widgets/navbar.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController homeC = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: false,
      bottomNavigationBar: CustomBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop, color: Color(0xFF2196F3)),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "kiloan",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF102A43)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF2196F3), size: 28),
                    onPressed: () {
                      Get.snackbar(
                        "Notifikasi",
                        "Belum ada pemberitahuan baru hari ini.",
                        backgroundColor: Colors.white,
                        colorText: Colors.black87,
                        icon: const Icon(Icons.notifications_active, color: Colors.blue),
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hai,", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text("Selamat datang kembali", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const Icon(Icons.qr_code_scanner, color: Color(0xFF2196F3), size: 36),
                ],
              ),

              const SizedBox(height: 24),

              Obx(() {
                if (homeC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                String formatRupiah(int angka) {
                  return "Rp ${angka.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}";
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
                      const Text("Omzet Hari Ini", style: TextStyle(color: Colors.white70)),
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

              const SizedBox(height: 16),

              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeC.isTabTransaksi.value = false,
                              child: Container(
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Text("KEUANGAN", style: TextStyle(color: !homeC.isTabTransaksi.value ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    if (!homeC.isTabTransaksi.value) Container(height: 2, width: double.infinity, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeC.isTabTransaksi.value = true,
                              child: Container(
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Text("TRANSAKSI", style: TextStyle(color: homeC.isTabTransaksi.value ? Colors.white : Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    if (homeC.isTabTransaksi.value) Container(height: 2, width: double.infinity, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -2),
                      child: Container(height: 1, width: double.infinity, color: Colors.white.withOpacity(0.2)),
                    ),
                    const SizedBox(height: 24),
                    homeC.isTabTransaksi.value 
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBlueCardItem(Icons.download, "${homeC.countMasukHariIni.value} Masuk", () {
                            Get.put(PesananController()).changeTab(0);
                            homeC.changeBottomNav(1);
                            Get.to(() => PesananView());
                          }),
                          _buildBlueCardItem(Icons.push_pin_outlined, "${homeC.countHarusSelesai.value} Harus Selesai", () {
                            Get.snackbar("Harus Selesai", "Ini daftar pesanan yang deadline hari ini.", backgroundColor: Colors.white);
                          }),
                          _buildBlueCardItem(Icons.sync, "${homeC.countTerlambat.value} Terlambat", () {
                            Get.snackbar("Terlambat", "Pesanan ini belum selesai walau sudah lewat deadline!", backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                          }),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBlueCardItem(Icons.payments_outlined, "${homeC.countBelumLunas.value} Belum Lunas", () {
                            Get.snackbar("Piutang", "Ada ${homeC.countBelumLunas.value} pesanan yang belum dibayar pelanggan.", backgroundColor: Colors.orange.shade100);
                          }),
                          _buildBlueCardItem(Icons.account_balance_wallet, "Kas Tunai", () {
                            Get.snackbar("Info", "Lihat rekap selengkapnya di menu Laporan.", backgroundColor: Colors.white);
                          }),
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
                    onTap: () {
                      final pesananC = Get.put(PesananController());
                      pesananC.changeTab(0);
                      homeC.changeBottomNav(1);
                      Get.to(() => PesananView());
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
                    onTap: () {
                      final pesananC = Get.put(PesananController());
                      pesananC.changeTab(1);
                      homeC.changeBottomNav(1);
                      Get.to(() => PesananView());
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
                    onTap: () {
                      final pesananC = Get.put(PesananController());
                      pesananC.changeTab(2);
                      homeC.changeBottomNav(1);
                      Get.to(() => PesananView());
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
                    onTap: () {
                      final pesananC = Get.put(PesananController());
                      pesananC.changeTab(3);
                      homeC.changeBottomNav(1);
                      Get.to(() => PesananView());
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
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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