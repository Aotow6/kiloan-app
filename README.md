# 🧺 Laundry Kiloan
*Digital Laundry Management System*


## 👥 Profil Kelompok: [Nama Kelompok Kalian]

| NIM | Nama | Program Studi / Kelas |
| :--- | :--- | :--- |
| 2409116041 | Shafa Rizqi Nur Wahidah | Sistem Informasi |
| 2409116049 | Rabiatul Hikmah | Sistem Informasi  |
| 2409116061 | Nayla Lelyanggraheni Hutomo | Sistem Informasi |
| 2409116067 | Satria Rajawali Ektya Antara | Sistem Informasi  |


## 📖 Deskripsi Aplikasi
**Laundry Kiloan** adalah aplikasi berbasis mobile yang dikembangkan menggunakan Flutter sebagai solusi digital untuk operasional bisnis laundry modern. Aplikasi ini dirancang untuk menggantikan sistem pencatatan manual menjadi sistem terintegrasi yang cepat, akurat, dan profesional.

Dengan dukungan backend Supabase, aplikasi ini mampu mengelola data secara *real-time* serta menjaga integritas data melalui sistem database relasional. Aplikasi juga dirancang dengan konsep *multi-outlet*, sehingga dapat digunakan oleh lebih dari satu cabang dalam satu sistem yang sama.


## 🤝 Profil Mitra: Laundry ...

**[Nama Laundry Mitra]** adalah mitra bisnis sekaligus latar belakang langsung pengembangan aplikasi Laundry App ini. Usaha ini beroperasi di **[Alamat/Jalan lokasi laundry]** yang menawarkan layanan cuci setrika kiloan dan satuan. Konsepnya berfokus pada pelayanan cepat dan bersih bagi warga sekitar. Ceritanya berawal dari peluang usaha di kawasan yang padat penduduk, di mana banyak mahasiswa dan pekerja kantoran yang tidak memiliki waktu untuk mencuci pakaian mereka sendiri. Operasional toko ini dimulai pada **[Tanggal/Bulan/Tahun didirikan]**.

Menurut pemilik, mengelola bisnis jasa laundry memiliki tantangan yang berbeda, terutama dalam hal **pencatatan dan pelacakan barang pelanggan**. Seringkali terjadi risiko nota hilang atau pakaian tertukar jika hanya mengandalkan pencatatan manual di buku tulis. Di awal operasional, pemilik sempat kewalahan mengatur jadwal selesai cucian saat pesanan sedang menumpuk. Oleh karena itu, dibutuhkan sebuah sistem pencatatan digital yang mandiri untuk menjaga kepercayaan pelanggan.

Penjualan di bisnis ini juga sangat dipengaruhi oleh **musim dan kalender**. Pada musim penghujan, jumlah pelanggan biasanya melonjak drastis karena banyak orang kesulitan menjemur pakaian. Begitu juga saat musim liburan atau awal semester bagi mahasiswa. Saat ini, pemilik masih **ikut campur langsung** dalam operasional harian untuk memastikan *quality control* dan meminimalisir kelalaian pegawai. Pemilik berpendapat bahwa sistem digitalisasi kasir (POS) sangat penting di fase ini agar pengawasan omzet dan kinerja pegawai bisa dipantau secara transparan tanpa harus selalu berada di toko.

*Ringkasan ini bersumber dari wawancara dengan pemilik [Nama Laundry Mitra] pada 21 februari 2026.*



## 🎯 Tujuan Pengembangan

| Tujuan | Penjelasan |
| :--- | :--- |
| **Efisiensi** | Mengurangi waktu input transaksi menjadi hitungan detik |
| **Transparansi**| Pelanggan dapat mengetahui detail layanan dan harga |
| **Profesionalisme**| Menggantikan nota kertas dengan sistem digital |
| **Keamanan Data**| Data tersimpan aman di database *cloud* |


## 🚀 Fitur Utama

