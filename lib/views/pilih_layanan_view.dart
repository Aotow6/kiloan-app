import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/layanan_controller.dart';
import '../controllers/transaksi_controller.dart';
import 'konfirmasi_pesanan_view.dart';

class PilihLayananView extends StatefulWidget {
  final String namaCustomer;
  final int idCustomer;
  final String noHp;

  const PilihLayananView({
    super.key,
    required this.namaCustomer,
    required this.idCustomer,
    this.noHp = "",
  });

  @override
  State<PilihLayananView> createState() => _PilihLayananViewState();
}

class _PilihLayananViewState extends State<PilihLayananView> {

  late final LayananController layC;
  late final TransaksiController trxC;

  @override
  void initState() {
    super.initState();

    layC = Get.isRegistered<LayananController>()
        ? Get.find<LayananController>()
        : Get.put(LayananController());

    trxC = Get.isRegistered<TransaksiController>()
        ? Get.find<TransaksiController>()
        : Get.put(TransaksiController());
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

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
          style: TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: Obx(() {
        if (trxC.cart.isEmpty) return const SizedBox.shrink();

        int totalTagihan = 0;
        for (var item in trxC.cart) {
          int qty = (item['kuantitas'] ?? 0).toInt(); 
          int harga = (item['harga_satuan'] ?? 0) as int;
          totalTagihan += (qty * harga);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Tagihan",
                      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(
                    "Rp ${_formatRupiah(totalTagihan)}",
                    style: TextStyle(
                        color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => KonfirmasiPesananView(
                        namaCustomer: widget.namaCustomer,
                        idCustomer: widget.idCustomer.toString(),
                        phoneCustomer: widget.noHp,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Buat Transaksi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => layC.searchQuery.value = val, 

              decoration: InputDecoration(
                hintText: "Pencarian",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(

            child: Obx(() {

              var groupedServices = layC.groupedServices;

              if (layC.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (groupedServices.isEmpty) {
                return const Center(child: Text("Layanan tidak ditemukan"));
              }

              return ListView.builder(
                itemCount: groupedServices.length,
                itemBuilder: (context, i) {
                  String kategori = groupedServices.keys.elementAt(i);
                  List<Map<String, dynamic>> services = groupedServices[kategori]!;
                  bool isExpanded = layC.expandedCategories[kategori] ?? true;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          layC.expandedCategories[kategori] = !isExpanded;
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Text(
                                kategori.capitalizeFirst ?? kategori,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF102A43),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        ...services.map(
                          (service) => _buildServiceItem(context, service, kategori),
                        ),
                    ],
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
      BuildContext context, Map<String, dynamic> service, String kategori) {
    final String hargaFormat = _formatRupiah(service['harga'] as int);
    final int jam = service['durasi_jam'] as int;
    final String durasiText =
        jam >= 24 && jam % 24 == 0 ? "${jam ~/ 24} Hari" : "$jam Jam";
    final int serviceId = int.tryParse(service['id'].toString()) ?? 0;

    IconData getIcon() {
      String kat = kategori.toLowerCase();
      if (kat.contains("kiloan")) return FontAwesomeIcons.shirt;
      if (kat.contains("bed")) return FontAwesomeIcons.bed;
      if (kat.contains("sepatu")) return FontAwesomeIcons.shoePrints;
      if (kat.contains("boneka")) return FontAwesomeIcons.paw;
      return FontAwesomeIcons.box;
    }

    return Obx(() {
      int cartIndex = trxC.cart.indexWhere((e) => e['service_id'] == serviceId);

      final bool inCart = cartIndex != -1;
      final int qty = inCart ? (trxC.cart[cartIndex]['kuantitas'] as double).toInt() : 0;
      final int subtotal = inCart ? trxC.cart[cartIndex]['subtotal_harga'] as int : 0;
      final Map<String, dynamic> cartItem = inCart ? trxC.cart[cartIndex] : {};

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: FaIcon(getIcon(), color: Colors.blueGrey, size: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['nama_layanan']
                            .toString()
                            .split(' ')
                            .map((w) => w.capitalizeFirst)
                            .join(' '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102A43),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${kategori.capitalizeFirst} • $durasiText",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Rp $hargaFormat/${service['satuan']}",
                        style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: (!inCart)
                  ? _qtyEmpty(service)
                  : _qtyFilled(service, qty, subtotal, cartIndex, cartItem),
            ),

            const SizedBox(height: 10),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          ],
        ),
      );
    });
  }

  Widget _qtyEmpty(Map<String, dynamic> service) {
    return InkWell(
      onTap: () {
        trxC.addOrUpdateCart(service, 1.0, "");
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text("0",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.0,
                    color: Color(0xFF102A43))),
            SizedBox(width: 8),
            Icon(Icons.add, color: Colors.blue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _qtyFilled(
    Map<String, dynamic> service,
    int qty,
    int subtotal,
    int index,
    Map<String, dynamic> cartItem,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (qty > 1) {
                    trxC.ubahQtyCart(index, (qty - 1).toDouble());
                  } else {
                    trxC.cart.removeAt(index);
                  }
                },
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(Icons.remove, color: Colors.blue, size: 16),
                ),
              ),
              Text("$qty",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.0,
                      color: Color(0xFF102A43))),
              InkWell(
                onTap: () {
                  trxC.ubahQtyCart(index, (qty + 1).toDouble());
                },
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(Icons.add, color: Colors.blue, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "Rp ${_formatRupiah(subtotal)}",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
              fontSize: 14),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
             trxC.cart.removeAt(index);
          },
          child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
        ),
      ],
    );
  }
}