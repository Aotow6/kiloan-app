import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/tambah_pelanggan_view.dart';
import 'package:laundry_app/views/pilih_layanan_view.dart';
import '../controllers/pelanggan_controller.dart';

class KelolaPelangganView extends StatelessWidget {
  KelolaPelangganView({super.key});

  final PelangganController pelC = Get.put(PelangganController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Kelola Pelanggan",
          style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () => Get.to(() => TambahPelangganView()),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              controller: pelC.searchCtrl,
              onChanged: (value) => pelC.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: "Cari nama atau nomor telepon...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Text(
                  "Total: ${pelC.filteredPelanggan.length} Pelanggan",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
          ),

          Expanded(
            child: Obx(() {
              var dataList = pelC.filteredPelanggan;

              if (dataList.isEmpty) {
                return const Center(child: Text("Tidak ada pelanggan"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  var p = dataList[index];

                  String nama = p['nama_pelanggan'] ?? "";
                  String noHp = p['no_wa'] ?? "";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text(nama.isNotEmpty ? nama[0] : "?"),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(noHp.isEmpty ? "Tanpa nomor" : noHp),
                            ],
                          ),
                        ),

                        // 🔥 TOMBOL ORDER (INI YANG PENTING)
                        ElevatedButton(
                          onPressed: () => Get.to(() => PilihLayananView(
                                namaCustomer: nama,
                                idCustomer: p['id'], // ✅ ID ASLI (INT)
                                noHp: noHp,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("+ Order"),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}