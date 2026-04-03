import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/views/home_view.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/header_curve.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController authC = Get.put(AuthController());

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
                  const SizedBox(height: 20),
                  const Text(
                    "Login sebagai :",
                    style: TextStyle(fontSize: 16, color: Color(0xFF102A43)),
                  ),
                  const SizedBox(height: 8),

                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => authC.isPemilik.value = true,
                        child: Text(
                          "PEMILIK",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: authC.isPemilik.value ? FontWeight.bold : FontWeight.normal,
                            color: authC.isPemilik.value ? const Color(0xFF2196F3) : Colors.grey,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("|", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                      GestureDetector(
                        onTap: () => authC.isPemilik.value = false,
                        child: Text(
                          "PEGAWAI",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: !authC.isPemilik.value ? FontWeight.bold : FontWeight.normal,
                            color: !authC.isPemilik.value ? const Color(0xFF2196F3) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 30), 
                  CustomTextField(
                    hintText: 'Email', 
                    prefixIcon: Icons.email_outlined,
                    controller: authC.emailLoginCtrl,
                  ),
                  CustomTextField(
                    hintText: 'Kata Sandi', 
                    isPassword: true, 
                    prefixIcon: Icons.lock_outline,
                    controller: authC.passwordLoginCtrl,
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Lupa Password ?', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: () => Get.to(() => HomeView()),// authC.login(), 

                      child: const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun ? "),
                      GestureDetector(

                        onTap: () => Get.to(() => RegisterView()),
                        child: const Text("DAFTAR SEKARANG", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
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