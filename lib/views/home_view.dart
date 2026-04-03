import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
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
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 40.0), 
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
                  const Icon(Icons.notifications_none, color: Color(0xFF2196F3), size: 28),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hai, ", 
                        style: TextStyle(fontSize: 18, color: Color(0xFF102A43), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selamat datang kembali",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const Icon(Icons.qr_code_scanner, color: Color(0xFF2196F3), size: 36),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => homeC.changeTab(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: homeC.activeTab.value == 0 ? Colors.white : Colors.transparent, width: 3)),
                              ),
                              child: Center(child: Text("KEUANGAN", style: TextStyle(color: homeC.activeTab.value == 0 ? Colors.white : Colors.white70, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => homeC.changeTab(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: homeC.activeTab.value == 1 ? Colors.white : Colors.transparent, width: 3)),
                              ),
                              child: Center(child: Text("TRANSAKSI", style: TextStyle(color: homeC.activeTab.value == 1 ? Colors.white : Colors.white70, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                      ],
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Obx(() {
                        if (homeC.activeTab.value == 1) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _cardItem(icon: Icons.download_outlined, count: "2", label: "Masuk"),
                              _cardItem(icon: Icons.push_pin_outlined, count: "0", label: "Harus Selesai"),
                              _cardItem(icon: Icons.sync_problem, count: "0", label: "Terlambat"),
                            ],
                          );
                        } else {
                          return const Center(child: Text("Data Keuangan Belum Tersedia", style: TextStyle(color: Colors.white)));
                        }
                      }),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusMenu(icon: Icons.local_laundry_service, label: "Diproses", count: "0", color: Colors.blue.shade700, bgColor: Colors.blue.shade50),
                  _statusMenu(icon: Icons.check_circle, label: "Selesai", count: "0", color: Colors.green.shade700, bgColor: Colors.green.shade50),
                  _statusMenu(icon: Icons.inventory_2, label: "Diambil", count: "0", color: Colors.orange.shade700, bgColor: Colors.orange.shade50),
                  _statusMenu(icon: Icons.cancel, label: "Batal", count: "0", color: Colors.red.shade700, bgColor: Colors.red.shade50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardItem({required IconData icon, required String count, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text("$count $label", style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _statusMenu({required IconData icon, required String label, required String count, required Color color, required Color bgColor}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, size: 30, color: color)),
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFFF9800), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF102A43))),
      ],
    );
  }
}