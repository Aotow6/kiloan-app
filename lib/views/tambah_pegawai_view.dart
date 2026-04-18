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

        title: Obx(() => Text(
          tamC.isEdit.value ? "Edit Pegawai" : "Tambah Pegawai", 
          style: const TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)
        )),
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
          ),
          child: tamC.isLoading.value 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("SIMPAN DATA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        )),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabel("Nama Pegawai"),
            Obx(() => _buildTextField(
              hint: "Masukkan nama pegawai", 
              controller: tamC.namaCtrl,
              errorText: tamC.errNama.value,

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
              ],
            )),
            const SizedBox(height: 20),

            _buildLabel("Telepon"),
            Obx(() => _buildTextField(
              hint: "081234567890", 
              controller: tamC.teleponCtrl,
              keyboardType: TextInputType.phone,
              errorText: tamC.errTelepon.value,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
            )),
            const SizedBox(height: 20),

            Obx(() {
              if (tamC.isEdit.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Email Login"),
                  _buildTextField(
                    hint: "Contoh: kasir1@gmail.com", 
                    controller: tamC.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    errorText: tamC.errEmail.value,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@\.\-_]")),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Kata Sandi"),
                  TextField(
                    controller: tamC.passwordCtrl,
                    obscureText: tamC.isPasswordHidden.value,

                    decoration: InputDecoration(
                      hintText: "Buat kata sandi",
                      errorText: tamC.errPassword.value,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(tamC.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => tamC.togglePassword(),
                      ),
                    ),
                  ),
                ],
              );
            }),
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
    required String hint, 
    required TextEditingController controller, 
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