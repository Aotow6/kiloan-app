import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends StatelessWidget {
  ProfilView({super.key});

  final ProfilController profC = Get.put(ProfilController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: Row( 
          children: [
            Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0x332196F3), borderRadius: BorderRadius.all(Radius.circular(6))),
                child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 18)),
            const SizedBox(width: 8),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: Obx(() => ElevatedButton(
              onPressed: profC.isLoading.value ? null : () => profC.simpanProfil(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: Colors.grey,
              ),
              child: profC.isLoading.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0x1A2196F3),
                    child: Icon(Icons.person, size: 50, color: Color(0xFF2196F3)),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white)),
                      ))
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel("Nama"),
            _buildTextField(profC.namaCtrl, "Satria"),
            const SizedBox(height: 20),
            _buildLabel("Email"),
            TextField(
              controller: profC.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              enabled: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                suffixIcon: const Icon(Icons.edit_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabel("Telepon"),
            _buildTextField(profC.teleponCtrl, "083141535335", keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildLabel("Password"),
            Obx(() => TextField(
                  controller: profC.passwordCtrl,
                  obscureText: profC.isPasswordHidden.value,
                  decoration: InputDecoration(
                    hintText: "Kosongkan jika tidak ingin mengubah",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    suffixIcon: IconButton(
                        icon: Icon(profC.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => profC.togglePasswordVisibility()),
                  ),
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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