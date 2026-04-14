import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaksi_controller.dart';

class KonfirmasiPesananView extends StatelessWidget {
  final String namaCustomer;
  final String phoneCustomer; 
  final String idCustomer;

  KonfirmasiPesananView({super.key, required this.namaCustomer, required this.phoneCustomer, required this.idCustomer});

  final TransaksiController trxC = Get.find<TransaksiController>();

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Konfirmasi Pesanan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Tagihan", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Obx(() => Text("Rp ${_formatRupiah(trxC.totalTagihan)}", style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 20, fontWeight: FontWeight.bold))),
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
                  backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                    : const Text("Buat Transaksi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              )),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              color: Colors.white, padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaCustomer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                        const SizedBox(height: 2),
                        Text(phoneCustomer, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            Obx(() => Container(
              color: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Layanan Antar Jemput", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      Switch(
                        value: trxC.isAntarJemput.value,
                        activeTrackColor: Colors.blue.shade200, 

                        activeColor: Colors.blue,
                        onChanged: trxC.toggleAntarJemput,
                      ),
                    ],
                  ),

                  if (trxC.isAntarJemput.value) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.orange,
                            title: const Text("Penjemputan", style: TextStyle(fontSize: 14)),
                            value: trxC.isPenjemputan.value,
                            onChanged: (val) => trxC.isPenjemputan.value = val ?? false,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.orange,
                            title: const Text("Pengantaran", style: TextStyle(fontSize: 14)),
                            value: trxC.isPengantaran.value,
                            onChanged: (val) => trxC.isPengantaran.value = val ?? false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Alamat", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: trxC.alamatCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Masukkan Alamat",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true, fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (trxC.deliveryFee.value > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Biaya Ongkir", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text("Rp ${_formatRupiah(trxC.deliveryFee.value)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102A43))),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => trxC.deliveryFee.value = 0, 

                                child: const Text("Hapus Ongkir", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                              )
                            ],
                          )
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => trxC.showOngkirDialog(context),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text("+ Tambah Ongkir", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ]
                ],
              ),
            )),
            const SizedBox(height: 8),

            Container(
              color: Colors.white, padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detail Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  const SizedBox(height: 16),

                  Obx(() => Column(
                    children: trxC.cart.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${item['kategori']} ${item['nama_layanan']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF102A43))),
                                  const SizedBox(height: 4),
                                  Text("Rp ${_formatRupiah(item['harga_satuan'])} • ${item['durasi_jam']} Jam", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue.shade200), 
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (item['kuantitas'] > 1) {
                                        trxC.ubahQtyCart(index, item['kuantitas'] - 1);
                                      } else {
                                        trxC.cart.removeAt(index); 

                                      }
                                    },
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
                                      child: Icon(Icons.remove, size: 16, color: Colors.blue)
                                    ),
                                  ),
                                  Text("${item['kuantitas'].toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF102A43))),
                                  InkWell(
                                    onTap: () => trxC.ubahQtyCart(index, item['kuantitas'] + 1),
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
                                      child: Icon(Icons.add, size: 16, color: Colors.blue)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            Text("Rp ${_formatRupiah(item['subtotal_harga'])}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF102A43))),
                            const SizedBox(width: 12),

                            InkWell(
                              onTap: () => trxC.cart.removeAt(index), 

                              child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )),

                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.add, color: Colors.blue, size: 18),
                    label: const Text("layanan", style: TextStyle(color: Colors.blue, fontSize: 16)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              color: Colors.white, 
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Tambahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: trxC.catatanCtrl, 
                    maxLines: 2, 
                    decoration: InputDecoration(
                      hintText: "Misalnya : Celana jeans luntur",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}