![Auth](https://img.shields.io/badge/Auth-Supabase-10b981?style=flat-square)
![Peran](https://img.shields.io/badge/Peran-Owner%20%7C%20Kasir-4b5563?style=flat-square)
![POS](https://img.shields.io/badge/POS-Pencatatan%20Transaksi-ef4444?style=flat-square)
![Backend](https://img.shields.io/badge/Backend-Supabase-10b981?style=flat-square)

| Fitur | Keterangan |
| :--- | :--- |
| **Autentikasi & sesi** | Login, pendaftaran akun kasir, pengelolaan sesi aman |
| **Dashboard** | Ringkasan omzet dan transaksi, pintu masuk ke modul utama |
| **POS / Kasir** | Buat pesanan baru, pemilihan layanan, hitung total otomatis, dan pembayaran |
| **Layanan & Pelanggan**| CRUD data layanan (kiloan/satuan) dan direktori data pelanggan |
| **Laporan** | Laporan pendapatan dan arus kas per rentang waktu tertentu |
| **Karyawan** | Kelola data karyawan/kasir dengan pembatasan hak akses untuk non-owner |
| **Tracking Cucian** | Pembaruan status operasional cucian (Proses, Selesai, Diambil) |
| **Pengaturan pengguna**| Ubah profil, ganti email, reset password, dan pengaturan terkait akun |

---

## 🧩 Widget dan Komponen

| Kategori | Widget / pola | Peran dalam aplikasi |
| :--- | :--- | :--- |
| **Layout** | `Scaffold`, `SafeArea`, `SingleChildScrollView`, `ListView`, `Column`, `Row`, `Expanded` | Kerangka halaman, daftar pesanan, layout dashboard |
| **Material** | `AppBar`, `Card`, `ListTile`, `CircleAvatar`, `Divider`, `BottomNavigationBar` | Pola UI yang konsisten, desain kartu informasi |
| **Input** | `TextField`, `TextFormField`, `DropdownButton`, `TextEditingController` | Form login, input data pelanggan, produk, transaksi |
| **Interaksi** | `InkWell`, `GestureDetector`, `IconButton`, `ElevatedButton`, `OutlinedButton` | Aksi sentuhan (*tap*), navigasi, tombol konfirmasi |
| **State & Navigasi** | `Obx`, `Get.put()`, `Get.to()`, `Get.snackbar()`, `BottomSheet` | Manajemen *state* reaktif (GetX), *routing*, dan *feedback* UI |

---


## 🧠 Arsitektur Sistem

### 🔗 Relasi Database
| Tabel | Fungsi |
| :--- | :--- |
| `outlets` | Data toko |
| `users` | Data pegawai |
| `customers` | Data pelanggan |
| `services` | Daftar layanan |
| `transactions` | Nota utama |
| `transaction_details` | Rincian item |
| `cashflows` | Arus kas |

### ⚙️ Backend Logic
* *Dynamic price calculation*
* *Relational data integrity* (Foreign Key)
* *Timestamp automation*
* *Delivery fee logic*



## 🗂️ Struktur Folder Project

Proyek ini menggunakan pola arsitektur MVC (Model-View-Controller) yang diadaptasi untuk **GetX State Management** agar kodenya rapi dan mudah di-*maintenance*:
<details>
<summary><b>Struktur folder </b></summary>

<br>


```text
lib/
│
├── controllers/            # Berisi logika bisnis dan state management
│   ├── auth_controller.dart
│   ├── pelanggan_controller.dart
│   ├── layanan_controller.dart
│   ├── transaksi_controller.dart
│   ├── laporan_controller.dart
│   └── user_controller.dart
│
├── models/                 # Struktur data / Blueprint objek
│   ├── user_model.dart
│   └── outlet_model.dart
│
├── views/                  # UI / Tampilan halaman aplikasi
│   ├── login_view.dart
│   ├── home_view.dart
│   │
│   ├── pelanggan/          # Modul Pelanggan
│   │   └── ...
│   ├── transaksi/          # Modul Kasir & POS
│   │   └── ...
│   └── admin/              # Modul Owner / Pengaturan
│       └── ...
│
├── widgets/                # Komponen UI yang bisa dipakai berulang (Reusable)
│   ├── navbar.dart
│   └── header_curve.dart
│
└── main.dart               # Entry point aplikasi & inisialisasi Supabase/GetX
```


## 🛠️ Teknologi yang Digunakan

| Teknologi | Fungsi |
|----------|-------|
| Flutter | Frontend mobile |
| GetX | State management & routing |
| Supabase | Backend & API |
| PostgreSQL | Database |
| Dart | Bahasa pemrograman |

---

## 💻 Cara Menjalankan Project (Getting Started)

Ikuti langkah-langkah di bawah ini untuk menjalankan *source code* **Laundry App** di lingkungan lokal Anda:

### 1. Persiapan Kebutuhan (Prerequisites)
Sebelum memulai, pastikan perangkat Anda sudah terinstal perangkat lunak berikut:
* **Flutter SDK:** Versi stabil terbaru ([Panduan Instalasi](https://docs.flutter.dev/get-started/install)).
* **Code Editor:** Visual Studio Code (disarankan) atau Android Studio.
* **Emulator/Device:** Android Emulator, Simulator iOS, atau perangkat fisik yang sudah terhubung via USB Debugging.

### 2. Clone Repository
Buka terminal atau command prompt, lalu jalankan perintah berikut untuk mengunduh kode proyek:
```bash
git clone [https://github.com/username-kalian/laundry-app.git](https://github.com/username-kalian/laundry-app.git)
cd laundry-app
```

## 🖼️ Tampilan Aplikasi


### 🔐 Login

### 🏠 Dashboard

### 👤 Pelanggan
### 🧾 Transaksi
### 💳 Pembayaran
### 📊 Laporan


