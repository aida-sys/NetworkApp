# Prompt: menambahkan mode POS local network tanpa merusak standalone

```text
Saya ingin menambahkan mode POS local network pada repo ini tanpa merusak versi standalone yang sudah ada. Kerjakan implementasinya sampai siap diuji dan dijalankan; jangan berhenti pada proposal, skeleton API, atau dokumentasi saja.

## Konteks repo

- Aplikasi desktop Windows Python/PySide6 ada di root repo (`app/`, `main.py`). Arsitekturnya memakai service/repository, SQLAlchemy, dan SQLite.
- Aplikasi Flutter ada di `android/kasirin_mobile/`, dipakai untuk Android dan web. Saat ini `PosRepository` mengakses database lokal langsung melalui Drift/SQLite.
- Flutter Android/web dan aplikasi desktop memiliki penyimpanan lokal masing-masing. Belum ada sinkronisasi transaksi POS.
- Folder `server/` yang sudah ada adalah server billing/lisensi. Jangan menganggapnya sebagai POS API dan jangan mencampur API transaksi dengan endpoint billing tanpa alasan yang jelas.
- Flutter web sudah memiliki dukungan database browser serta penanganan file browser. Pertahankan perubahan yang ada di working tree.

## Tujuan

Bangun mode LAN dengan satu sumber data pusat:

- Satu komputer Windows toko menjalankan POS API dan database pusat di disk lokal komputer itu.
- Aplikasi desktop, Android, dan browser menjadi klien yang berkomunikasi dengan API.
- File SQLite pusat tidak boleh dibuka langsung oleh klien melalui shared folder, SMB, atau drive jaringan.
- Billing/lisensi tetap dipisahkan dari API transaksi POS.

## Aturan kompatibilitas yang wajib

1. **Standalone harus tetap menjadi default dan tetap berfungsi seperti sekarang.**
   - Jangan menghapus, mengganti, atau mengubah perilaku repository/database lokal yang dipakai standalone.
   - Jangan otomatis mengubah instalasi atau database lama menjadi mode LAN.
   - Jangan melakukan dual-write ke database lokal dan server.
   - Jangan menggabungkan data secara diam-diam.

2. **Tambahkan mode LAN sebagai jalur eksplisit.**
   - Pilih mekanisme konfigurasi yang sesuai dengan tiap aplikasi, misalnya mode/build config atau pilihan setup yang disimpan dengan aman.
   - Build dan instalasi default tetap standalone.
   - Jangan mengizinkan satu instalasi berpindah mode setelah memiliki data tanpa alur migrasi yang jelas, konfirmasi, dan backup.
   - Saat klien LAN kehilangan koneksi ke server, jangan diam-diam jatuh kembali menulis ke database lokal. Tampilkan status/error yang jelas.

3. **Jaga pekerjaan yang sudah ada.**
   - Awali dengan membaca `git status` dan diff yang sudah ada.
   - Jangan menjalankan `git reset`, checkout yang membuang perubahan, atau menghapus file yang belum dibuat olehmu.
   - Jangan menimpa perubahan pengguna atau perubahan web yang telah ada.

## Arsitektur yang diharapkan

- Buat layanan POS API terpisah dari billing. Gunakan FastAPI bila sesuai dengan stack repo.
- Investigasi apakah service, repository, dan model SQLAlchemy di aplikasi desktop bisa dipakai ulang oleh API dengan aman.
- Jangan menyalin aturan bisnis ke API dan klien jika aturan itu dapat ditangani di satu tempat.
- Flutter standalone tetap memakai repository lokal. Tambahkan kontrak/repository remote untuk mode LAN, lalu arahkan provider ke implementasi yang sesuai konfigurasi.
- Aplikasi desktop standalone tetap menggunakan alur lokal yang ada. Tambahkan jalur remote/API untuk mode LAN; jangan membuat desktop LAN membaca file database server secara langsung.
- Gunakan DTO/API contract yang eksplisit dan berversi. Dokumentasikan pemetaan jika skema backend Python berbeda dari skema Drift Flutter.
- Tempatkan database server di disk lokal server. Untuk skala toko kecil, evaluasi apakah SQLite yang hanya diakses backend cukup; jika beban tulis/kebutuhan konkurensi menuntut, gunakan PostgreSQL. Jelaskan keputusan dan cara backup/restore.
- Web app sebaiknya dapat disajikan dari server yang sama agar URL API/CORS sederhana. Untuk Android, sediakan konfigurasi alamat server LAN yang praktis, tidak hard-coded ke IP developer.
- Server harus bisa bind ke interface LAN melalui konfigurasi yang terdokumentasi. Batasi akses dengan autentikasi dan konfigurasi firewall; jangan mengeksposnya ke internet secara default.

## Fitur dan aturan transaksi

Inventarisasi fitur aktif yang tersedia pada desktop dan Flutter. Buat matriks parity lokal/LAN dan pastikan klien LAN tidak melakukan perubahan lokal untuk fitur yang belum didukung API.

Minimal, API LAN harus menangani:
- autentikasi, user, role, izin, dan identitas toko;
- produk, kategori, harga, stok, pemasok;
- shift kasir;
- checkout, pembayaran, stok, jurnal/ledger, dan audit log;
- pembelian/penerimaan barang;
- laporan serta pengaturan toko yang tersedia di UI.

Checkout harus ditentukan dan disimpan server secara atomik. Server memvalidasi harga, jumlah, stok, shift, pembayaran, dan izin; klien tidak boleh menjadi sumber kebenaran stok/harga. Tambahkan idempotency key pada operasi transaksi agar retry jaringan tidak membuat transaksi atau pembayaran ganda. Cegah overselling saat dua kasir memesan stok yang sama.

Untuk versi LAN pertama, jika server tidak tersedia, tolak operasi tulis dengan pesan yang jelas. Jangan membuat antrean transaksi offline kecuali kamu juga menyelesaikan sinkronisasi, konflik stok, retry, dan deduplikasi secara aman. Cache baca boleh digunakan hanya jika status stale ditampilkan dengan jelas.

## Migrasi data

Sediakan prosedur yang aman untuk memindahkan data standalone ke server:
- backup sebelum migrasi;
- preview jumlah record dan validasi;
- pemetaan skema eksplisit;
- impor yang dapat diulang tanpa membuat duplikat;
- laporan sukses/gagal;
- tidak pernah mengubah atau menghapus database sumber saat impor.

Jangan mengaktifkan migrasi otomatis saat aplikasi dibuka.

## Cara kerja

1. Audit arsitektur dan fitur yang ada; tulis temuan singkat dan rencana file/komponen yang akan disentuh.
2. Catat baseline test/build yang relevan sebelum perubahan.
3. Implementasikan API dan repository remote secara bertahap.
4. Hubungkan desktop, Android, dan web ke API dalam mode LAN, sambil memastikan mode standalone tetap memakai jalur lama.
5. Tambahkan konfigurasi server, instruksi instalasi, backup/restore, migrasi data, dan troubleshooting.
6. Jalankan test suite yang relevan, test integrasi API dengan database sementara, analisis/build Flutter Android dan web, serta test/build desktop yang tersedia.
7. Perbaiki semua kegagalan yang disebabkan perubahanmu. Jangan menyatakan selesai jika ada jalur UI LAN yang masih menulis langsung ke database lokal atau hanya pura-pura berhasil.

## Acceptance criteria

Pekerjaan dianggap selesai hanya bila:

- Mode standalone default tetap menggunakan database lokal lama dan test/regresi yang relevan lulus.
- Mode LAN mengarahkan operasi POS ke API dan database pusat.
- Desktop, Android, dan web dapat tersambung ke server melalui LAN dengan konfigurasi yang terdokumentasi.
- Tidak ada akses klien langsung ke file SQLite server.
- Kehilangan koneksi server tidak menyebabkan fallback tulis ke database lokal.
- Checkout aman terhadap retry jaringan, stok tidak bisa negatif akibat transaksi bersamaan, dan transaksi tersimpan atomik.
- Migrasi dari data standalone dilakukan eksplisit, dapat diuji, dan tidak mengubah sumber.
- Server LAN tidak bercampur dengan billing/lisensi.
- Dokumentasi menjelaskan cara menjalankan server, alamat klien, port/firewall, backup/restore, migrasi, serta cara kembali memakai standalone tanpa menghapus data.
- Semua test/build yang relevan dilaporkan dengan hasil sebenarnya.

Kerjakan secara mandiri dan teruskan sampai acceptance criteria terpenuhi. Jangan berhenti untuk meminta konfirmasi atas pilihan implementasi rutin. Jika menemukan keputusan produk yang benar-benar tidak bisa ditentukan dari repo, jelaskan opsi, pilih asumsi paling aman untuk standalone, lanjutkan pekerjaan yang tidak bergantung pada keputusan itu, lalu tanyakan hanya hal yang betul-betul memblokir.
```
