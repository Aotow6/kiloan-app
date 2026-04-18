import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/outlet_controller.dart';

class OutletView extends StatelessWidget {
  OutletView({super.key});

  final OutletController outletC = Get.put(OutletController());
  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.changeBottomNav(3); 
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
            const SizedBox(width: 10),
            const Text("kiloan",             style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.white,
              child: const Text("Edit Profil Outlet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            ),

            Container(
              color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Outlet", isRequired: true),
                  Obx(() => _buildTextField(
                    hint: "Contoh: Raya Laundry Samarinda", 
                    icon: FontAwesomeIcons.shop, 
                    controller: outletC.namaCtrl,
                    errorText: outletC.errNama.value,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
                    ],
                  )),
                  const SizedBox(height: 20),

                  _buildLabel("Alamat", isRequired: true),
                  Obx(() => _buildTextField(
                    hint: "Jl. Antasari No. 12, Samarinda", 
                    icon: FontAwesomeIcons.mapLocationDot, 
                    maxLines: 4, 
                    controller: outletC.alamatCtrl,
                    errorText: outletC.errAlamat.value,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\'\,\/\(\)]")),
                    ],
                  )),
                  const SizedBox(height: 24),

                  const Text("Jam Operasional", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildTimePicker(
                          label: "Jam Buka",
                          time: outletC.jamBuka.value,
                          icon: FontAwesomeIcons.doorOpen,
                          onTap: () => outletC.pilihJam(context, true) 
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => _buildTimePicker(
                          label: "Jam Tutup",
                          time: outletC.jamTutup.value,
                          icon: FontAwesomeIcons.doorClosed,
                          onTap: () => outletC.pilihJam(context, false) 
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: outletC.isLoading.value ? null : () => outletC.simpanProfil(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3), padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: outletC.isLoading.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                )),
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF102A43))),
          if (isRequired) const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    int maxLines = 1, 
    TextEditingController? controller,
    String? errorText,
    List<TextInputFormatter>? inputFormatters, 
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      inputFormatters: inputFormatters, 

      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText, 

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16, right: 12, top: maxLines > 1 ? 16 : 0, bottom: maxLines > 1 ? 16 : 0),
          child: FaIcon(icon, color: const Color(0xFF2196F3), size: 20),
        ),

        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 0),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildTimePicker({required String label, required String time, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            FaIcon(icon, color: const Color(0xFF2196F3), size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}