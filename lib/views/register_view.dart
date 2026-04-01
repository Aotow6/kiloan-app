import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/header_curve.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderCurve(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text("Daftar Toko Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF102A43))),
                  const SizedBox(height: 20),

                  CustomTextField(hintText: 'Nama Lengkap', prefixIcon: Icons.person_outline, controller: authC.namaLengkapCtrl),
                  CustomTextField(hintText: 'Nama Laundry', prefixIcon: Icons.storefront_outlined, controller: authC.namaLaundryCtrl),
                  CustomTextField(hintText: 'Email', prefixIcon: Icons.email_outlined, controller: authC.emailRegisCtrl),
                  CustomTextField(hintText: 'Password', isPassword: true, prefixIcon: Icons.lock_outline, controller: authC.passwordRegisCtrl),
                  CustomTextField(hintText: 'Konfirmasi Password', isPassword: true, prefixIcon: Icons.lock_outline, controller: authC.confirmPasswordCtrl),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: () => authC.register(), 

                      child: const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun ? "),
                      GestureDetector(

                        onTap: () => Get.back(),
                        child: const Text("MASUK", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}