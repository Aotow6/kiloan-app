import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pesanan_controller.dart';
import '../controllers/detail_pesanan_controller.dart';

class DetailPesananView extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailPesananView({super.key, required this.data});

  final DetailPesananController detailC = Get.put(DetailPesananController());
  final PesananController pesananC = Get.find<PesananController>();

  @override
  Widget build(BuildContext context) {
    detailC.fetchDetailItems(data['id']);

    String tglMasuk = data['waktu_masuk'] != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(data['waktu_masuk']))
        : "-";

    String estSelesai = data['estimasi_selesai'] != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(data['estimasi_selesai']))
        : "-";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ✅ APPBAR FIX (TADI ERROR DI SINI)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ✅ BOTTOM BUTTON (SUDAH ADA WHATSAPP)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // 🔥 TOMBOL WHATSAPP
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  detailC.kirimNotaWA(
                    transaksi: data,
                    namaCustomer:
                        data['customers']?['nama_pelanggan'] ?? '',
                    noWa: data['customers']?['no_wa'] ?? '',
                  );
                },
                icon: const Icon(Icons.chat),
                label: const Text("Kirim Nota WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (data['status_pembayaran'] == 'Belum Lunas') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    pesananC.lunasiPembayaran(data['id']);
                  },
                  icon: const Icon(Icons.payments_outlined, color: Colors.white),
                  label: const Text(
                    "LUNASI PEMBAYARAN",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (data['status_pesanan'] == 'proses') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      pesananC.updateStatusPesanan(data['id'], 'Batal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "BATALKAN PESANAN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      pesananC.updateStatusPesanan(data['id'], 'Selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "SELESAIKAN PROSES",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),

      // ✅ BODY
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // STATUS
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Text(
                "Status: ${data['status_pesanan'].toString().toUpperCase()}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // INFO CUSTOMER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['nomor_nota'] ?? "-",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(tglMasuk),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['customers']?['nama_pelanggan'] ??
                                  "Pelanggan",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(data['customers']?['no_wa'] ?? "-"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // DETAIL ITEM
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rincian Cucian",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    if (detailC.isLoading.value) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    return Column(
                      children: detailC.listItems.map((item) {
                        return ListTile(
                          title: Text(
                              "${item['services']['nama_layanan']}"),
                          trailing: Text(
                              "${item['kuantitas']} ${item['services']['satuan']}"),
                        );
                      }).toList(),
                    );
                  })
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ESTIMASI
            Center(
              child: Column(
                children: [
                  const Text("Estimasi Selesai"),
                  Text(estSelesai),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String formatted = cleanText.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}