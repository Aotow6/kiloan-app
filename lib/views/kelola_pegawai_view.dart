import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/kelola_pegawai_controller.dart';
import 'tambah_pegawai_view.dart'; 

class KelolaPegawaiView extends StatelessWidget {
  KelolaPegawaiView({super.key});

  final KelolaPegawaiController pegC = Get.put(KelolaPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Kelola Pegawai", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF102A43)), onPressed: () {}),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () => Get.to(() => TambahPegawaiView()),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pegC.listPegawai.length,
        itemBuilder: (context, index) {
          var pegawai = pegC.listPegawai[index];
          bool isActive = pegawai['isActive'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [

                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2196F3),
                  child: const FaIcon(FontAwesomeIcons.solidUser, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pegawai['nama'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      const SizedBox(height: 4),
                      Text(pegawai['telepon'].toString(), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Switch(
                      value: isActive,
                      activeColor: Colors.green,
                      onChanged: (val) => pegC.toggleStatus(index, val),
                    ),

                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {

                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () => pegC.hapusPegawai(pegawai['id'] as int, pegawai['nama'].toString()),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}