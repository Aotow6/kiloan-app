import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/views/pembayaran_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/detail_pesanan_controller.dart';
import '../controllers/pesanan_controller.dart';
import '../controllers/pembayaran_controller.dart'; 

class DetailPesananView extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailPesananView({super.key, required this.data});

  final DetailPesananController detailC = Get.put(DetailPesananController());
  final PesananController pesananC = Get.put(PesananController());

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    detailC.initData(data);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: detailC.isDataChanged);
        return false; 
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), 
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), 
            onPressed: () {
              Get.back(result: detailC.isDataChanged);
            }
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
             Image.asset(
                    'assets/images/app.png',
                    height: 32,
                    width: 32,
                  ),              const SizedBox(width: 8),
              const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          centerTitle: true,
        ),

        bottomNavigationBar: Obx(() {
          final Map<String, dynamic> h = Map<String, dynamic>.from(
            detailC.headerData.isEmpty ? data : detailC.headerData
          );

          bool isLocked = h['status_pesanan'].toString().toLowerCase() == 'diambil' || h['status_pesanan'].toString().toLowerCase() == 'batal';
          bool isBatal = h['status_pesanan'].toString().toLowerCase() == 'batal';
          bool isLunas = h['status_pembayaran'].toString().toLowerCase() == 'lunas';
          bool isBon = h['status_pembayaran'].toString().toLowerCase() == 'bon';

          bool isOwner = pesananC.isOwner;

          return Container(

            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                if (isBatal) ...[

                  if (isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => pesananC.hapusTransaksiPermanen(h['id']),
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        label: const Text("HAPUS TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(30)),
                      child: Center(child: Text("Pesanan DIBATALKAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700))),
                    )
                ] else ...[

                  if (!isLunas || isBon) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isBon) {
                             final payC = Get.put(PembayaranController());
                             payC.totalTagihan.value = h['total_tagihan'] ?? 0;
                             payC.idTransaksi.value = h['id'] ?? 0;
                             payC.idCustomer.value = h['customer_id'] ?? 0;
                             Get.to(() => PembayaranView());
                          } else {
                            Get.bottomSheet(
                              Container(

                                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
                                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Pilih Metode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back(); 
                                          final payC = Get.put(PembayaranController());
                                          payC.totalTagihan.value = h['total_tagihan'] ?? 0;
                                          payC.idTransaksi.value = h['id'] ?? 0;
                                          payC.idCustomer.value = h['customer_id'] ?? 0;
                                          Get.to(() => PembayaranView());
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                                        child: const Text("Bayar Lunas Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                      SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Get.defaultDialog(
                                            title: "Jadikan Bon?",
                                            middleText: "Tagihan Rp ${_formatRupiah(h['total_tagihan'] ?? 0)} akan masuk ke hutang pelanggan.",
                                            textConfirm: "Ya, Jadikan Bon",
                                            confirmTextColor: Colors.white,
                                            textCancel: "Batal",
                                            onConfirm: () {
                                              detailC.prosesJadikanBon(h['id'], h['customer_id'], h['total_tagihan']);
                                            }
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange), padding: const EdgeInsets.symmetric(vertical: 14)),
                                        child: const Text("Masukkan Ke Kasbon", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            );
                          }
                        },
                        icon: const Icon(Icons.payments_outlined, color: Colors.white),
                        label: Text(isBon ? "LUNASI BON (HUTANG)" : "PROSES PEMBAYARAN", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBon ? Colors.orange.shade700 : const Color(0xFFFF9800),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (!isLocked) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => pesananC.batalkanPesanan(h['id'], isLunas, h['total_dibayar']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("BATALKAN PESANAN", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if(h['status_pesanan'].toString().toLowerCase() == 'proses') {
                             detailC.updateStatus(h['id'], 'selesai');
                          } else if (h['status_pesanan'].toString().toLowerCase() == 'selesai') {

                             if (!isLunas && !isBon) {
                               Get.snackbar(
                                 "Tahan Dulu!", 
                                 "Pesanan belum dibayar. Silakan proses pembayaran atau jadikan Kasbon (Bon) terlebih dahulu sebelum barang diambil.",
                                 backgroundColor: Colors.red.shade700,
                                 colorText: Colors.white,
                                 duration: const Duration(seconds: 4),
                               );
                               return; 
                             }

                             detailC.updateStatus(h['id'], 'diambil');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: h['status_pesanan'].toString().toLowerCase() == 'selesai' ? Colors.green : const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(h['status_pesanan'].toString().toLowerCase() == 'selesai' ? "SUDAH DIAMBIL" : "SELESAIKAN PROSES", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ] else if (isLocked && !isBon) ...[
                     Container(
                       width: double.infinity,
                       padding: const EdgeInsets.symmetric(vertical: 14),
                       decoration: BoxDecoration(
                         color: Colors.grey.shade200,
                         borderRadius: BorderRadius.circular(30)
                       ),
                       child: Center(
                         child: Text("Pesanan ${h['status_pesanan'].toString().toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                       ),
                     )
                  ]
                ]
              ],
            ),
          );
        }),

        body: Obx(() {
          if (detailC.isLoading.value && detailC.listItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, dynamic> h = Map<String, dynamic>.from(
            detailC.headerData.isEmpty ? data : detailC.headerData
          );

          bool isLocked = h['status_pesanan'].toString().toLowerCase() == 'diambil' || h['status_pesanan'].toString().toLowerCase() == 'batal';
          bool isLunas = h['status_pembayaran'].toString().toLowerCase() == 'lunas';
          bool isBon = h['status_pembayaran'].toString().toLowerCase() == 'bon';

          bool isLogistikLocked = isLocked || isLunas || isBon; 

          String tglMasuk = h['waktu_masuk'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(h['waktu_masuk']))
              : "-";
          String estSelesai = h['estimasi_selesai'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(h['estimasi_selesai']))
              : "-";
          String noWa = h['customers']?['no_wa'] ?? '';
          bool hasWa = noWa.isNotEmpty && noWa.toLowerCase() != "tanpa nomor";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status: ${h['status_pesanan'].toString().toUpperCase()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLunas ? Colors.green : (isBon ? Colors.orange : Colors.red.shade700),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(h['status_pembayaran'] ?? "Belum Lunas", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),                 
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                Container(
                  color: Colors.white, padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(h['nomor_nota'] ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                          Text(tglMasuk, style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(radius: 24, backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue, size: 30)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h['customers']?['nama_pelanggan'] ?? "Pelanggan", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                                Text(noWa.isEmpty ? "Tanpa Nomor" : noWa, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                               if (hasWa)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 28), 
                                  onPressed: () {
                                    detailC.kirimNotaWA(
                                      transaksi: h,
                                      namaCustomer: h['customers']?['nama_pelanggan'] ?? '',
                                      noWa: noWa,
                                    );
                                  }
                                ),
                              IconButton(
                                icon: const Icon(Icons.print_outlined, color: Color(0xFF2196F3), size: 28), 
                                onPressed: () {
                                  detailC.cetakNotaPDF(h);
                                }
                              ),
                            ]
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  color: Colors.white,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent), 
                    child: ExpansionTile(
                      initiallyExpanded: detailC.isAntarJemputExpanded.value, 
                      onExpansionChanged: (val) => detailC.isAntarJemputExpanded.value = val,
                      title: const Text("Informasi Antar/Jemput", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              detailC.isPengantaranSaved.value 
                                  ? Expanded(child: Text(detailC.alamatCtrl.text.isEmpty ? "Alamat tersimpan" : detailC.alamatCtrl.text, style: const TextStyle(color: Colors.black87)))
                                  : Text("Belum ada pengantaran/jemputan", style: TextStyle(color: Colors.grey.shade700)),
                              detailC.isPengantaranSaved.value
                                  ? IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                                      onPressed: isLogistikLocked ? null : () => _showTambahPengantaranBottomSheet(context, h, h['status_pesanan']), 

                                    )
                                  : ElevatedButton(
                                      onPressed: isLogistikLocked ? null : () => _showTambahPengantaranBottomSheet(context, h, h['status_pesanan']), 

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text("+ Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Detail Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),

                          if (!isLogistikLocked) 
                            TextButton(
                              onPressed: () async {
                                await detailC.goToEditLayanan(h);
                                detailC.fetchDetailItems(h['id'], h['catatan']);
                                detailC.isDataChanged = true; 
                              }, 
                              child: const Text("Edit", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14))
                            )
                        ],
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: detailC.listItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12), 
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), 
                                  child: const Icon(Icons.checkroom, color: Colors.blue, size: 28)
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${item['services']?['nama_layanan'] ?? 'Layanan'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102A43))),
                                      const SizedBox(height: 4),
                                      Text("${item['kuantitas']} ${item['services']?['satuan'] ?? 'Pcs'} x Rp ${_formatRupiah(item['services']?['harga'] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Text("Rp ${_formatRupiah(item['subtotal_harga'])}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102A43))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           const Text("Total Tagihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                           Text("Rp ${_formatRupiah(h['total_tagihan'] ?? 0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text("Est. Selesai", style: TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(estSelesai, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  color: Colors.white, 
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Informasi Tambahan (Catatan)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      const SizedBox(height: 16),
                      TextField(
                        controller: detailC.catatanEditCtrl,
                        maxLines: 2,
                        readOnly: isLocked,
                        decoration: InputDecoration(
                          hintText: "Misalnya : Celana jeans luntur",
                          filled: true, fillColor: isLocked ? Colors.grey.shade200 : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => detailC.simpanCatatan(h['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Simpan Catatan"),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      )
    );
  }

  void _showTambahPengantaranBottomSheet(BuildContext context, Map<String, dynamic> h, String statusP) {

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    Get.bottomSheet(
      Container(

        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(detailC.isPengantaranSaved.value ? "Ubah Logistik" : "Tambah Logistik", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            const Text("Alamat", style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: detailC.alamatCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukkan Alamat",
                filled: true, fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24), 

            Obx(() {
              int subtotalLayanan = (h['total_tagihan'] ?? 0) - (h['delivery_fee'] ?? 0);

              if (detailC.ongkir.value == 0) {
                return GestureDetector(
                  onTap: () => _showDialogTambahOngkir(), 
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("+ Tambah Ongkir", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Biaya Ongkir", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Rp ${_formatRupiah(detailC.ongkir.value)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => detailC.hapusOngkir(),
                          child: const Text("Hapus Ongkir", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (detailC.isPengantaranSaved.value) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => detailC.batalkanPengantaran(h['id'], subtotalLayanan), 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB71C1C), 
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text("Batalkan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: detailC.isLoading.value ? null : () {
                                 detailC.konfirmasiSimpanPengantaran(h['id'], subtotalLayanan);
                              }, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: detailC.isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      )
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: detailC.isLoading.value ? null : () {
                             detailC.konfirmasiSimpanPengantaran(h['id'], subtotalLayanan);
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: detailC.isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                        ),
                      )
                    ]
                  ],
                );
              }
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDialogTambahOngkir() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tambah Ongkir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 24),
              TextField(
                controller: detailC.ongkirCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyFormat(), 
                ],
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  filled: true, fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3), side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         detailC.simpanOngkir(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
}

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.text.isEmpty) return newV.copyWith(text: '');
    String clean = newV.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return newV.copyWith(text: '');
    int value = int.parse(clean);
    String formatted = value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return newV.copyWith(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}