import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laundry_app/controllers/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_controller.dart'; 

class LayananController extends GetxController {
  final supabase = Supabase.instance.client;
  final userC = Get.find<UserController>();

  var listServices = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final kategoriCtrl = TextEditingController();
  final namaLayananCtrl = TextEditingController();
  final hargaCtrl = TextEditingController();
  final durasiCtrl = TextEditingController();

  var errKategori = RxnString();
  var errNama = RxnString();
  var errHarga = RxnString();
  var errDurasi = RxnString();

  final searchCtrl = TextEditingController();
  var searchQuery = "".obs;
  var selectedFilter = "Semua".obs;

  var expandedCategories = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (userC.outletId != null) {
      fetchServices(); 
    }
  }

  void clearErrors() {
    errKategori.value = null;
    errNama.value = null;
    errHarga.value = null;
    errDurasi.value = null;
  }

  bool hasEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true).hasMatch(text);
  }

  List<String> get existingCategories {
    return listServices.map((e) => e['kategori'].toString()).toSet().toList();
  }

  void toggleKategori(String kategori) {
    expandedCategories[kategori] = !(expandedCategories[kategori] ?? false);
  }

  void formatHarga(String value, TextEditingController ctrl) {
    String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      ctrl.text = '';
      return;
    }
    String formatted = clean.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    ctrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> fetchServices() async {
    if (userC.outletId == null) return;
    try {
      isLoading.value = true;
      final data = await supabase
          .from('services')
          .select()
          .eq('outlet_id', userC.outletId) 
          .isFilter('deleted_at', null) 

          .order('kategori', ascending: true);

      listServices.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      ErrorHandler.show(e);
    } finally {
      isLoading.value = false;
    }
  }

  void siapkanTambah() {
    clearErrors();
    kategoriCtrl.clear();
    namaLayananCtrl.clear();
    hargaCtrl.clear();
    durasiCtrl.clear();
  }

  Future<void> simpanLayanan() async {
    clearErrors();
    bool isValid = true;

    String kategori = kategoriCtrl.text.trim().toLowerCase();
    String nama = namaLayananCtrl.text.trim().toLowerCase(); 
    String hargaRaw = hargaCtrl.text.replaceAll('.', ''); 
    String durasiRaw = durasiCtrl.text.trim();

    if (kategori.isEmpty) {
      errKategori.value = "Kategori layanan wajib diisi";
      isValid = false;
    } else if (kategori.length < 3) {
      errNama.value = "Minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(kategori)) { 
      errKategori.value = "Kategori tidak boleh mengandung emoji";
      isValid = false;
    }
    
    if (nama.isEmpty) {
      errNama.value = "Nama layanan wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) { 

      errNama.value = "Nama tidak boleh mengandung emoji";
      isValid = false;
    }

    if (hargaRaw.isEmpty || hargaRaw == '0') {
      errHarga.value = "Harga tidak boleh kosong/nol";
      isValid = false;
    }
    if (durasiRaw.isEmpty) {
      errDurasi.value = "Durasi wajib diisi";
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;

      final cekDuplikat = await supabase
          .from('services')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .eq('kategori', kategori)
          .eq('nama_layanan', nama) 
          .isFilter('deleted_at', null) 

          .maybeSingle();

      if (cekDuplikat != null) {
        errNama.value = "Layanan ini sudah ada!";
        isLoading.value = false;
        return;
      }

      await supabase.from('services').insert({
        'outlet_id': userC.outletId, 
        'kategori': kategori,
        'nama_layanan': nama,
        'harga': int.parse(hargaRaw),
        'durasi_jam': int.tryParse(durasiRaw) ?? 0,
        'satuan': kategori.contains('kiloan') ? 'Kg' : 'Pcs',
      });

      await fetchServices(); 
      Get.back(); 
      Get.snackbar("Sukses", "Layanan berhasil disimpan", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Gagal", "Gagal menyimpan layanan: ", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void siapkanEdit(Map<String, dynamic> service) {
    clearErrors();
    kategoriCtrl.text = service['kategori']?.toString() ?? '';
    namaLayananCtrl.text = service['nama_layanan']?.toString() ?? '';

    String hargaAwal = service['harga']?.toString() ?? '';
    formatHarga(hargaAwal, hargaCtrl); 

    durasiCtrl.text = service['durasi_jam']?.toString() ?? '0';
  }

  Future<void> updateLayanan(int id) async {
    clearErrors();
    bool isValid = true;

    String kategori = kategoriCtrl.text.trim().toLowerCase();
    String nama = namaLayananCtrl.text.trim().toLowerCase(); 
    String hargaRaw = hargaCtrl.text.replaceAll('.', ''); 
    String durasiRaw = durasiCtrl.text.trim();

    if (kategori.isEmpty) {
      errKategori.value = "Kategori wajib diisi";
      isValid = false;
    } else if (hasEmoji(kategori)) { 

      errKategori.value = "Kategori tidak boleh mengandung emoji";
      isValid = false;
    }

    if (nama.isEmpty) {
      errNama.value = "Nama layanan wajib diisi";
      isValid = false;
    } else if (nama.length < 3) {
      errNama.value = "Minimal 3 karakter";
      isValid = false;
    } else if (hasEmoji(nama)) { 

      errNama.value = "Nama tidak boleh mengandung emoji";
      isValid = false;
    }

    if (hargaRaw.isEmpty || hargaRaw == '0') {
      errHarga.value = "Harga tidak valid";
      isValid = false;
    }
    if (durasiRaw.isEmpty) {
      errDurasi.value = "Durasi wajib diisi";
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;

      final cekDuplikat = await supabase
          .from('services')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .eq('kategori', kategori)
          .eq('nama_layanan', nama)
          .neq('id', id)
          .isFilter('deleted_at', null) 

          .maybeSingle();

      if (cekDuplikat != null) {
        errNama.value = "Layanan ini sudah ada!";
        isLoading.value = false;
        return;
      }

      await supabase.from('services').update({
        'kategori': kategori,
        'nama_layanan': nama,
        'harga': int.parse(hargaRaw),
        'durasi_jam': int.tryParse(durasiRaw) ?? 0,
        'satuan': kategori.contains('kiloan') ? 'Kg' : 'Pcs',
      }).eq('id', id);

      await fetchServices(); 
      Get.back(); 
      Get.snackbar("Sukses", "Layanan berhasil diupdate!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Gagal update server sibuk", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void hapusLayanan(int id, String nama) {
    Get.defaultDialog(
      title: "Hapus Layanan",
      middleText: "Yakin hapus $nama?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {

          await supabase.from('services').update({
            'deleted_at': DateTime.now().toUtc().toIso8601String()
          }).eq('id', id);

          await supabase.from('services').delete().eq('id', id);
          fetchServices(); 
          Get.back(); 
          Get.snackbar("Berhasil", "$nama telah dihapus", backgroundColor: Colors.red, colorText: Colors.white);
        } catch (e) {
          ErrorHandler.show(e);
        }
      },
    );
  }

  List<String> get filterOptions {
    var categories = listServices.map((e) => e['kategori'].toString()).toSet().toList();
    categories.insert(0, "Semua"); 
    return categories;
  }

  Map<String, List<Map<String, dynamic>>> get groupedServices {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    var filteredList = listServices.where((service) {
      String nama = service['nama_layanan'].toString().toLowerCase();
      String kategori = service['kategori'].toString().toLowerCase();
      String query = searchQuery.value.toLowerCase();

      bool matchesSearch = nama.contains(query) || kategori.contains(query);
      bool matchesFilter = selectedFilter.value == "Semua" || service['kategori'] == selectedFilter.value;

      return matchesSearch && matchesFilter;
    }).toList();

    for (var service in filteredList) {
      String kat = service['kategori'] as String;
      if (!grouped.containsKey(kat)) {
        grouped[kat] = [];

        if (!expandedCategories.containsKey(kat)) {
          expandedCategories[kat] = false; 
        }
      }
      grouped[kat]!.add(service);
    }
    return grouped;
  }

  @override
  void onClose() {
    kategoriCtrl.dispose();
    namaLayananCtrl.dispose();
    hargaCtrl.dispose();
    durasiCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}