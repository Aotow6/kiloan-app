import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import 'package:get/get.dart';
import '../controllers/pelanggan_controller.dart';

class TambahPelangganView extends StatelessWidget {
  TambahPelangganView({super.key});

  final PelangganController pelangganC = Get.put(PelangganController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Tambah Pelanggan",
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: Obx(() => ElevatedButton(
          onPressed: pelangganC.isLoading.value ? null : () {
            pelangganC.simpanPelanggan();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: pelangganC.isLoading.value 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
            "SIMPAN",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )),
      ),

      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Tambah Pelanggan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF102A43),
                ),
              ),
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Nama"),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: pelangganC.namaCtrl,

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
                        LengthLimitingTextInputFormatter(30),
                      ],

                      decoration: InputDecoration(
                        hintText: "Nama Pelanggan",
                        errorText: pelangganC.errNama.value, 
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    )),

                    const SizedBox(height: 24),

                    const Text("Telepon"),
                    const SizedBox(height: 8),

                    Obx(() => TextField(
                          controller: pelangganC.phoneCtrl,
                          enabled: !pelangganC.isTanpaNomor.value,
                          keyboardType: TextInputType.number, 

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, 
                            LengthLimitingTextInputFormatter(13), 
                          ],
                          decoration: InputDecoration(
                            hintText: "0812345678",
                            errorText: pelangganC.errPhone.value, 
                            filled: true,
                            fillColor: pelangganC.isTanpaNomor.value
                                ? Colors.grey.shade200
                                : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                        )),

                    const SizedBox(height: 12),

                    Obx(() => Row(
                          children: [
                            Checkbox(
                              value: pelangganC.isTanpaNomor.value,
                              onChanged: pelangganC.toggleTanpaNomor,
                            ),
                            const Text("Tanpa nomor telepon"),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}