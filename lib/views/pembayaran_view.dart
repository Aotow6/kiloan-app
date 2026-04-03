import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/pembayaran_controller.dart';

class PembayaranView extends StatelessWidget {
  PembayaranView({super.key});

  final PembayaranController payC = Get.put(PembayaranController());

  final List<Map<String, dynamic>> listBank = [
    {"nama": "BCA", "color": Colors.blue.shade900},
    {"nama": "BRI", "color": Colors.blue.shade700},
    {"nama": "BNI", "color": Colors.orange.shade900},
    {"nama": "MANDIRI", "color": Colors.blue.shade800},
  ];

  final List<Map<String, dynamic>> listEwallet = [
    {"nama": "GoPay", "color": Colors.blue},
    {"nama": "OVO", "color": Colors.purple},
    {"nama": "DANA", "color": Colors.blue.shade400},
    {"nama": "ShopeePay", "color": Colors.deepOrange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Get.back()),
        title: const Text("Transaksi Bayar", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: Obx(() {
          bool canPay = false;

          if (payC.selectedTab.value == 0 && payC.uangDiterima.value >= payC.totalTagihan.value) canPay = true;
          if ((payC.selectedTab.value == 1 || payC.selectedTab.value == 2) && payC.selectedMethod.value != "") canPay = true;

          return ElevatedButton(
            onPressed: canPay ? () => payC.prosesBayar() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canPay ? const Color(0xFF2196F3) : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Selesaikan Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          );
        }),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Tagihan", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(payC.formatRupiah(payC.totalTagihan.value), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => payC.jadikanBon(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text("Jadikan Bon", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem("Tunai", 0),
                _buildTabItem("Non Tunai", 1),
                _buildTabItem("E-Wallet", 2),
              ],
            )),
          ),

          Expanded(
            child: Obx(() {
              if (payC.selectedTab.value == 0) return _buildTabTunai();
              if (payC.selectedTab.value == 1) return _buildListMethod(listBank);
              return _buildListMethod(listEwallet);
            }),
          )
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isSel = payC.selectedTab.value == index;
    return GestureDetector(
      onTap: () => payC.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSel ? Colors.blue : Colors.transparent, width: 3))),
        child: Text(label, style: TextStyle(color: isSel ? Colors.blue : Colors.grey, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildTabTunai() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Uang Diterima", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          TextField(
            controller: payC.uangDiterimaCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyFormat()],
            onChanged: (v) => payC.updateUangDiterima(v),
            decoration: InputDecoration(
              prefixText: "Rp ", prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              filled: true, fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _btnQuick("Uang Pas", payC.totalTagihan.value)),
              const SizedBox(width: 8),
              Expanded(child: _btnQuick("50.000", 50000)),
              const SizedBox(width: 8),
              Expanded(child: _btnQuick("100.000", 100000)),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kembalian", style: TextStyle(fontSize: 18, color: Colors.grey)),
              Obx(() => Text("Rp ${payC.formatRupiah(payC.kembalian)}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green))),
            ],
          )
        ],
      ),
    );
  }

  Widget _btnQuick(String label, int val) {
    return OutlinedButton(
      onPressed: () => payC.setUangCepat(val),
      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildListMethod(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, i) {
        String name = items[i]["nama"];
        return Obx(() {
          bool isSelected = payC.selectedMethod.value == name;
          return GestureDetector(
            onTap: () => payC.selectedMethod.value = name,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 2),
                color: isSelected ? Colors.blue.shade50 : Colors.white,
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: items[i]["color"], radius: 15, child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 16),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.blue)
                ],
              ),
            ),
          );
        });
      },
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