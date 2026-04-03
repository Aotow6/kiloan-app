import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 

import 'package:get/get.dart';
import 'package:laundry_app/views/kelola_layanan_view.dart';
import 'package:laundry_app/views/kelola_pegawai_view.dart';
import 'package:laundry_app/views/kelola_pelanggan_view.dart';
import 'package:laundry_app/views/outlet_view.dart';
import 'package:laundry_app/views/profil_view.dart';
import '../controllers/home_controller.dart';
import '../controllers/pengaturan_controller.dart';
import 'widgets/navbar.dart';

class PengaturanView extends StatelessWidget {
  PengaturanView({super.key});

  final PengaturanController pengC = Get.put(PengaturanController());
  final HomeController homeC = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeC.changeBottomNav(3); 
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4), 
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), 
              child: const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 24)
            ),
            const SizedBox(width: 10),
            const Text("kiloan", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Color(0xFF2196F3), size: 28), onPressed: () {}),
        ],
      ),

      bottomNavigationBar: CustomBottomNav(),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: const FaIcon(FontAwesomeIcons.solidUser, color: Colors.grey, size: 30),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("raya laundry", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [

                  _buildMenuItem(
                    icon: FontAwesomeIcons.userTie, 
                    title: "Profil Pemilik", 
                    subtitle: "Data diri pemilik laundry", 
                    iconColor: Colors.blue.shade700,
                    onTap: () {Get.to(() => ProfilView());}
                  ),
                  _divider(),

                  _buildMenuItem(
                    icon: FontAwesomeIcons.store, 
                    title: "Edit Profil", 
                    subtitle: "Edit nama outlet, alamat, jam operasional", 
                    iconColor: Colors.teal.shade500,
                    onTap: () {Get.to(() => OutletView());}
                  ),
                  _divider(),

                  _buildMenuItem(
                    icon: FontAwesomeIcons.users, 
                    title: "Pelanggan Saya", 
                    subtitle: "Daftar pelanggan yang terdaftar di outlet", 
                    iconColor: Colors.lightBlue.shade600,
                    onTap: () {Get.to(() => KelolaPelangganView());}
                  ),
                  _divider(),

                  _buildMenuItem(
                    icon: FontAwesomeIcons.shirt, 
                    title: "Kelola Layanan/Produk", 
                    subtitle: "Tambah, edit, hapus layanan dan produk laundry", 
                    iconColor: Colors.cyan.shade600,
                    onTap: () {Get.to(() => KelolaLayananView());}
                  ),
                  _divider(),

                  _buildMenuItem(
                    icon: FontAwesomeIcons.userGear, 
                    title: "Kelola Pegawai", 
                    subtitle: "Daftar pegawai. Tambah, edit, nonaktifkan pegawai", 
                    iconColor: Colors.indigo.shade500,
                    onTap: () {Get.to(() => KelolaPegawaiView());}
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => pengC.konfirmasiLogout(),
                  icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 18, color: Color(0xFFB71C1C)),
                  label: const Text("Keluar Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), 

          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [

            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: FaIcon(icon, color: iconColor, size: 22)),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 84, right: 20), 

      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
    );
  }
}