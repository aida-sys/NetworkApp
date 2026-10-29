# Kasirin Mobile

Flutter/Dart POS client for Android and iOS. POS data is stored in a separate app-private SQLite database on each device. There is no transaction synchronization with the desktop app or billing server.

## Toolchain & Versions

- Flutter stable 3.24+ / 3.27+ with Dart 3.5+
- Android Gradle Plugin (AGP): `8.7.0`
- Gradle: `8.9` (via `gradle/wrapper/gradle-wrapper.properties`)
- Kotlin: `2.0.21`
- Minimum Android SDK: `23` (`minSdk = 23`)
- Application ID: `com.kasirin.kasirin_mobile`

## Local Development & Build Commands

From `android/kasirin_mobile/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
flutter build web --release --no-web-resources-cdn
```

The web release is written to `build/web`. `--no-web-resources-cdn` bundles
Flutter's rendering engine with the app, so the page does not depend on Google's
CDN being reachable. Serve the folder over HTTP or HTTPS; do not open
`build/web/index.html` as a `file://` URL because browsers block the database
WASM and worker there. For a local preview, run this from `android/kasirin_mobile/`:

```powershell
python -m http.server 8080 --directory build/web --bind 127.0.0.1
```

Then open `http://localhost:8080`. Browser data is stored locally in that
browser profile and is separate from the Android database.

Or using the convenience script at `android/start_flutter1.ps1`.

## App Architecture & UI Overview

1. **Inisialisasi & Setup Toko (`/setup`)**:
   - Jika database baru/kosong (`setupRequired == true`), diarahkan otomatis ke setup OWNER tanpa data demo.
   - Mengisi Nama Lengkap, Username, Nama Toko, Password, dan Konfirmasi Password.
   - Membuat toko default `MAIN`, roles bawaan (`OWNER`, `ADMIN`, `SUPERVISOR`, `CASHIER`), dan akun pemilik utama.

2. **Autentikasi Lokal (`/login`)**:
   - Validasi username dan password menggunakan PBKDF2 hash yang aman.
   - Fitur proteksi: penolakan user nonaktif, pembatasan 5x percobaan gagal (lockout 15 menit), dan pencatatan histori login.
   - Role-based routing: Akun `CASHIER` langsung diarahkan ke layar kasir (`/cashier`).

3. **Kasir POS (`/cashier`)**:
   - Manajemen shift (Buka shift dengan modal awal kas, tutup shift dengan kas akhir).
   - Katalog produk real-time dengan pencarian cepat nama, SKU, dan barcode.
   - Keranjang belanja interaktif dengan pengaturan quantity stepper (+ / -), subtotal, dan perhitungan harga grosir bertingkat (bulk price rules).
   - Checkout tunai (Cash) dengan nominal cepat (Uang Pas, pecahan uang), validasi kembalian, transaksi atomic SQLite (sale, items, payment, stock movement, balanced double-entry journal, audit log), dan struk transaksi.

4. **Dashboard Utama (`/`)**:
   - Ringkasan statistik operasional: Omzet penjualan hari ini, total produk aktif, dan status shift.
   - Navigasi touch-first cepat ke Kasir, Master Data, Laporan, Karyawan, Belanja, Pengaturan, dan Lisensi.

5. **Master Data Produk (`/master-data`)**:
   - Daftar produk dengan status stok dan indikator stok menipis.
   - Tambah produk baru (SKU, barcode, nama, harga beli, harga jual, stok awal, stok minimum).
   - Nonaktifkan/hapus produk.

6. **Manajemen Karyawan (`/user-management`)**:
   - Daftar staf dan hak akses (OWNER, ADMIN, SUPERVISOR, CASHIER).
   - Dialog pendaftaran karyawan baru dengan validasi username unik dan password hash.

7. **Pusat Laporan & Keuangan (`/report-center`)**:
   - Ringkasan omzet, total transaksi harian, dan daftar riwayat faktur penjualan terbaru.
   - Peringatan stok menipis (low stock alerts).

8. **Pengaturan Toko (`/store-settings`)**:
   - Ubah nama toko, slogan, alamat, dan nomor WhatsApp.

9. **Lisensi & Aktivasi (`/license`)**:
   - Status lisensi trial/aktif, identifikasi perangkat, dan uji konektivitas ke billing server.
