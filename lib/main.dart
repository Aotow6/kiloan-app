import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/controllers/user_controller.dart';
import 'package:laundry_app/controllers/layanan_controller.dart';
import 'package:laundry_app/controllers/pelanggan_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wrjktapmmczgblqtoujd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indyamt0YXBtbWN6Z2JscXRvdWpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMDE4NTksImV4cCI6MjA5MDY3Nzg1OX0.vyyQ1NPLq8QExpvrwT00qMxPT6DazJa4BKlyt52KJMs',
  );

  Get.put(UserController(), permanent: true);
  Get.lazyPut(() => LayananController());
  Get.lazyPut(() => PelangganController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: ThemeData(
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
      ],
    );
  }
}