import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/home_view.dart';
import 'package:laundry_app/views/laporan_view.dart';
import 'package:laundry_app/views/pengaturan_view.dart';
import '../../controllers/home_controller.dart';
import '../pesanan_view.dart';
import '../cari_pelanggan_view.dart';
import '../tambah_pelanggan_view.dart';

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, -3))],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bottomNavItem(icon: Icons.home_filled, label: "Beranda", index: 0),
              _bottomNavItem(icon: Icons.receipt_long, label: "Pesanan", index: 1),

              GestureDetector(
                onTap: () => _showTransactionBottomSheet(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.add, size: 36, color: Colors.white),
                ),
              ),

              _bottomNavItem(icon: Icons.insert_chart, label: "Laporan", index: 2),
              _bottomNavItem(icon: Icons.person, label: "Pengaturan", index: 3),
            ],
          )
        ],
      ),
    );
  }

  Widget _bottomNavItem({required IconData icon, required String label, required int index}) {
    return Expanded(
      child: InkWell(

        onTap: () async {
          int previousIndex = homeC.bottomNavIndex.value; 

          homeC.changeBottomNav(index);

          if (index == 0) {
            Get.offAll(() => HomeView());
          } else if (index == 1) {
            await Get.to(() => PesananView());
            homeC.changeBottomNav(previousIndex); 

          } else if (index == 3) {
            await Get.to(() => PengaturanView()); 
            homeC.changeBottomNav(previousIndex);
          } else if (index == 2) {
            await Get.to(() => LaporanView()); 
            homeC.changeBottomNav(previousIndex);
          }
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: 65,
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: homeC.bottomNavIndex.value == index ? const Color(0xFF2196F3) : Colors.grey.shade400, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: homeC.bottomNavIndex.value == index ? FontWeight.bold : FontWeight.normal,
                  color: homeC.bottomNavIndex.value == index ? const Color(0xFF2196F3) : Colors.grey.shade500,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  void _showTransactionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Pilih pelanggan sebelum\nmelakukan transaksi!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => CariPelangganView());
              },
              child: _bottomSheetMenu(icon: Icons.person_search, label: "Cari Pelanggan", iconBg: Colors.blue.shade100, iconColor: Colors.blue),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => TambahPelangganView());
              },
              child: _bottomSheetMenu(icon: Icons.person_add_alt_1, label: "Tambah Pelanggan", iconBg: Colors.lightBlue.shade100, iconColor: Colors.lightBlue),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: _bottomSheetMenu(icon: Icons.contacts, label: "Ambil dari Kontak HP", iconBg: Colors.grey.shade200, iconColor: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _bottomSheetMenu({required IconData icon, required String label, required Color iconBg, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconBg, radius: 18, child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}