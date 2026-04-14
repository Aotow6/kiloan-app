import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart';

class PelangganController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listPelanggan = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs;

  final namaCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  var isTanpaNomor = false.obs;

  var errNama = RxnString();
  var errPhone = RxnString();

  var sortType = 'Terbaru'.obs;

  void changeSort(String val) {
    sortType.value = val;
    if (val == 'Abjad') {
      listPelanggan.sort((a, b) => (a['nama_pelanggan'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b['nama_pelanggan'] ?? '')
              .toString()
              .toLowerCase()));
    } else {
      listPelanggan.sort((a, b) => b['id'].compareTo(a['id']));
    }
  }

  void goToDetail(String nama, String noHp) {
    Get.snackbar("Info", "Membuka profil $nama");
  }

  @override
  void onInit() {
    super.onInit();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    try {
      isLoading.value = true;

      final data = await supabase
          .from('customers')
          .select()
          .eq('outlet_id', userC.outletId)
          .order('created_at', ascending: false);

      listPelanggan.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearErrors() {
    errNama.value = null;
    errPhone.value = null;
  }

  bool hasEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true).hasMatch(text);
  }

  Future<void> simpanPelanggan() async {
    clearErrors();
    bool isValid = true;

    String nama = namaCtrl.text.trim();
    String phone = phoneCtrl.text.trim();

    if (nama.isEmpty) {
      errNama.value = "Nama wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Nama minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) {
      errNama.value = "Nama tidak boleh menggunakan emoji";
      isValid = false;
    }

    if (!isTanpaNomor.value) {
      if (phone.isEmpty) {
        errPhone.value = "Nomor HP wajib diisi atau centang 'Tanpa nomor'";
        isValid = false;
      } else if (!phone.startsWith('08')) {
        errPhone.value = "Nomor HP harus diawali '08'";
        isValid = false;
      } else if (phone.length < 10 || phone.length > 13) {
        errPhone.value = "Nomor HP tidak valid (10-13 digit)";
        isValid = false;
      }
    }

    if (!isValid) return;

    try {
      isLoading.value = true;

      final cekDuplikat = await supabase
          .from('customers')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .ilike('nama_pelanggan', nama) 
          .maybeSingle();

      if (cekDuplikat != null) {
        errNama.value = "Pelanggan dengan nama ini sudah ada di toko Anda";
        isLoading.value = false;
        return;
      }

      await supabase.from('customers').insert({
        'outlet_id': userC.outletId,
        'nama_pelanggan': nama,
        'no_wa': isTanpaNomor.value ? null : phone,
        'total_kasbon': 0,
      });

      namaCtrl.clear();
      phoneCtrl.clear();
      isTanpaNomor.value = false;
      clearErrors();

      await fetchPelanggan();

      Get.back(); 

      Get.snackbar(
        "Sukses",
        "Pelanggan $nama berhasil ditambahkan!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan pelanggan server sedang sibuk.", 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hapusPelanggan(int id) async {
    try {
      await supabase.from('customers').delete().eq('id', id);
      await fetchPelanggan();
      Get.snackbar("Sukses", "Data berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal hapus: $e");
    }
  }

  List<Map<String, dynamic>> get filteredPelanggan {
    if (searchQuery.value.isEmpty) return listPelanggan;

    return listPelanggan.where((p) {
      return p['nama_pelanggan']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          (p['no_wa'] ?? '').toString().contains(searchQuery.value);
    }).toList();
  }

  void toggleTanpaNomor(bool? val) {
    isTanpaNomor.value = val ?? false;
    if (isTanpaNomor.value) {
      phoneCtrl.clear();
      errPhone.value = null; 
    }
  }

  void prepareNewForm() {
    namaCtrl.clear();
    phoneCtrl.clear();
    isTanpaNomor.value = false;
    clearErrors();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    namaCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}