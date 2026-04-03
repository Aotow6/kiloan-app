import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/layanan_controller.dart';

class TambahLayananView extends StatelessWidget {
  TambahLayananView({super.key});

  final LayananController layC = Get.find<LayananController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Tambah Layanan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: ElevatedButton(
          onPressed: () => layC.simpanLayanan(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("SIMPAN LAYANAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabel("Kategori Layanan"),
            _buildTextField(
              hint: "Misal: Kiloan, Bed Cover, Sepatu", 
              controller: layC.kategoriCtrl
            ),
            const SizedBox(height: 20),

            _buildLabel("Nama Layanan / Varian"),
            _buildTextField(
              hint: "Misal: Express, King, Deep Clean", 
              controller: layC.namaLayananCtrl
            ),
            const SizedBox(height: 20),

            _buildLabel("Harga"),
            _buildTextField(
              hint: "Contoh: 15000", 
              controller: layC.hargaCtrl,
              keyboardType: TextInputType.number,
              prefixText: "Rp "
            ),
            const SizedBox(height: 20),

            _buildLabel("Estimasi Selesai (Durasi)"),
            _buildTextField(
              hint: "Contoh: 8 (untuk 8 jam) atau 24 (untuk 1 hari)", 
              controller: layC.durasiCtrl,
              keyboardType: TextInputType.number,
              suffixText: " Jam"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, String? prefixText, String? suffixText}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        filled: true,
        fillColor: Colors.grey.shade50, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}