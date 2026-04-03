import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/pembayaran_view.dart';
import '../controllers/detail_pesanan_controller.dart';

class DetailPesananView extends StatelessWidget {
  DetailPesananView({super.key});

  final DetailPesananController detailC = Get.put(DetailPesananController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF102A43)), onPressed: () => Get.back()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20)),
            const SizedBox(width: 8),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF2196F3)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.print_outlined, color: Color(0xFF2196F3)), onPressed: () {}),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("BATAL", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("SELESAIKAN PROSES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), color: Colors.white,
              child: const Text("Antrian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
            ),
            const Divider(height: 1, thickness: 1),

            Container(
              color: Colors.white, padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TRX/260402/004", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      Text("02/04/2026 13:28:17", style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue, size: 30)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ggg", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                            Text("+6285753556422", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400),
                      const SizedBox(width: 16),
                      Icon(Icons.phone, color: Colors.grey.shade400),
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
                child: Obx(() => ExpansionTile(
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
                              ? Text(detailC.alamatCtrl.text.isEmpty ? "Alamat tersimpan" : detailC.alamatCtrl.text, style: const TextStyle(color: Colors.black87))
                              : Text("Belum ada pengantaran", style: TextStyle(color: Colors.grey.shade700)),
                          detailC.isPengantaranSaved.value
                              ? IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                                  onPressed: () => _showTambahPengantaranBottomSheet(), 
                                )
                              : ElevatedButton(
                                  onPressed: () => _showTambahPengantaranBottomSheet(), 
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text("+ Pengantaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                )
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Tagihan", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(height: 4),
                            Text("15.000", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => _showModalDetailTagihan(), 
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
                              child: const Text("DETAIL")
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {Get.to(() => PembayaranView());}, 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), 
                              child: const Text("BAYAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Column(
                children: const [
                  Text("Est. Selesai", style: TextStyle(color: Colors.black54, fontSize: 13)),
                  SizedBox(height: 4),
                  Text("02/04/2026 21:28:17", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              color: Colors.white, padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Detail Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                      TextButton(onPressed: () {}, child: const Text("Edit", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12), 
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), 
                        child: const Icon(Icons.checkroom, color: Colors.blue, size: 32)
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Kiloan Express", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102A43))),
                            SizedBox(height: 4),
                            Text("1.0 Kg", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              color: Colors.white, 
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Informasi Tambahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  SizedBox(height: 16),
                  Text("Tidak Ada", style: TextStyle(color: Colors.black87, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showModalDetailTagihan() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),

            const Text("Total Tagihan", style: TextStyle(color: Colors.grey)),
            const Text("30,080", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Obx(() => Column(
              children: [
                GestureDetector(
                  onTap: () => detailC.toggleDetailTagihan(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Detail Tagihan", style: TextStyle(color: Colors.black54, fontSize: 15)),
                      Icon(detailC.isDetailTagihanExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
                if (detailC.isDetailTagihanExpanded.value) ...[
                  const SizedBox(height: 12),
                  _rowRincian("Subtotal", "15,000", isBold: true),
                  _rowRincian("Kiloan Express x 1.0 Kg", "15,000", isSub: true),
                  const SizedBox(height: 8),
                  _rowRincian("Ongkir", "15,080", isBold: true),
                  _rowRincian("Jarak : - Km", "", isSub: true),
                ]
              ],
            )),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Obx(() => Column(
              children: [
                GestureDetector(
                  onTap: () => detailC.toggleDetailPembayaran(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Detail Pembayaran", style: TextStyle(color: Colors.black54, fontSize: 15)),
                      Icon(detailC.isDetailPembayaranExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
                if (detailC.isDetailPembayaranExpanded.value) ...[
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft, 
                    child: Text("Belum ada pembayaran", style: TextStyle(color: Colors.grey, fontSize: 13))
                  ),
                ]
              ],
            )),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600, 
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                child: const Text("PREVIEW NOTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _rowRincian(String label, String value, {bool isBold = false, bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.only(left: isSub ? 16 : 0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: isSub ? 12 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
            color: isBold ? Colors.black87 : Colors.grey.shade600
          )),
          if (value.isNotEmpty) Text(value, style: TextStyle(
            fontSize: isSub ? 13 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal
          )),
        ],
      ),
    );
  }

  void _showTambahPengantaranBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
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
                Obx(() => Text(detailC.isPengantaranSaved.value ? "Ubah Pengantaran" : "Tambah Pengantaran", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)))),
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
                          detailC.ongkir.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => detailC.hapusOngkir(),
                          child: const Text("Hapus Ongkir", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
                        )
                      ],
                    ),
                  ],
                );
              }
            }),
            const SizedBox(height: 32),

            Obx(() {
              if (detailC.isPengantaranSaved.value) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => detailC.batalkanPengantaran(), 
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
                        onPressed: () => Get.back(), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => detailC.konfirmasiSimpanPengantaran(), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
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
                      onPressed: () => detailC.simpanOngkir(),
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    int value = int.parse(cleanText);
    String formatted = value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return newValue.copyWith(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}