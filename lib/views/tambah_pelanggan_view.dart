import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pelanggan_controller.dart';

class TambahPelangganView extends StatelessWidget {
  TambahPelangganView({super.key});

  final PelangganController pelC = Get.put(PelangganController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20),
            ),
            const SizedBox(width: 8),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: ElevatedButton(
          onPressed: () {

            Get.back();
            Get.snackbar("Sukses", "Pelanggan berhasil ditambahkan", backgroundColor: Colors.green, colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("SIMPAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),

      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Tambah Pelanggan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Nama", style: TextStyle(fontSize: 14, color: Color(0xFF102A43), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pelC.namaCtrl,
                      decoration: InputDecoration(
                        hintText: "Nama Pelanggan",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text("Telepon", style: TextStyle(fontSize: 14, color: Color(0xFF102A43), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: pelC.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      enabled: !pelC.isTanpaNomor.value, 

                      decoration: InputDecoration(
                        hintText: "812-345-678",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: pelC.isTanpaNomor.value ? Colors.grey.shade200 : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("🇮🇩", style: TextStyle(fontSize: 18)), 

                              SizedBox(width: 4),
                              Text("+62", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 12),

                    Obx(() => GestureDetector(
                      onTap: () => pelC.toggleTanpaNomor(!pelC.isTanpaNomor.value),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: pelC.isTanpaNomor.value,
                              onChanged: pelC.toggleTanpaNomor,
                              activeColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("Tanpa nomor telepon", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}