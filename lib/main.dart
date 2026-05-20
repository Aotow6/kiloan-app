import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

import 'package:laundry_app/controllers/user_controller.dart';
import 'package:laundry_app/controllers/layanan_controller.dart';
import 'package:laundry_app/controllers/pelanggan_controller.dart';
import 'package:laundry_app/controllers/home_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'package:laundry_app/services/sensor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final session = Supabase.instance.client.auth.currentSession;
  final String ruteAwal = session != null ? '/home' : '/login';

  Get.put(UserController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(SensorService(), permanent: true); 
  Get.lazyPut(() => LayananController());
  Get.lazyPut(() => PelangganController());
  Get.lazyPut(() => LayananController());
  Get.lazyPut(() => PelangganController());

  runApp(MyApp(ruteAwal: ruteAwal));
}

class MyApp extends StatelessWidget {
  final String ruteAwal; 

  const MyApp({super.key, required this.ruteAwal});

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

      initialRoute: ruteAwal, 
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => HomeView()),
      ],
    );
  }
}