import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/layanan_controller.dart';

class TambahLayananView extends StatelessWidget {
  TambahLayananView({super.key});

  final LayananController layC = Get.find<LayananController>();

  @override
  Widget build(BuildContext context) {

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Tambah Layanan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding), 

        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: Obx(() => ElevatedButton(
          onPressed: layC.isLoading.value ? null : () => layC.simpanLayanan(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: layC.isLoading.value 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
            : const Text("SIMPAN LAYANAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        )),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabel("Kategori Layanan"),

            RawAutocomplete<String>(
              textEditingController: layC.kategoriCtrl,
              focusNode: FocusNode(),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                   return layC.existingCategories;
                }
                return layC.existingCategories.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return Obx(() => TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.none, 

                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-\&]')),
                    LengthLimitingTextInputFormatter(20),
                  ],

                  decoration: InputDecoration(
                    hintText: "Misal: kiloan, satuan, bed cover",
                    errorText: layC.errKategori.value,
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ));
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                       width: MediaQuery.of(context).size.width - 48, 
                       constraints: const BoxConstraints(maxHeight: 200),
                       child: ListView.builder(
                         padding: EdgeInsets.zero,
                         shrinkWrap: true,
                         itemCount: options.length,
                         itemBuilder: (BuildContext context, int index) {
                           final String option = options.elementAt(index);
                           return InkWell(
                             onTap: () {
                               onSelected(option);
                             },
                             child: Padding(
                               padding: const EdgeInsets.all(16.0),

                               child: Text(option.capitalizeFirst ?? option, style: const TextStyle(fontSize: 16)),
                             ),
                           );
                         },
                       )
                    )
                  )
                );
              },
            ),

            const SizedBox(height: 20),

            _buildLabel("Nama Layanan / Varian"),
            Obx(() => _buildTextField(
              hint: "Misal: express, king, deep clean", 
              controller: layC.namaLayananCtrl,
              errorText: layC.errNama.value,
              textCapitalization: TextCapitalization.none, 
              inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
              LengthLimitingTextInputFormatter(30),
              ],
            )),
            const SizedBox(height: 20),

            _buildLabel("Harga"),
            Obx(() => _buildTextField(
              hint: "Contoh: 15.000", 
              controller: layC.hargaCtrl,
              errorText: layC.errHarga.value,
              keyboardType: TextInputType.number,
              prefixText: "Rp ",
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
              onChanged: (val) => layC.formatHarga(val, layC.hargaCtrl) 
            )),
            const SizedBox(height: 20),

            _buildLabel("Estimasi Selesai (Durasi)"),
            Obx(() => _buildTextField(
              hint: "Contoh: 8 (untuk 8 jam) atau 24 (untuk 1 hari)", 
              controller: layC.durasiCtrl,
              errorText: layC.errDurasi.value,
              keyboardType: TextInputType.number,
              suffixText: " Jam",
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            )),
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

  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, 
    TextInputType keyboardType = TextInputType.text, 
    String? prefixText, 
    String? suffixText,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText, 
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        filled: true,
        fillColor: Colors.grey.shade50, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}