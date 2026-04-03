import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/pesanan_controller.dart';
import 'detail_pesanan_view.dart';
import 'widgets/navbar.dart';

class PesananView extends StatelessWidget {
  PesananView({super.key});

  final PesananController pesananC = Get.put(PesananController());
  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.changeBottomNav(1); 
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: false,

      bottomNavigationBar: CustomBottomNav(),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 28),
                          const SizedBox(width: 8),
                          const Text("kiloan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.search, color: Color(0xFF2196F3), size: 28),
                          SizedBox(width: 16),
                          Icon(Icons.history, color: Color(0xFF2196F3), size: 28),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Hai, ", style: TextStyle(fontSize: 18, color: Color(0xFF102A43), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text("Ini status orderan kamu", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              height: 50,
              child: Obx(() {
                int activeIndex = pesananC.selectedTab.value; 
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pesananC.tabs.length,
                  itemBuilder: (context, index) {
                    bool isActive = activeIndex == index;
                    return GestureDetector(
                      onTap: () => pesananC.changeTab(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isActive ? const Color(0xFF2196F3) : Colors.transparent, width: 3)),
                        ),
                        child: Center(
                          child: Text(
                            pesananC.tabs[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? const Color(0xFF2196F3) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            Expanded(
              child: Obx(() {
                if (pesananC.selectedTab.value == 0) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _orderCard(),
                    ],
                  );
                } else {
                  return _emptyState();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard() {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailPesananView());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TRX/260402/003", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(20)),
                  child: const Text("Belum Lunas", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade100)),
                  child: const Icon(Icons.checkroom, color: Color(0xFF2196F3), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ggg", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tanggal Pesan", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const Text("02/04/2026 11:28", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Estimasi Selesai", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const Text("02/04/2026 19:28", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text("Belum ada data", style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 80), 
      ],
    );
  }
}