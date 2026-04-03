import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends StatelessWidget {
  ProfilView({super.key});

  final ProfilController profilC = Get.put(ProfilController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), 
          onPressed: () => Get.back()
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4), 
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), 
              child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20)
            ),
            const SizedBox(width: 8),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: ElevatedButton(
          onPressed: () => profilC.simpanProfil(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1.2)),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200))
              ),
              child: const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.shade100, width: 4),
                        ),
                        child: const Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white, size: 36)),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Nama"),
                            _buildTextField(
                              hint: "Nama Anda", 
                              controller: profilC.namaCtrl,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildLabel("Email"),
                  _buildTextField(
                    hint: "email@contoh.com", 
                    controller: profilC.emailCtrl,
                    isReadOnly: true, 
                  ),
                  const SizedBox(height: 24),

                  _buildLabel("Telepon"),
                  _buildTextField(
                    hint: "08xxxxxxxxxx", 
                    controller: profilC.teleponCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  _buildLabel("Password"),
                  Obx(() => TextField(
                    controller: profilC.passwordCtrl,
                    obscureText: profilC.isPasswordHidden.value,
                    decoration: InputDecoration(
                      hintText: "Kosongkan jika tidak ingin mengubah",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          profilC.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => profilC.togglePassword(),
                      ),
                    ),
                  )),

                ],
              ),
            ),
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

  Widget _buildTextField({required String hint, required TextEditingController controller, bool isReadOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: TextStyle(
        color: isReadOnly ? Colors.grey.shade600 : Colors.black87,
        fontWeight: isReadOnly ? FontWeight.normal : FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: isReadOnly ? Colors.grey.shade200 : Colors.grey.shade50, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        suffixIcon: isReadOnly ? const Icon(Icons.lock_outline, color: Colors.grey, size: 20) : null,
      ),
    );
  }
}