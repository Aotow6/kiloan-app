import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tambah_pesanan_controller.dart';

class TambahPesananView extends StatelessWidget {
  TambahPesananView({super.key});

  final TambahPesananController tambahC = Get.put(TambahPesananController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Buat Pesanan Baru",
          style: TextStyle(
              color: Color(0xFF102A43), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
      body: Obx(() {
        if (tambahC.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Informasi Pelanggan"),

              Row(
                children: [
                  Expanded(child: _buildPelangganDropdown()),
                  IconButton(
                    onPressed: () => _showTambahPelanggan(),
                    icon: const Icon(Icons.person_add_alt_1,
                        color: Colors.blue),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle("Layanan & Detail"),
              _buildLayananDropdown(),
              const SizedBox(height: 16),

              _buildInputBerat(),
              const SizedBox(height: 20),

              _sectionTitle("Catatan Tambahan"),
              TextField(
                controller: tambahC.catatanCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      "Contoh: Cuci bersih, jangan campur baju luntur",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 30),

              _buildRingkasanHarga(),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43))),
    );
  }

  Widget _buildPelangganDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<int>(
              hint: const Text("Pilih Pelanggan"),
              isExpanded: true,
              value: tambahC.selectedPelangganId.value,
              items: tambahC.listPelanggan.map((p) {
                return DropdownMenuItem<int>(
                  value: p['id'],
                  child:
                      Text("${p['nama_pelanggan']} - ${p['no_wa']}"),
                );
              }).toList(),
              onChanged: (val) =>
                  tambahC.selectedPelangganId.value = val,
            )),
      ),
    );
  }

  Widget _buildLayananDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<int>(
              hint: const Text("Pilih Layanan"),
              isExpanded: true,
              value: tambahC.selectedLayananId.value,
              items: tambahC.listLayanan.map((l) {
                return DropdownMenuItem<int>(
                  value: l['id'],
                  child: Text(
                      "${l['nama_layanan']} (Rp ${l['harga']}/${l['satuan']})"),
                );
              }).toList(),
              onChanged: (val) {
                tambahC.selectedLayananId.value = val;
                var lay = tambahC.listLayanan
                    .firstWhere((element) => element['id'] == val);
                tambahC.hargaLayanan.value = lay['harga'];
                tambahC.hitungTotal();
              },
            )),
      ),
    );
  }

  Widget _buildInputBerat() {
    return Row(
      children: [
        const Text("Jumlah / Berat:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 15),
        SizedBox(
          width: 80,
          child: TextField(
            controller: tambahC.beratCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (v) => tambahC.hitungTotal(),
          ),
        ),
        const SizedBox(width: 10),
        const Text("Kg / Pcs"),
      ],
    );
  }

  Widget _buildRingkasanHarga() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Estimasi Total:",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                "Rp ${tambahC.totalHarga.value}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ],
          ),
        ));
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => tambahC.simpanPesanan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("SIMPAN PESANAN",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showTambahPelanggan() {
    final namaCtrl = TextEditingController();
    final waCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pelanggan Baru",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: namaCtrl,
                decoration:
                    const InputDecoration(labelText: "Nama Pelanggan")),
            TextField(
                controller: waCtrl,
                decoration: const InputDecoration(
                    labelText: "Nomor WhatsApp (62xxx)")),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await tambahC.supabase.from('customers').insert({
                    'outlet_id': tambahC.userC.outletId,
                    'nama_pelanggan': namaCtrl.text,
                    'no_wa': waCtrl.text,
                  });

                  tambahC.fetchInitialData();
                  Get.back();
                },
                child: const Text("SIMPAN"),
              ),
            )
          ],
        ),
      ),
    );
  }
}