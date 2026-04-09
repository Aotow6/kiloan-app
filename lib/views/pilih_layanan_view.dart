import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/transaksi_controller.dart';
import 'konfirmasi_pesanan_view.dart';

class PilihLayananView extends StatelessWidget {
  final String namaCustomer;
  final int idCustomer; // ✅ FIX: harus int
  final String noHp;    // ✅ TAMBAHAN

  PilihLayananView({
    super.key,
    required this.namaCustomer,
    required this.idCustomer,
    this.noHp = "", // ✅ default biar aman
  });

  final TransaksiController trxC = Get.put(TransaksiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Pilih Layanan",
          style: TextStyle(
              color: Color(0xFF102A43), fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: Obx(() {
        if (trxC.cart.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5))
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.to(() => KonfirmasiPesananView(
                  namaCustomer: namaCustomer,
                  idCustomer: idCustomer.toString(), // ✅ convert ke string kalau view berikutnya masih String
                  phoneCustomer: noHp, // ✅ kirim nomor asli
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              "Lanjutkan ${trxC.totalItem} Layanan",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
          ),
        );
      }),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => trxC.layC.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Pencarian",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              var groupedServices = trxC.layC.groupedServices;

              if (groupedServices.isEmpty) {
                return const Center(
                    child: Text("Layanan tidak ditemukan"));
              }

              return ListView.builder(
                itemCount: groupedServices.length,
                itemBuilder: (context, index) {
                  String kategori =
                      groupedServices.keys.elementAt(index);
                  List<Map<String, dynamic>> services =
                      groupedServices[kategori]!;

                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      kategori,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    children: services
                        .map((service) =>
                            _buildServiceItem(context, service))
                        .toList(),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context, Map<String, dynamic> service) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.shirt,
                  color: Colors.blueGrey, size: 24),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['nama_layanan']),
                Text("Rp ${service['harga']}"),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () => _showDialog(context, service),
            child: const Text("Tambah"),
          )
        ],
      ),
    );
  }

  void _showDialog(
      BuildContext context, Map<String, dynamic> service) {
    var qty = 1.0.obs;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(service['nama_layanan']),
              const SizedBox(height: 20),

              Obx(() => Text("Qty: ${qty.value.toInt()}")),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (qty.value > 1) qty.value--;
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () {
                      qty.value++;
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  trxC.addOrUpdateCart(service, qty.value, "");
                  Get.back();
                },
                child: const Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}