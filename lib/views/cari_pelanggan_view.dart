import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pelanggan_controller.dart';
import 'tambah_pelanggan_view.dart'; 

class CariPelangganView extends StatelessWidget {
  CariPelangganView({super.key});

  final PelangganController pelC = Get.put(PelangganController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20),
            ),
            const SizedBox(width: 8),
            const Text("kiloan",
                style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () {
          pelC.prepareNewForm(); 
          Get.to(() => TambahPelangganView());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        "Pelanggan (${pelC.filteredPelanggan.length})",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102A43)),
                      )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: pelC.searchCtrl,
                            onChanged: (val) => pelC.searchQuery.value = val,
                            decoration: const InputDecoration(
                              hintText: "Cari pelanggan...",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(() => DropdownButton<String>(
                                value: pelC.sortType.value,
                                icon: const Icon(Icons.sort_by_alpha,
                                    color: Color(0xFF2196F3), size: 20),
                                style: const TextStyle(
                                    color: Color(0xFF102A43),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                onChanged: (String? newValue) {
                                  if (newValue != null) pelC.changeSort(newValue);
                                },
                                items: <String>['Terbaru', 'Abjad']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value, child: Text(value));
                                }).toList(),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Obx(() {
                if (pelC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = pelC.filteredPelanggan;

                if (data.isEmpty) {
                  return const Center(child: Text("Belum ada pelanggan"));
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var p = data[index];

                    String nama = p['nama_pelanggan'] ?? '';
                    String noHp = p['no_wa'] ?? "Tanpa nomor";

                    String inisial = nama.isNotEmpty
                        ? nama
                            .trim()
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                        : "--";

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => pelC.goToDetail(nama, noHp, p['id']),
                          child: _pelangganItem(
                            inisial: inisial,
                            nama: nama,
                            noHp: noHp,
                            isBaru: false,
                            id: p['id'],
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFEEEEEE)),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pelangganItem({
    required String inisial,
    required String nama,
    required String noHp,
    required bool isBaru,
    required int id,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFFF9800),
          child: Text(inisial,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(nama,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF102A43))),
                  const SizedBox(width: 8),
                  if (isBaru)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFCC80),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text("Baru",
                          style: TextStyle(
                              color: Color(0xFFE65100),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(noHp,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
        OutlinedButton(

          onPressed: () => pelC.validasiDanLanjutOrder(nama, noHp, id),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2196F3),
            side: const BorderSide(color: Color(0xFF2196F3)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text("+ Order",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}