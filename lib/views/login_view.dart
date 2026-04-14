import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/header_curve.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController authC = Get.put(AuthController());

  void _tampilkanDialogLupaPassword(BuildContext context, AuthController authC) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lupa Password?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102A43),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan email akunmu, kami akan mengirimkan link untuk mereset password.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: authC.resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Contoh: rabi@gmail.com",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => authC.kirimResetPassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "KIRIM LINK RESET",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

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
                                fontWeight: authC.isPemilik.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: authC.isPemilik.value
                                    ? const Color(0xFF2196F3)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text("|", style: TextStyle(color: Colors.grey)),
                          ),
                          GestureDetector(
                            onTap: () => authC.isPemilik.value = false,
                            child: Text(
                              "PEGAWAI",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: !authC.isPemilik.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: !authC.isPemilik.value
                                    ? const Color(0xFF2196F3)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )),

                  const SizedBox(height: 30),

                  Obx(() => CustomTextField(
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    controller: authC.emailLoginCtrl,
                    errorText: authC.errEmailLogin.value,
                  )),
                  Obx(() => CustomTextField(
                    hintText: 'Kata Sandi',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    controller: authC.passwordLoginCtrl,
                    errorText: authC.errPasswordLogin.value,
                  )),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _tampilkanDialogLupaPassword(context, authC),
                      child: const Text(
                        'Lupa Password ?',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: authC.isLoading.value
                              ? null
                              : () => authC.login(),
                          child: authC.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'MASUK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Belum punya akun ? "),
                      GestureDetector(
                        onTap: () => Get.to(() => RegisterView()),
                        child: const Text(
                          "DAFTAR SEKARANG",
                          style: TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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