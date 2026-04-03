import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/layanan_controller.dart';
import 'tambah_layanan_view.dart';

class KelolaLayananView extends StatelessWidget {
  KelolaLayananView({super.key});

  final LayananController layC = Get.put(LayananController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Kelola Layanan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () => Get.to(() => TambahLayananView()),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [

                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: layC.searchCtrl,
                    onChanged: (value) => layC.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: "Cari layanan...",
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
                const SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: layC.selectedFilter.value,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        style: const TextStyle(color: Color(0xFF102A43), fontSize: 14, fontWeight: FontWeight.w500),
                        items: layC.filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            layC.selectedFilter.value = newValue;
                          }
                        },
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),

          Expanded(
            child: Obx(() {
              var groupedData = layC.groupedServices;

              if (groupedData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("Data tidak ditemukan", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    ],
                  )
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: groupedData.length,
                itemBuilder: (context, index) {
                  String kategori = groupedData.keys.elementAt(index);
                  List<Map<String, dynamic>> services = groupedData[kategori]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(kategori, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                            IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.orange), 
                              onPressed: () {} 
                            )
                          ],
                        ),
                      ),

                      ...services.map((service) => _buildServiceItem(service, kategori)).toList(),
                      const Divider(height: 32),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, String kategori) {
    String hargaFormat = service['harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    int jam = service['durasi_jam'] as int;
    String durasiText = jam >= 24 && jam % 24 == 0 ? "${jam ~/ 24} Hari" : "$jam Jam";

    IconData getIcon() {
      String kat = kategori.toLowerCase();
      if (kat.contains("kiloan")) return FontAwesomeIcons.shirt;
      if (kat.contains("bed")) return FontAwesomeIcons.bed;
      if (kat.contains("sepatu")) return FontAwesomeIcons.shoePrints;
      if (kat.contains("boneka")) return FontAwesomeIcons.paw;
      return FontAwesomeIcons.box;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Center(child: FaIcon(getIcon(), color: Colors.blueGrey, size: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['nama_layanan'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                const SizedBox(height: 4),
                Text(hargaFormat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                const SizedBox(height: 4),
                Text(durasiText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => layC.hapusLayanan(service['id'] as int, service['nama_layanan'].toString()),
          )
        ],
      ),
    );
  }
}