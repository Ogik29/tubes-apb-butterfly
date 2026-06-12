# Rencana Integrasi API Laravel ke Frontend Flutter

Rencana ini menjelaskan langkah-langkah untuk menghubungkan aplikasi Flutter frontend dengan REST API Laravel backend. Kita akan mengganti seluruh simulasi data (*mock data*) dengan request HTTP riil ke backend.

## User Review Required

> [!IMPORTANT]
> **Base URL dan Akses Emulator/Device:**
> * Jika menggunakan **Android Emulator**, backend Laravel (`http://localhost:8000`) harus diakses lewat **`http://10.0.2.2:8000`** karena `localhost` pada emulator menunjuk ke sistem operasi emulator itu sendiri.
> * Jika menggunakan **Device Fisik**, device dan laptop backend harus berada di satu jaringan Wi-Fi, dan base URL diatur ke IP laptop (misal: `http://192.168.1.10:8000`).
> * Jika menggunakan **iOS Simulator** atau **Windows Build/Web**, base URL bisa tetap menggunakan **`http://localhost:8000`**.
> * **Rencana kita:** Kita akan menaruh konfigurasi `baseUrl` di satu file helper `ApiService` agar mudah diubah.

> [!NOTE]
> **State Management:**
> * Kita memiliki package `provider` di `pubspec.yaml` tetapi belum dipakai (aplikasi saat ini memakai `InheritedWidget` bernama `AppState`).
> * Kita akan tetap memelihara `AppState` agar meminimalkan perubahan struktur di `main.dart`, namun isinya akan dikembangkan untuk memuat data token dan menyimpan status login secara persisten menggunakan `shared_preferences`.

## Open Questions

> [!WARNING]
> **Autentikasi & CORS:**
> Apakah database backend Laravel sudah terkonfigurasi dengan benar (migrasi & seeder sudah berhasil dijalankan), dan apakah Laravel CORS (`config/cors.php`) sudah mengizinkan request dari client?
> * *Catatan:* Jika berjalan di localhost, pastikan server Laravel dinyalakan menggunakan perintah `php artisan serve --host=0.0.0.0` agar bisa diakses oleh emulator android/device lain di jaringan yang sama.

---

## Proposed Changes

### [Core & Utilities]

#### [MODIFY] [pubspec.yaml](file:///d:/Flutter/tubes_apb_mothra/pubspec.yaml)
* Menambahkan dependensi `http` untuk mengirim HTTP request:
  ```yaml
  dependencies:
    ...
    http: ^1.2.1
  ```

#### [NEW] [api_service.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/services/api_service.dart)
* Membuat kelas `ApiService` untuk menangani panggilan API. Kelas ini akan mencakup:
  * Pengaturan header default (termasuk token bearer dari `shared_preferences`).
  * Penanganan error respon HTTP (401 Unauthorized, 422 Validation Error).
  * Endpoint autentikasi (`login`, `register`, `logout`, `getMe`).
  * Endpoint kupu-kupu & koleksi (`getButterflies`, `getCollection`, `getStats`, `getAdminStats`).
  * Endpoint scan (`scanImage` menggunakan multipart request untuk upload gambar, `saveScan`).
  * Endpoint riwayat (`getHistory`, `deleteHistory`).
  * Endpoint CRUD Admin (`addButterfly`, `updateButterfly`, `deleteButterfly`).

#### [MODIFY] [main.dart](file:///d:/Flutter/tubes_apb_mothra/lib/main.dart)
* Memperbarui `AppState` agar memegang token autentikasi.
* Membaca token login dari `shared_preferences` saat aplikasi pertama kali dibuka (auto-login jika token masih aktif).

---

### [Screens Refactoring]

#### [MODIFY] [login_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/auth/login_screen.dart)
* Mengganti logika login tiruan dengan panggilan API `login` dari `ApiService`.
* Menyimpan token yang didapat ke `shared_preferences` dan menyetel data user di `AppState`.

#### [MODIFY] [register_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/auth/register_screen.dart)
* Menghubungkan tombol daftar ke API `register` di `ApiService`.
* Setelah registrasi sukses, otomatis masuk ke dashboard menggunakan token yang diterbitkan.

#### [MODIFY] [dashboard_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/dashboard/dashboard_screen.dart)
* Mengganti fungsi logout agar memanggil API `logout` Laravel untuk membatalkan token di server.
* Memuat statistik dashboard secara dinamis melalui API `/api/dashboard/stats` (atau `/api/dashboard/admin-stats` untuk admin) alih-alih menghitung dari array statis lokal.

#### [MODIFY] [collection_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/collection/collection_screen.dart)
* Mengganti variabel global `sampleButterflies` dengan data dari API `GET /api/butterflies` (untuk semua spesies) dan mencocokkan status koleksi (`is_collected`).
* Menggunakan `FutureBuilder` atau stateful fetch di `initState` untuk memuat data dari server secara asinkron dengan loading indicator.

#### [MODIFY] [scan_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/scan/scan_screen.dart)
* Mengganti simulasi deteksi dengan mengirim file gambar asli ke API `POST /api/scan` via multipart upload.
* Menerima respon hasil identifikasi model CNN dari backend (nama spesies, status racun, nilai keyakinan/confidence) lalu mengarahkannya ke halaman hasil.

#### [MODIFY] [result_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/scan/result_screen.dart)
* Mengubah aksi tombol "Simpan ke Koleksi" agar memanggil API `PATCH /api/scan/{id}/save` untuk menambahkan kupu-kupu hasil identifikasi ke koleksi permanen pengguna di database.

#### [MODIFY] [history_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/history/history_screen.dart)
* Memuat daftar riwayat scan riil milik pengguna dari API `GET /api/history`.
* Mengimplementasikan fitur hapus riwayat melalui API `DELETE /api/history/{id}`.

#### [MODIFY] [admin_panel_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/admin/admin_panel_screen.dart)
* Memuat data master spesies langsung dari API `/api/butterflies`.
* Menghubungkan fungsi hapus spesies dengan API `DELETE /api/butterflies/{id}`.

#### [MODIFY] [species_form_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/admin/species_form_screen.dart)
* Menghubungkan form ke API:
  * Tambah Spesies Baru: `POST /api/butterflies`
  * Edit Spesies Lama: `PUT /api/butterflies/{id}`

---

## Verification Plan

### Automated Tests & Runs
* Menjalankan aplikasi Flutter menggunakan simulator Windows/Android.
* Memantau network logs untuk memastikan token disertakan dengan benar di header `Authorization: Bearer <token>`.
* Melakukan uji coba login/register dan memeriksa apakah session tetap bertahan saat aplikasi di-restart.

### Manual Verification
1. **Autentikasi:** Mendaftar akun baru, melakukan logout, lalu masuk kembali. Memastikan login admin (`role = admin`) membuka akses ke Admin Panel.
2. **Katalog & Koleksi:** Memastikan halaman koleksi menampilkan ikon gembok pada kupu-kupu yang belum discan, dan menampilkan detail spesies jika sudah dikoleksi.
3. **Scan:** Mengunggah gambar, memastikan gambar berhasil terkirim ke backend, dan mendapatkan respon hasil identifikasi simulasi dari server. Menekan "Simpan ke Koleksi" dan memastikan status koleksi terbarui saat kembali ke katalog.
4. **CRUD Admin:** Menambahkan spesies baru melalui admin, lalu memverifikasi spesies tersebut langsung muncul di halaman katalog user biasa.
