import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/transaksi_controller.dart';
import 'konfirmasi_pesanan_view.dart';

class PilihLayananView extends StatelessWidget {
  final String namaCustomer;
  final String idCustomer;

  PilihLayananView({super.key, required this.namaCustomer, required this.idCustomer});

  final TransaksiController trxC = Get.put(TransaksiController());

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedServices = {};
    for (var service in trxC.listServices) {
      String kat = service['kategori'] as String;
      if (!groupedServices.containsKey(kat)) groupedServices[kat] = [];
      groupedServices[kat]!.add(service);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: const Text("Pilih Layanan", style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold)),
      ),
      
      bottomNavigationBar: Obx(() {
        if (trxC.cart.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
          child: ElevatedButton(
            onPressed: () => Get.to(() => KonfirmasiPesananView(namaCustomer: namaCustomer, idCustomer: idCustomer,phoneCustomer: "08123456789")),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2), padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("Lanjutkan ${trxC.totalItem} Layanan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        );
      }),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Pencarian", prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: groupedServices.length,
              itemBuilder: (context, index) {
                String kategori = groupedServices.keys.elementAt(index);
                List<Map<String, dynamic>> services = groupedServices[kategori]!;

                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true, 
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kategori, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                        Text("Cuci • Kering", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    children: services.map((service) => _buildServiceItem(context, service, kategori)).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, Map<String, dynamic> service, String kategori) {
    int jam = service['durasi_jam'];
    String estimasiText = jam >= 24 && jam % 24 == 0 ? "${jam ~/ 24} Hari" : "$jam Jam";
    String satuanText = kategori.toLowerCase().contains("kiloan") ? "Kg" : "Satuan";
    String hargaFormat = service['harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: FaIcon(FontAwesomeIcons.bed, color: Colors.brown, size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['nama_layanan'].toString(), style: const TextStyle(fontSize: 16, color: Color(0xFF102A43))),
                const SizedBox(height: 4),
                Text(hargaFormat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                const SizedBox(height: 4),
                Text("$estimasiText • $satuanText", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          
          Obx(() {
            var cartItem = trxC.getCartItem(service['id']);
            if (cartItem == null) {
              return ElevatedButton(
                onPressed: () => _showAddEditDialog(context, service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            } else {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showAddEditDialog(context, service, existingItem: cartItem),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF1976D2), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDetailBottomSheet(context, service, cartItem, kategori),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                      child: Text("${cartItem['kuantitas'].toInt()} items", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            }
          })
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, Map<String, dynamic> service, {Map<String, dynamic>? existingItem}) {
    var qty = (existingItem != null ? existingItem['kuantitas'] as double : 1.0).obs;
    var noteCtrl = TextEditingController(text: existingItem != null ? existingItem['keterangan'] : "");
    var totalHarga = (0).obs;

    void updateTotal() => totalHarga.value = (service['harga'] * qty.value).toInt();
    updateTotal(); 

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tambah Layanan Satuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  InkWell(onTap: () => Get.back(), child: const Icon(Icons.close, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${service['kategori']} ${service['nama_layanan']}".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                        const SizedBox(height: 4),
                        Text("${service['harga']}", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: Colors.blue), onPressed: () { if (qty.value > 1) { qty.value--; updateTotal(); } }),
                      Container(
                        width: 50, height: 35, alignment: Alignment.center,
                        decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(20)),
                        child: Obx(() => Text("${qty.value.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      IconButton(icon: const Icon(Icons.add, color: Colors.blue), onPressed: () { qty.value++; updateTotal(); }),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text("Keterangan", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  hintText: "Misalnya : Celana jeans luntur",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true, fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => Text("Total Harga : ${totalHarga.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102A43)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (existingItem != null) ...[
                    InkWell(
                      onTap: () { trxC.removeCartItemByServiceId(service['id']); Get.back(); },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { trxC.addOrUpdateCart(service, qty.value, noteCtrl.text); Get.back(); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2), padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0,
                      ),
                      child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, Map<String, dynamic> service, Map<String, dynamic> cartItem, String kategori) {
    String satuanText = kategori.toLowerCase().contains("kiloan") ? "Kg" : "Satuan";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text("${service['kategori']} ${service['nama_layanan']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cartItem['keterangan'].toString().isEmpty ? "Tanpa Keterangan" : cartItem['keterangan'], style: const TextStyle(color: Colors.black87, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("${cartItem['kuantitas']} $satuanText", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
                Text(cartItem['subtotal_harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () { Get.back(); _showAddEditDialog(context, service, existingItem: cartItem); },
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit, color: Colors.blue, size: 18)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () { trxC.removeCartItemByServiceId(service['id']); Get.back(); },
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete, color: Colors.red, size: 18)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0,
                ),
                child: const Text("TAMBAH ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}