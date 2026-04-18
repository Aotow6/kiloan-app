import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'user_controller.dart';
import '../views/detail_pelanggan_view.dart';
import '../views/tambah_pelanggan_view.dart';

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

  var isEdit = false.obs;
  var editId = 0.obs;

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

  void goToDetail(String nama, String phone, int id) {
    Get.to(() => DetailPelangganView(nama: nama, phone: phone, id: id));
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

  void prepareNewForm() {
    isEdit.value = false;
    namaCtrl.clear();
    phoneCtrl.clear();
    isTanpaNomor.value = false;
    clearErrors();
    Get.to(() => TambahPelangganView());
  }

      final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  Future<void> ambilDariKontak() async {
    try {

      Contact? contact = await _contactPicker.selectContact();

      if (contact != null) {
        String namaKontak = contact.fullName ?? 'Pelanggan Baru';
        String noHpKontak = '';

        if (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {

          noHpKontak = contact.phoneNumbers!.first.replaceAll(RegExp(r'[^0-9+]'), '');

          if (noHpKontak.startsWith('+62')) {
            noHpKontak = '0${noHpKontak.substring(3)}';
          } else if (noHpKontak.startsWith('62')) {
            noHpKontak = '0${noHpKontak.substring(2)}';
          }
        }

        isEdit.value = false;
        namaCtrl.text = namaKontak;
        phoneCtrl.text = noHpKontak;
        isTanpaNomor.value = noHpKontak.isEmpty; 
        clearErrors();

        Get.to(() => TambahPelangganView());
      }
    } catch (e) {
      debugPrint("Error pilih kontak: $e");
    }
  }

  void setEditMode(String nama, String phone, int id) {
    isEdit.value = true;
    editId.value = id;
    namaCtrl.text = nama;

    if (phone == "Tanpa nomor" || phone.isEmpty) {
       isTanpaNomor.value = true;
       phoneCtrl.clear();
    } else {
       isTanpaNomor.value = false;
       phoneCtrl.text = phone;
    }

    clearErrors();
    Get.to(() => TambahPelangganView());
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

      final query = supabase
          .from('customers')
          .select('id')
          .eq('outlet_id', userC.outletId)
          .ilike('nama_pelanggan', nama);

      final cekDuplikat = isEdit.value 
         ? await query.neq('id', editId.value).maybeSingle()
         : await query.maybeSingle();

      if (cekDuplikat != null) {
        errNama.value = "Pelanggan dengan nama ini sudah ada di toko Anda";
        isLoading.value = false;
        return;
      }

      if (isEdit.value) {
        await supabase.from('customers').update({
          'nama_pelanggan': nama,
          'no_wa': isTanpaNomor.value ? null : phone,
        }).eq('id', editId.value);

        Get.back(); 

        Get.snackbar("Sukses", "Data $nama berhasil diperbarui!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        await supabase.from('customers').insert({
          'outlet_id': userC.outletId,
          'nama_pelanggan': nama,
          'no_wa': isTanpaNomor.value ? null : phone,
          'total_kasbon': 0,
        });

        Get.back(); 

        Get.snackbar("Sukses", "Pelanggan $nama berhasil ditambahkan!", backgroundColor: Colors.green, colorText: Colors.white);
      }

      await fetchPelanggan();

    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan data server sedang sibuk.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hapusPelanggan(int id, String nama, {bool dariDetail = false}) {
    return Get.defaultDialog(
      title: "Hapus Pelanggan?",
      middleText: "Yakin ingin menghapus data $nama?",
      textCancel: "Batal",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        try {
          await supabase.from('customers').delete().eq('id', id);
          await fetchPelanggan();

          Get.back(); 

          if (dariDetail) {
             Get.back(); 
          }

          Get.snackbar("Sukses", "Data $nama berhasil dihapus", backgroundColor: Colors.red.shade600, colorText: Colors.white);
        } catch (e) {
          Get.back();
          Get.snackbar("Error", "Gagal menghapus: $e", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
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

  @override
  void onClose() {
    searchCtrl.dispose();
    namaCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  var detailKasbon = 0.obs;
  var detailPiutang = 0.obs;
  var detailTotalNominal = 0.obs;
  var detailTotalTransaksi = 0.obs;
  var detailTotalBatal = 0.obs;
  var detailTotalKg = 0.0.obs;
  var detailTotalSatuan = 0.obs;
  var detailTransaksiPertama = "-".obs;
  var detailTransaksiTerakhir = "-".obs;
  var isDetailLoading = false.obs;

  Future<void> fetchDetailPelanggan(int customerId) async {
    try {
      isDetailLoading.value = true;

      final cust = await supabase.from('customers').select('total_kasbon').eq('id', customerId).single();
      detailKasbon.value = cust['total_kasbon'] ?? 0;

      final trxs = await supabase.from('transactions')
          .select('*, transaction_details(*, services(satuan))')
          .eq('customer_id', customerId);

      int piutang = 0;
      int nominal = 0;
      int batal = 0;
      double kg = 0.0;
      int satuan = 0;
      DateTime? firstDate;
      DateTime? lastDate;

      for (var trx in trxs) {
        String statusPesanan = trx['status_pesanan'].toString().toLowerCase();
        String statusBayar = trx['status_pembayaran'].toString().toLowerCase();
        int tagihan = trx['total_tagihan'] ?? 0;

        if (statusPesanan == 'batal') {
          batal++;
        } else {
          nominal += tagihan;

          if (statusBayar == 'belum lunas') {
            piutang += tagihan;
          }

          if (trx['transaction_details'] != null) {
            for (var det in trx['transaction_details']) {
              double qty = double.tryParse(det['kuantitas'].toString()) ?? 0.0;
              String sat = det['services']?['satuan']?.toString().toLowerCase() ?? '';

              if (sat == 'kg') {
                kg += qty;
              } else {
                satuan += qty.toInt();
              }
            }
          }

          if (trx['waktu_masuk'] != null) {
            DateTime tgl = DateTime.parse(trx['waktu_masuk']);
            if (firstDate == null || tgl.isBefore(firstDate)) firstDate = tgl;
            if (lastDate == null || tgl.isAfter(lastDate)) lastDate = tgl;
          }
        }
      }

      detailPiutang.value = piutang;
      detailTotalNominal.value = nominal;
      detailTotalTransaksi.value = trxs.length;
      detailTotalBatal.value = batal;
      detailTotalKg.value = kg;
      detailTotalSatuan.value = satuan;

      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      detailTransaksiPertama.value = firstDate != null ? formatter.format(firstDate) : "-";
      detailTransaksiTerakhir.value = lastDate != null ? formatter.format(lastDate) : "-";

    } catch (e) {
      debugPrint("Error fetch detail pelanggan: $e");
    } finally {
      isDetailLoading.value = false;
    }
  }

  String formatRupiahLokal(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}