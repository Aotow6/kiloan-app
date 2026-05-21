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


## 🤝 Profil Mitra: Yuni Laundry

**Yuni Laundry** adalah mitra bisnis sekaligus latar belakang langsung pengembangan aplikasi Laundry App ini. Usaha ini beroperasi di **JL. Suwandi, Gn.Kelua, samarinda Ulu, kota Samarinda** yang menawarkan layanan cuci setrika kiloan dan satuan. Konsepnya berfokus pada pelayanan cepat dan bersih bagi warga sekitar. Ceritanya berawal dari peluang usaha di kawasan yang padat penduduk, di mana banyak mahasiswa dan pekerja kantoran yang tidak memiliki waktu untuk mencuci pakaian mereka sendiri. Operasional toko ini dimulai pada **sejak 12 tahun yang lalu**.

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
</details>


## 🛠️ Teknologi yang Digunakan

| Teknologi / Library | Fungsi |
| :--- | :--- |
| **Flutter & Dart** | Framework Frontend & Bahasa Pemrograman |
| **GetX** | State management, routing, & dependency injection |
| **Supabase (PostgreSQL)** | Backend serverless, Database relasional, & Autentikasi aman |
| **PDF & Printing** | *Generate* laporan keuangan dan cetak struk digital |
| **URL Launcher & Share** | Integrasi pengiriman nota otomatis via WhatsApp & platform lain |
| **Native Integrations** | Akses kontak bawaan HP (Contact Picker) & *Splash Screen* |
| **Intl** | Formatter lokalisasi mata uang (Rupiah) dan format tanggal |

## 🌟 Nilai Tambah (Eksplorasi Package Tambahan)

Aplikasi ini mengimplementasikan berbagai *package* pihak ketiga di luar modul praktikum standar untuk menunjang fitur operasional bisnis yang lebih nyata dan profesional:

**1. Modul Laporan & Dokumen Digital**
* `pdf` & `printing`: Digunakan untuk men-*generate* struk transaksi dan laporan keuangan ke dalam format PDF secara dinamis. *Package* ini juga memungkinkan aplikasi untuk mencetak dokumen secara langsung.
* `path_provider`: Mengakses direktori *file system* bawaan perangkat untuk menyimpan file PDF (laporan/struk) secara lokal di *storage* HP pengguna.

**2. Integrasi Komunikasi & CRM (Customer Relationship Management)**
* `share_whatsapp` & `url_launcher`: Memungkinkan kasir untuk mengirimkan nota digital atau status cucian langsung ke nomor WhatsApp pelanggan dengan satu kali klik.
* `share_plus`: Menyediakan fitur *native sharing popup* untuk membagikan bukti transaksi ke berbagai platform lain (Email, Telegram, dll).

**3. UX & Utilitas Native**
* `flutter_native_contact_picker`: Eksplorasi fitur *native* HP yang memungkinkan kasir mengambil data pelanggan langsung dari buku kontak (*phonebook*) perangkat tanpa harus mengetik nomor satu per satu.
* `intl`: Digunakan untuk melokalisasi format tanggal (Date Time) dan format mata uang Rupiah (IDR) secara otomatis pada fitur kasir dan laporan keuangan agar angka mudah dibaca.
* `font_awesome_flutter`: Memperkaya antarmuka pengguna (UI) dengan ratusan ikon profesional yang tidak tersedia di *package* Material bawaan.
* `flutter_native_splash`: Membuat *branding* aplikasi terlihat lebih profesional layaknya aplikasi komersial dengan menampilkan *splash screen* transisi logo saat aplikasi baru dibuka, menghilangkan layar putih kosong (*blank white screen*).



## 🖼️ Tampilan Aplikasi

### Registrasi
<p align="center"> <img src="https://github.com/user-attachments/assets/3300b572-51e3-4ceb-aa2b-2ac13cd5f861" width="250"/> 
  
### 🔐 Login
<p align="center"> <img src="https://github.com/user-attachments/assets/dfff9234-1bb7-4525-9024-f198533a16bb" width="250" style="margin-right: 10px;"/>
  <img src="https://github.com/user-attachments/assets/a20051f3-97ea-42c8-8845-508125820d59" width="250"/> </p>

### 🏠 Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/bcd40e7c-d6b4-4e9c-a3d7-14ad512f3910" width="250" style="margin-right: 10px;" />
<img  src="https://github.com/user-attachments/assets/250c4012-fe4e-4250-a9b2-e73dccea87e3"  width="250" /> </p>

### Pesanan
<p align="center"> <img src="https://github.com/user-attachments/assets/4494da6d-7ca9-406c-aad5-db82f27ea88e"  width="250" /> </p>

#### 🧾 Transaksi
<p align="center"> <img src="https://github.com/user-attachments/assets/6d47e1b4-2204-4d48-837a-72057dfd76fd"  width="250" /> </p>

### 📊 Laporan
<p align="center"> <img src="https://github.com/user-attachments/assets/336164ec-ce61-4c4c-b95b-996a56c7759d" width="250" />
<img src="https://github.com/user-attachments/assets/175420cf-e9f0-46b4-aaa6-863c44f90ed4" width="250" /> </p>

### Pengaturan 
<p align="center"> <img  src="https://github.com/user-attachments/assets/4184cdc8-dbd8-4725-bfe0-27e9f28eebad" width="250" />
<img  src="https://github.com/user-attachments/assets/c89539f3-87cd-4242-be08-384628563192" width="250" /> </p>

