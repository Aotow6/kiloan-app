import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
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

                  Obx(() => CustomTextField(
                    hintText: 'Nama Lengkap', 
                    prefixIcon: Icons.person_outline, 
                    controller: authC.namaLengkapCtrl,
                    errorText: authC.errNamaLengkap.value,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
                      LengthLimitingTextInputFormatter(30),
                    ],
                  )),
                  Obx(() => CustomTextField(
                    hintText: 'Nama Laundry', 
                    prefixIcon: Icons.storefront_outlined, 
                    controller: authC.namaLaundryCtrl,
                    errorText: authC.errNamaLaundry.value,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s\-\&\.\']")),
                      LengthLimitingTextInputFormatter(30),
                    ],
                  )),

                  Obx(() => CustomTextField(
                    hintText: 'Nomor Telepon ', 
                    prefixIcon: Icons.phone_outlined, 
                    controller: authC.noTelpRegisCtrl, 
                    errorText: authC.errNoTelpRegis.value,

                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                  )),

                  Obx(() => CustomTextField(
                    hintText: 'Email', 
                    prefixIcon: Icons.email_outlined, 
                    controller: authC.emailRegisCtrl,
                    errorText: authC.errEmailRegis.value,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\@\.\-\_]")),
                      LengthLimitingTextInputFormatter(30),
                    ],
                  )),
                  Obx(() => CustomTextField(
                    hintText: 'Password', 
                    isPassword: true, 
                    prefixIcon: Icons.lock_outline, 
                    controller: authC.passwordRegisCtrl,
                    errorText: authC.errPasswordRegis.value,
                  )),
                  Obx(() => CustomTextField(
                    hintText: 'Konfirmasi Password', 
                    isPassword: true, 
                    prefixIcon: Icons.lock_outline, 
                    controller: authC.confirmPasswordCtrl,
                    errorText: authC.errConfirmPassword.value,
                  )),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: authC.isLoading.value ? null : () => authC.register(), 
                      child: authC.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    )),
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