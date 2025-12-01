<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- Ganti src logo kalau sudah ada -->
  <img src="assets/images/logo.png" alt="Logo">

  <h3 align="center">FaisalPedia — Mobile App Toko Online Sederhana</h3>

  <p align="center">
    Test Project: Simulasi alur toko online dengan 3 role (Pembeli, CS1, CS2)
    <br />
    <br />
    <!-- Ganti link repo / demo sesuai kebutuhan -->
    <a href="https://github.com/F415alarrahman/Faisal-Pedia">View Repository</a>
    ·
    <a href="https://faisalarrp.online/">Live Web</a>
  </p>
</div>

---

## About The Project

FaisalPedia adalah aplikasi mobile (Flutter) untuk simulasi **toko online sederhana** dengan beberapa alur penting:

- Pembeli dapat melihat produk, mengelola keranjang, melakukan checkout, upload bukti pembayaran, dan mengunduh invoice (PDF).
- CS Layer 1 melakukan verifikasi pembayaran, mengatur stok, export data pesanan ke Excel, dan menangani auto cancel 24 jam.
- CS Layer 2 memproses pesanan hingga selesai (diproses, dikirim, selesai).

Semua role ini ada dalam **satu aplikasi Flutter**, dan **role bisa diganti langsung dari UI** tanpa login kompleks.

Aplikasi ini dibuat sebagai **test project** untuk menguji:

- Arsitektur mobile app
- State management
- Pengelolaan data (API / local)
- Flow transaksi & status pesanan
- Mekanisme auto cancel 1×24 jam

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Tech Stack / Built With

### Mobile App

- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: `Provider`
  - Dipilih karena:
    - Simple, ringan, bawaan ekosistem Flutter
    - Mudah di-scale ke arsitektur dengan Notifier / ViewModel
    - Cocok untuk pemisahan logic UI dan business logic

### Backend (Testing / Demo)

Backend untuk testing berada di:

- `https://faisalarrp.online/api`

Teknologi backend:

- PHP + MySQL (API sederhana untuk produk & pesanan)
- Response dalam bentuk JSON
- Di sisi Flutter dibungkus oleh lapisan **service** dan **repository** sehingga pemanggilan API terpisah dari UI.

> **Catatan sesuai brief:** Data source menggunakan **simulasi API** melalui service layer, yang pada implementasi ini dihubungkan ke backend PHP. Di sisi Flutter tetap diperlakukan sebagai remote API (bisa dengan mudah diganti ke JSON lokal / mock service bila dibutuhkan).

### Payment Gateway

- **Midtrans Snap (Sandbox)**
  - Digunakan untuk simulasi pembayaran otomatis (VA / e-wallet).
  - Integrasi lewat backend PHP (server key & client key tidak disimpan di Flutter).

**Akun Midtrans Sandbox yang digunakan**  
(Email hanya untuk identifikasi, password & server key dibagikan secara privat ke pewawancara, tidak di-commit ke repo publik):

- Email: `faisalarrahmanpratama@gmail.com`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Arsitektur Aplikasi

Secara garis besar, aplikasi dibagi menjadi beberapa layer:

1. **Presentation Layer (UI)**

   - Widget-page per fitur (Produk, Keranjang, Checkout, CS1 List, CS2 List, dsb).
   - Menggunakan `ChangeNotifier` + `Consumer` (Provider) untuk menghubungkan UI ke state.

2. **State / Logic Layer (Notifier / ViewModel)**

   - Contoh: `DetailProductNotifier`, `CartNotifier`, `Cs1OrderListNotifier`, `Cs2OrderListNotifier`, dll.
   - Tanggung jawab:
     - Mengambil data dari repository
     - Menyimpan state lokal (list produk, keranjang, daftar pesanan, role aktif)
     - Mengatur flow (ubah status order, validasi stok, dsb)

3. **Data Layer**

   - **Repository**
     - Misal: `ProductRepository`, `OrderRepository`
     - Abstraksi: menyediakan fungsi seperti `getProducts()`, `createOrder()`, `getOrdersByStatus()`, dll.
   - **Service / API Client**
     - Mengurus pemanggilan HTTP ke backend (`https://faisalarrp.online/api/...`)
     - Parsing JSON → model Dart

4. **Model**
   - `ProductModel`, `OrderModel`, `BuyerModel`, dsb.
   - Menyimpan struktur data yang dipakai di seluruh app.

Dengan pembagian ini:

- UI tidak memanggil API langsung.
- Mudah untuk mengganti data source (misal: dari API ke file JSON lokal) cukup di layer repository / service.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Cara Menjalankan Aplikasi

### Prerequisites

- Flutter SDK (minimal versi 3.x)
- Dart SDK (bundle dengan Flutter)
- Emulator Android / iOS atau device fisik

Cek instalasi:

```sh
flutter doctor
