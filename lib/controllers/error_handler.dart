import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static void show(Object e, {String defaultMessage = "Terjadi kesalahan pada sistem."}) {
    String errorMessage = defaultMessage;

    if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
      errorMessage = "Tidak ada koneksi internet. Silakan periksa jaringan Anda.";
    } 

    else if (e is PostgrestException) {
      errorMessage = "Gagal mengambil data dari server.";
    } 
    else if (e is AuthException) {
      errorMessage = e.message;
    }

    Get.snackbar(
      "Oops!", 
      errorMessage,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
    );
  }
}