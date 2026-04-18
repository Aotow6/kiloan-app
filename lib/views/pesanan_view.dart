import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
      bottomNavigationBar: CustomBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),

            Expanded(
              child: Obx(() {
                final isWaiting = pesananC.isLoading.value;
                if (isWaiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = pesananC.searchQuery.value.toLowerCase();
                final items = pesananC.listPesanan.where((item) {
                  final nama = (item['customers']?['nama_pelanggan'] ?? "").toLowerCase();
                  final nota = (item['nomor_nota'] ?? "").toLowerCase();
                  return nama.contains(query) || nota.contains(query);
                }).toList();

                if (items.isEmpty) {
                  return _emptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => pesananC.fetchPesanan(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _orderCard(items[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
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
                    height: 32,
                    width: 32,
                  ),
                  const SizedBox(width: 8),
                  const Text("kiloan",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3))),
                ],
                ),
                const Icon(Icons.receipt_long, color: Color(0xFF2196F3), size: 28),
            ],
          ),

          const SizedBox(height: 15),

          TextField(
            onChanged: (value) => pesananC.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: "Cari nama atau no. nota...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      height: 50,
      child: Obx(() {
        final currentTab = pesananC.selectedTab.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: pesananC.tabs.length,
          itemBuilder: (context, index) {
            bool isActive = currentTab == index;
            return GestureDetector(
              onTap: () => pesananC.changeTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: isActive
                              ? const Color(0xFF2196F3)
                              : Colors.transparent,
                          width: 3)),
                ),
                child: Center(
                  child: Text(
                    pesananC.tabs[index],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF2196F3)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _orderCard(Map<String, dynamic> data) {
    String tgl = "-";
    if (data['waktu_masuk'] != null) {
      try {
        tgl = DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(data['waktu_masuk']));
      } catch (e) {
        tgl = "-";
      }
    }

    String statusPesanan = (data['status_pesanan'] ?? "").toString().toLowerCase();
    String statusBayar = data['status_pembayaran'] ?? "Belum Lunas";
    Color badgeColor = Colors.red.shade700;

    if (statusPesanan == 'batal') {
      statusBayar = 'Batal';
      badgeColor = const Color.fromARGB(255, 255, 0, 0);
    } else {
      if (statusBayar == 'Lunas') badgeColor = Colors.green;
      if (statusBayar == 'Bon') badgeColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () async {
        final bool? result = await Get.to(() => DetailPesananView(data: data));
        if (result == true) {
          pesananC.fetchPesanan();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['nomor_nota'] ?? "-",
                    style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusBayar,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              children: [
                Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person, color: Color(0xFF2196F3))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          data['customers'] != null
                              ? data['customers']['nama_pelanggan']
                              : "Pelanggan",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF102A43))),
                      const SizedBox(height: 4),
                      Text("Masuk: $tgl",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Data tidak ditemukan",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}