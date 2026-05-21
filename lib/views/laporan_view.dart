import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';
import '../controllers/home_controller.dart';
import 'widgets/navbar.dart';

class LaporanView extends StatelessWidget {
  LaporanView({super.key});

  final LaporanController lapC = Get.put(LaporanController());
  final HomeController homeC = Get.find<HomeController>();

  String formatRupiah(int angka) {
    return "Rp ${angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.'
    )}";
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.changeBottomNav(2);
    });

    if (homeC.userC.currentUser.value?.role?.toLowerCase() == 'kasir') {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        bottomNavigationBar: CustomBottomNav(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text("Akses Ditolak", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 8),
              Text("Halaman ini khusus untuk Admin / Owner.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
            'assets/images/app.png',
            height: 32,
            width: 32,
          ),
          const SizedBox(width: 8),
          const Text(
            "kiloan",
            style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filePdf, color: Color(0xFF102A43)),
            onPressed: () {
               if (!lapC.isLoading.value) {
                  lapC.cetakLaporanPDF();
               }
            }
          ),
          const SizedBox(width: 8),
        ],
      ),

      bottomNavigationBar: CustomBottomNav(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: const Text(
              "Ringkasan Kinerja",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pilih Periode :",
                  style: TextStyle(color: Colors.black87, fontSize: 14)
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => _tampilkanDialogBulan(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          lapC.selectedPeriode.value,
                          style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)
                        )),
                        const Icon(Icons.arrow_drop_down, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (lapC.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await lapC.prosesLaporan();
                },
                color: const Color(0xFF2196F3),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Total Pendapatan Kas Bulanan",
                              style: TextStyle(color: Colors.white70, fontSize: 14)
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatRupiah(lapC.totalPemasukan.value),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF2196F3),
                                size: 30
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total Pesanan Layanan",
                                    style: TextStyle(fontSize: 14, color: Colors.grey)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${lapC.totalPesanan.value} Transaksi",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF102A43)
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(Icons.money_off, color: Colors.orange, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Estimasi Piutang Baru (Bulan Ini)", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(formatRupiah(lapC.totalPiutang.value), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _tampilkanDialogBulan(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 16),
                child: Text(
                  "Pilih Bulan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lapC.listPeriode.length,
                  itemBuilder: (context, index) {
                    String bulan = lapC.listPeriode[index];
                    return InkWell(
                      onTap: () => lapC.ubahPeriode(bulan),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Text(
                          bulan,
                          style: const TextStyle(fontSize: 16, color: Colors.black87)
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}