# 🧺 Laundry Kiloan
*Digital Laundry Management System*

## 📖 Deskripsi Aplikasi
**Laundry Kiloan** adalah aplikasi berbasis mobile yang dikembangkan menggunakan Flutter sebagai solusi digital untuk operasional bisnis laundry modern. Aplikasi ini dirancang untuk menggantikan sistem pencatatan manual menjadi sistem terintegrasi yang cepat, akurat, dan profesional.

Dengan dukungan backend Supabase, aplikasi ini mampu mengelola data secara *real-time* serta menjaga integritas data melalui sistem database relasional. Aplikasi juga dirancang dengan konsep *multi-outlet*, sehingga dapat digunakan oleh lebih dari satu cabang dalam satu sistem yang sama.


## 🎯 Tujuan Pengembangan

| Tujuan | Penjelasan |
| :--- | :--- |
| **Efisiensi** | Mengurangi waktu input transaksi menjadi hitungan detik |
| **Transparansi**| Pelanggan dapat mengetahui detail layanan dan harga |
| **Profesionalisme**| Menggantikan nota kertas dengan sistem digital |
| **Keamanan Data**| Data tersimpan aman di database *cloud* |


## 🚀 Fitur Aplikasi

### 👤 Manajemen Pelanggan
* Menambahkan pelanggan baru
* Menyimpan data pelanggan (nama & nomor WhatsApp)
* Pencarian pelanggan secara *real-time*
* Detail informasi pelanggan

### 🧾 Sistem Transaksi (Point of Sale)
* Membuat transaksi laundry
* Mendukung *multi-item* dalam satu nota
* Perhitungan otomatis total harga
* Integrasi langsung dengan layanan

### 🧺 Manajemen Layanan
* Menambah & mengedit layanan
* Kategori layanan (kiloan / satuan)
* Harga dan durasi pengerjaan

### 🔄 Tracking Status Cucian
| Status | Deskripsi |
| :--- | :--- |
| **Proses** | Sedang dikerjakan |
| **Selesai** | Siap diambil |
| **Diambil** | Sudah diterima pelanggan |
| **Batal** | Transaksi dibatalkan |

### 💳 Sistem Pembayaran
* Mendukung pencatatan multi-metode pembayaran (Tunai, Non-Tunai/Transfer Bank, dan E-Wallet)
* Pencatatan spesifik vendor pembayaran (BCA, BRI, Mandiri, dll) 
* Status pembayaran (Lunas / Belum Lunas)
* Perhitungan total tagihan secara otomatis

### 🏪 Multi Outlet System
* Setiap data terhubung ke `outlet_id`
* Mendukung banyak cabang dalam satu database

### 🔐 Autentikasi User
* Login & *session management*
* Identifikasi pegawai berdasarkan `user_id`

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

---

## 🧩 Widget yang Digunakan

* **Layout:** `Scaffold`, `AppBar`, `Container`, `Column` / `Row`, `Expanded`, `Padding`
* **Input:** `TextField`, `DropdownButton`, `TextEditingController`
* **Data Display:** `ListView`, `ListView.builder`, `ListTile`, `CircleAvatar`
* **Navigasi (GetX):** `GetMaterialApp`, `GetPage`, `Get.to()`, `Get.back()`
* **State Management:** `Obx`, `.obs`, `Get.put()`, `Get.find()`
* **Feedback UI:** `ElevatedButton`, `OutlinedButton`, `IconButton`, `Get.snackbar()`, `CircularProgressIndicator`

---

## 🗂️ Struktur Folder Project

## 🛠️ Teknologi yang Digunakan

| Teknologi | Fungsi |
|----------|-------|
| Flutter | Frontend mobile |
| GetX | State management & routing |
| Supabase | Backend & API |
| PostgreSQL | Database |
| Dart | Bahasa pemrograman |



## 🖼️ Tampilan Aplikasi



### 🔐 Login

### 🏠 Dashboard

### 👤 Pelanggan
### 🧾 Transaksi
### 💳 Pembayaran
### 📊 Laporan


