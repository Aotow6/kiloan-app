import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaksi_controller.dart';

class KonfirmasiPesananView extends StatelessWidget {
  final String namaCustomer;
  final String phoneCustomer;
  final String idCustomer;

  KonfirmasiPesananView({
    super.key,
    required this.namaCustomer,
    required this.phoneCustomer,
    required this.idCustomer,
  });

  final TransaksiController trxC = Get.find<TransaksiController>();

  String formatRupiah(int value) {
    return value
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(
              color: Color(0xFF102A43), fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Tagihan",
                    style: TextStyle(color: Colors.grey)),
                Obx(() => Text(
                      "Rp ${formatRupiah(trxC.totalTagihan)}",
                      style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: trxC.isLoading.value
                        ? null
                        : () => trxC.buatTransaksi(
                              idCustomer,
                              namaCustomer,
                              phoneCustomer,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: trxC.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Buat Transaksi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  )),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaCustomer,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      Text(phoneCustomer,
                          style: const TextStyle(color: Colors.teal)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 8),

            Obx(() => Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Layanan Antar Jemput"),
                          Switch(
                            value: trxC.isAntarJemput.value,
                            onChanged: (val) =>
                                trxC.toggleAntarJemput(val),
                          ),
                        ],
                      ),

                      if (trxC.isAntarJemput.value) ...[
                        const SizedBox(height: 10),

                        TextField(
                          controller: trxC.alamatCtrl,
                          decoration: const InputDecoration(
                            hintText: "Masukkan alamat",
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () =>
                              trxC.showOngkirDialog(context),
                          child: Text(
                            trxC.deliveryFee.value > 0
                                ? "Rp ${formatRupiah(trxC.deliveryFee.value)}"
                                : "+ Atur Ongkir",
                          ),
                        ),
                      ]
                    ],
                  ),
                )),

            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Obx(() => Column(
                    children: trxC.cart.asMap().entries.map((entry) {
                      var item = entry.value;
                      int index = entry.key;

                      return ListTile(
                        title: Text(item['nama_layanan']),
                        subtitle: Text(
                            "${item['kuantitas']} x Rp ${formatRupiah(item['harga_satuan'])}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Rp ${formatRupiah(item['subtotal_harga'])}"),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  trxC.ubahQtyCart(index, 0),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}