# Walkthrough: Integrasi REST API Laravel ke Frontend Flutter

Kita telah berhasil menyelesaikan integrasi penuh antara frontend Flutter (`tubes_apb_fe`) dengan backend Laravel (`mothra-backend`). Semua data *mocking* lokal telah diganti dengan request HTTP riil.

## Perubahan yang Dilakukan

### 1. Penambahan Dependensi & Core Service
*   **[pubspec.yaml](file:///d:/Flutter/tubes_apb_mothra/pubspec.yaml):** Menambahkan package `http: ^1.2.1` untuk melakukan request jaringan.
*   **[api_service.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/services/api_service.dart) [NEW]:**
    *   Mengatur konfigurasi base URL dinamis (`10.0.2.2:8000` untuk emulator Android dan `localhost:8000` untuk desktop/simulator iOS).
    *   Secara otomatis melampirkan Bearer Token dari `SharedPreferences` pada header `Authorization`.
    *   Menangani endpoint login, register, logout, profil, daftar spesies kupu-kupu, riwayat scan, penambahan koleksi, dashboard statistik, dan fungsi CRUD Admin.

### 2. Pengecekan Login & Auto-Login
*   **[main.dart](file:///d:/Flutter/tubes_apb_mothra/lib/main.dart):**
    *   Membuat aplikasi memeriksa keberadaan `auth_token` di penyimpanan lokal saat pertama kali dibuka.
    *   Jika token ditemukan, memanggil `ApiService.getMe()` untuk mengambil data profil terkini dari database Laravel. Jika sukses, pengguna langsung masuk ke dashboard tanpa melalui halaman login.

### 3. Autentikasi Pengguna
*   **[login_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/auth/login_screen.dart):** Mengganti validasi statis dengan `ApiService.login()`. Menambahkan status loading (`CircularProgressIndicator`) pada tombol "Masuk" dan menampilkan pesan kesalahan (*validation error*) dari Laravel jika login gagal.
*   **[register_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/auth/register_screen.dart):** Menambahkan `TextEditingController` untuk menangkap input, memanggil `ApiService.register()`, dan langsung mengarahkan ke dashboard secara otomatis setelah berhasil mendaftar.

### 4. Sinkronisasi Dashboard & Ensiklopedia
*   **[dashboard_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/dashboard/dashboard_screen.dart):**
    *   Menghubungkan tab Beranda agar memuat statistik dinamis dari server (jumlah scan, jumlah aman, jumlah beracun, tingkat keyakinan rata-rata, dsb.) menggunakan `FutureBuilder`.
    *   Menghubungkan fungsi logout agar mengirim request API untuk menghapus token di database server Laravel.
*   **[collection_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/collection/collection_screen.dart):**
    *   Mengambil daftar kupu-kupu secara asinkron lewat `ApiService.getButterflies()`.
    *   Menampilkan data gambar secara riil menggunakan `Image.network` jika spesies tersebut sudah berhasil dikumpulkan (*collected*).

### 5. Identifikasi & Simpan Koleksi (CNN & History)
*   **[scan_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/scan/scan_screen.dart):** Menggunakan `http.MultipartRequest` untuk mengirim file gambar yang diambil dari kamera/galeri ke endpoint `/api/scan`.
*   **[result_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/scan/result_screen.dart):** 
    *   Menghubungkan tombol "Simpan ke Koleksi" agar memanggil `ApiService.saveScan()` untuk mensinkronisasi koleksi pengguna dengan database server.
    *   Menambahkan penanganan tipe `imagePath` agar mendukung file lokal (untuk scan baru) maupun network URL (untuk scan dari riwayat).
*   **[history_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/history/history_screen.dart):**
    *   Memuat riwayat scan riil dari server.
    *   Menambahkan fitur **Swipe-to-Delete** menggunakan widget `Dismissible` yang terhubung ke API `DELETE /api/history/{id}` untuk menghapus riwayat dari database.

### 6. CRUD Master Data Admin
*   **[admin_panel_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/admin/admin_panel_screen.dart):** Menghubungkan daftar spesies ke API, menyinkronkan dialog hapus spesies ke server, dan menambahkan fungsi auto-refresh ketika admin melakukan penambahan/pembaruan spesies.
*   **[species_form_screen.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/screens/admin/species_form_screen.dart):** Menghubungkan formulir input ke server dengan memicu `ApiService.addButterfly()` (untuk spesies baru) atau `ApiService.updateButterfly()` (untuk pengeditan spesies lama).

---

## Rencana Pengujian (Verifikasi)

1.  **Pengujian Autentikasi:** Mendaftar akun baru lewat aplikasi -> Logout -> Coba login kembali dengan akun yang sama -> Tutup aplikasi lalu buka lagi untuk memastikan auto-login berfungsi.
2.  **Pengujian Deteksi CNN & Koleksi:**
    *   Masuk sebagai pengguna biasa, masuk ke tab Scan, lalu unggah gambar kupu-kupu.
    *   Periksa hasil identifikasi, lalu tekan tombol "Simpan ke Koleksi".
    *   Masuk ke tab Koleksi, pastikan kupu-kupu yang baru saja di-scan statusnya telah terbuka (*unlocked*) dan menampilkan gambar serta deskripsi lengkapnya.
3.  **Pengujian Manajemen Admin:**
    *   Login menggunakan akun admin (misalnya akun dengan role `admin` di database).
    *   Buka panel admin, lakukan penambahan spesies baru -> pastikan data berhasil masuk ke database Laravel dan secara instan dapat dilihat oleh user biasa di tab Koleksi.
