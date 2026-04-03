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

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.changeBottomNav(2); 
    });

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
            Container(
              padding: const EdgeInsets.all(4), 
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), 
              child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 24)
            ),
            const SizedBox(width: 8),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filePdf, color: Color(0xFF102A43)), 
            onPressed: () {
              Get.snackbar("Download PDF", "Fitur cetak PDF belum tersedia", backgroundColor: Colors.orange, colorText: Colors.white);
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
              "Ringkasan", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pilih Periode :", style: TextStyle(color: Colors.black87, fontSize: 14)),
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
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => lapC.prosesLaporan(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("PROSES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(Icons.analytics_outlined, size: 120, color: Colors.blue.shade100),
                    const SizedBox(height: 24),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Pilih Periode terlebih dahulu\nUntuk\nMenampilkan Ringkasan",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                child: Text("Pilih Bulan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
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
                        child: Text(bulan, style: const TextStyle(fontSize: 16, color: Colors.black87)),
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