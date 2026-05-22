import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/tambah_pelanggan_view.dart';
import '../controllers/pelanggan_controller.dart';
import '../controllers/home_controller.dart';


class KelolaPelangganView extends StatelessWidget {
  KelolaPelangganView({super.key});

  final PelangganController pelC = Get.put(PelangganController());
  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Kelola Pelanggan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () {
          pelC.prepareNewForm(); 

          Get.to(() => TambahPelangganView());
        }, 
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2196F3))),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Obx(() => Text(
                  "Total: ${pelC.totalPelanggan.value} Pelanggan", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)
                )),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (pelC.isLoading.value && pelC.listPelanggan.isEmpty) {
                 return const Center(child: CircularProgressIndicator());
              }

              var dataList = pelC.filteredPelanggan;

              if (dataList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("Pelanggan tidak ditemukan", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  )
                );
              }

              return RefreshIndicator(
                onRefresh: () => pelC.fetchPelanggan(),
                child: ListView.builder(
                  controller: pelC.scrollController, 

                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  itemCount: dataList.length + (pelC.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {

                    if (index == dataList.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.blue),
                          ),
                        );
                      }

                    var pelanggan = dataList[index];

                    String nama = pelanggan['nama_pelanggan']?.toString() ?? "Tanpa Nama";
                    String telepon = pelanggan['no_wa']?.toString() ?? "";
                    int id = pelanggan['id'] as int;

                    String inisial = nama.trim().isNotEmpty
                        ? nama.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
                        : "?";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.orange.shade400,
                            child: Text(inisial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama, 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  telepon.isEmpty ? "Tanpa nomor" : telepon, 
                                  style: TextStyle(fontSize: 13, color: telepon.isEmpty ? Colors.grey.shade400 : Colors.grey.shade600)
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                tooltip: "Lihat Detail",

                                onPressed: () => pelC.goToDetail(nama, telepon.isEmpty ? "Tanpa nomor" : telepon, id), 
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                tooltip: "Edit Pelanggan",

                                onPressed: () => pelC.setEditMode(nama, telepon, id),
                              ),
                              if (homeC.userC.currentUser.value?.role?.toLowerCase() != 'kasir')
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                tooltip: "Hapus Pelanggan",

                                onPressed: () => pelC.hapusPelanggan(id, nama),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}