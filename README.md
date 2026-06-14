# Mothra App — Aplikasi Identifikasi Kupu-Kupu Beracun Berbasis CNN

Mothra App adalah proyek monorepo aplikasi seluler (Flutter) yang diintegrasikan dengan REST API (Laravel) dan Model Kecerdasan Buatan (Python TensorFlow Lite) untuk mengidentifikasi spesies kupu-kupu beserta status toksisitasnya (beracun/aman).

---

## Arsitektur Sistem

```
┌──────────────────┐               ┌─────────────────┐               ┌────────────────────────┐
│ Flutter Frontend │  ───(API)───> │ Laravel Backend │  ──(Exec)───> │   Python Interpreter   │
│  (Aplikasi HP)   │  <──(JSON)─── │   (Port 8000)   │  <──(JSON)─── │ (venv - predict.py)   │
└──────────────────┘               └─────────────────┘               └────────────────────────┘
```

---

## Prerequisites
Pastikan komputer Anda sudah terinstal perlengkapan berikut:
* **Flutter SDK** (Versi >= 3.5.0)
* **PHP** (Versi >= 8.2) & **Composer**
* **DBMS** (PostgreSQL / MySQL)
* **Python** (Versi >= 3.10)

---

## Panduan Setup Lokal

### Langkah 1: Kloning Repositori
```bash
git clone https://github.com/Ogik29/tubes-apb-butterfly.git
cd tubes-apb-butterfly
```

---

### Langkah 2: Setup Backend Laravel (`mothra-backend`)

1. **Masuk ke folder backend**:
   ```bash
   cd mothra-backend
   ```
2. **Install dependensi PHP**:
   ```bash
   composer install
   ```
3. **Salin file konfigurasi `.env`**:
   * Di Windows (CMD):
     ```cmd
     copy .env.example .env
     ```
   * Di macOS / Linux / Git Bash:
     ```bash
     cp .env.example .env
     ```
4. **Generate Application Key**:
   ```bash
   php artisan key:generate
   ```
5. **Konfigurasi Database di `.env`**:
   Buat database baru di PostgreSQL atau MySQL Anda (contoh: `mothra_db`), lalu sesuaikan pengaturan di `.env`:
   ```env
   DB_CONNECTION=pgsql # ganti ke mysql jika memakai MySQL
   DB_HOST=127.0.0.1
   DB_PORT=5432 # ganti ke 3306 jika memakai MySQL
   DB_DATABASE=mothra_db
   DB_USERNAME=postgres # sesuaikan username db Anda
   DB_PASSWORD=root # sesuaikan password db Anda
   ```
6. **Tentukan Path Python Virtual Environment di `.env`**:
   Tambahkan baris berikut di paling bawah file `.env`:
   ```env
   PYTHON_BINARY=venv/Scripts/python.exe
   ```
   *(Untuk pengguna macOS/Linux, gunakan `PYTHON_BINARY=venv/bin/python`)*
7. **Jalankan Migrasi Database & Seeder**:
   Langkah ini membuat tabel dan mengisi data master spesies kupu-kupu beserta akun admin awal:
   ```bash
   php artisan migrate --seed
   ```
8. **Buat Link Storage (Symlink)**:
   Diperlukan agar gambar hasil pemindaian di folder storage backend dapat diakses oleh aplikasi Flutter:
   ```bash
   php artisan storage:link
   ```
9. **Jalankan Server Laravel**:
   Agar server dapat diakses dari perangkat lain (seperti HP fisik), jalankan dengan host `0.0.0.0`:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

---

### Langkah 3: Setup Python Virtual Environment (Model AI)

1. **Buat Virtual Environment baru**:
   Jalankan perintah ini di dalam direktori `mothra-backend`:
   ```bash
   python -m venv venv
   ```
2. **Aktifkan Virtual Environment**:
   * Windows (PowerShell): `venv\Scripts\activate.ps1`
   * Windows (CMD): `venv\Scripts\activate.bat`
   * macOS / Linux: `source venv/bin/activate`
3. **Upgrade pip dan install dependensi**:
   ```bash
   pip install --upgrade pip
   pip install -r ml/requirements.txt
   ```
4. **Matikan Virtual Environment**:
   Setelah instalasi sukses, matikan virtual environment dengan mengetik:
   ```bash
   deactivate
   ```

---

### Langkah 4: Setup Frontend Flutter

Buka terminal baru di direktori utama/root proyek (`tubes-apb-butterfly`).

1. **Install dependensi Flutter**:
   ```bash
   flutter pub get
   ```
2. **Konfigurasi Alamat IP Server**:
   Buka file [api_service.dart](file:///d:/Flutter/tubes_apb_mothra/lib/app/services/api_service.dart) dan sesuaikan properti `baseUrl`:
   * **Menggunakan HP Fisik**: Ganti `laptopIp` dengan IP Wi-Fi laptop Anda (dapat dicari dengan perintah `ipconfig` di Windows CMD). Pastikan HP dan laptop terhubung ke Wi-Fi yang sama.
   * **Menggunakan Android Emulator**: Anda dapat mengembalikannya ke `'http://10.0.2.2:8000'`.
3. **Jalankan Aplikasi**:
   Pastikan perangkat emulator atau HP fisik Anda telah terdeteksi (`flutter devices`), kemudian jalankan:
   ```bash
   flutter run
   ```

---

## Seeder
Anda dapat menggunakan kredensial berikut untuk masuk ke aplikasi setelah menjalankan seed:

* **Akun Admin**:
  * Email: `atmint@gmail.com`
  * Password: `password123`
* **Akun Pengguna Biasa**:
  * Email: `user@gmail.com`
  * Password: `password123`

---

## Troubleshooting
* **Pesan "Prediksi model gagal" saat memindai**:
  Pastikan Anda telah membuat virtual environment python (`venv`) dengan benar dan menginstal seluruh package di `ml/requirements.txt`.
* **Koneksi Ditolak/Timeout di HP Fisik**:
  1. Pastikan server Laravel dijalankan menggunakan parameter `--host=0.0.0.0`.
  2. Pastikan Windows Firewall Anda tidak memblokir port `8000`.
  3. Pastikan HP dan laptop Anda berada dalam satu subnet/jaringan Wi-Fi yang sama.
