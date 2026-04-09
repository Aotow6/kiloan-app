import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/tambah_pegawai_controller.dart';

class TambahPegawaiView extends StatelessWidget {
  TambahPegawaiView({super.key});

  final TambahPegawaiController tamC = Get.put(TambahPegawaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Tambah Pegawai", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: Obx(() => ElevatedButton(
          onPressed: tamC.isLoading.value ? null : () => tamC.simpanData(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            disabledBackgroundColor: Colors.grey,
          ),
          child: tamC.isLoading.value 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("SIMPAN AKUN KASIR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        )),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabel("Nama Lengkap"),
            _buildTextField(hint: "Masukkan nama pegawai", controller: tamC.namaCtrl),
            const SizedBox(height: 20),

            _buildLabel("Telepon / WhatsApp"),
            _buildTextField(
              hint: "081234567890", 
              controller: tamC.teleponCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _buildLabel("Email (Untuk Login)"),
            _buildTextField(
              hint: "Contoh: kasir1@rutarolaundry.com", 
              controller: tamC.emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            _buildLabel("Kata Sandi (Minimal 6 karakter)"),
            Obx(() => TextField(
              controller: tamC.passwordCtrl,
              obscureText: tamC.isPasswordHidden.value,
              decoration: InputDecoration(
                hintText: "Buat kata sandi sementara",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                suffixIcon: IconButton(
                  icon: Icon(tamC.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => tamC.togglePassword(),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}