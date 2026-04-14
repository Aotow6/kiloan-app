import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/pelanggan_controller.dart';

class DetailPelangganView extends StatelessWidget {
  final String nama;
  final String phone;
  final int id; 

  DetailPelangganView({super.key, required this.nama, required this.phone, required this.id});

  final PelangganController pelC = Get.find<PelangganController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
        title: Text(nama, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [

          IconButton(
            onPressed: () => pelC.setEditMode(nama, phone, id), 
            icon: const Icon(Icons.settings_outlined, color: Colors.black54)
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSectionCard(
                  title: "Profil & Kontak",
                  titleColor: Colors.orange.shade700,
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.phone_android, phone),
                      const SizedBox(height: 12),

                      _buildInfoRow(Icons.person, nama),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                      const SizedBox(width: 15),
                      Icon(Icons.phone, color: Colors.red.shade400),
                    ],
                  ),
                ),

                _buildSectionCard(
                  title: "Data Keuangan",
                  titleColor: Colors.orange.shade700,
                  child: Row(
                    children: [
                      _buildFinancialItem("Kasbon", "0"),
                      const VerticalDivider(thickness: 1, color: Colors.grey),
                      _buildFinancialItem("Piutang", "0"),
                    ],
                  ),
                ),

                _buildSectionCard(
                  title: "Data Transaksi",
                  titleColor: Colors.orange.shade700,
                  child: Column(
                    children: [
                      _buildTransactionRow("Total Nominal", "0", isBold: true),
                      _buildTransactionRow("Total Transaksi", "0 Transaksi", valueColor: Colors.blue),
                      _buildTransactionRow("Total Transaksi Produk", "0 Transaksi", valueColor: Colors.blue),
                      _buildTransactionRow("Total Dibatalkan", "0 Transaksi", valueColor: Colors.blue),
                      _buildTransactionRow("Total Rincian", "0.0 Kg / 0 Satuan", valueColor: Colors.blue),
                      const Divider(),
                      _buildTransactionRow("Transaksi Pertama", "-"),
                      _buildTransactionRow("Transaksi Terakhir", "-"),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right),
                        ],
                      )
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 100),
                  child: TextButton.icon(
                    onPressed: () => pelC.hapusPelanggan(id, nama, dariDetail: true),
                    icon: const Icon(Icons.delete, color: Colors.red), 
                    label: const Text("Hapus Pelanggan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                )
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("BUAT TRANSAKSI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Color titleColor, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildFinancialItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          )),
        ],
      ),
    );
  }
}