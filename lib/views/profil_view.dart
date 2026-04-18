import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
             Image.asset(
                    'assets/images/app.png',
                    height: 32,
                    width: 32,
                  ),
            const SizedBox(width: 8),
            const Text("kiloan",             style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)),

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
                      ))
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildLabel("Nama"),
            Obx(() => _buildTextField(
              controller: profC.namaCtrl, 
              hint: "Masukkan nama",
              errorText: profC.errNama.value,

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
              ],
            )),

            const SizedBox(height: 20),

            _buildLabel("Email"),
            Obx(() => TextField(
              controller: profC.emailCtrl,
              keyboardType: TextInputType.emailAddress,

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@\.\-_]")),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                errorText: profC.errEmail.value,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                suffixIcon: const Icon(Icons.edit_outlined, color: Colors.grey),
              ),
            )),

            const SizedBox(height: 20),

            _buildLabel("Telepon"),
            Obx(() => _buildTextField(
              controller: profC.teleponCtrl, 
              hint: "08123456789", 
              keyboardType: TextInputType.number,
              errorText: profC.errTelepon.value,

              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)],
            )),

            const SizedBox(height: 20),

            _buildLabel("Password"),
            Obx(() => TextField(
                  controller: profC.passwordCtrl,
                  obscureText: profC.isPasswordHidden.value,

                  decoration: InputDecoration(
                    hintText: "Kosongkan jika tidak ingin mengubah",
                    errorText: profC.errPassword.value,
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
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

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}