# Product Requirements Document

## Product Name
Catatan Harian

## Version
1.0.0

## Owner
Samuel

## Product Summary
Catatan Harian adalah aplikasi Flutter offline untuk membantu pengguna mencatat kegiatan harian, ide, tugas, dan hal penting secara cepat tanpa koneksi internet. Aplikasi berfokus pada kemudahan penggunaan, performa ringan, dan penyimpanan lokal sederhana menggunakan `shared_preferences`.

## Background
Banyak pengguna membutuhkan aplikasi catatan yang ringan, cepat dibuka, dan tidak bergantung pada login atau layanan cloud. Aplikasi ini ditujukan untuk kebutuhan pencatatan pribadi yang sederhana dengan tampilan modern dan mudah dipahami, terutama untuk pengguna pemula.

## Goals
- Membantu pengguna menyimpan catatan harian secara offline.
- Menyediakan alur tambah, edit, hapus, dan cari catatan yang cepat.
- Menyediakan filter kategori dan urutan catatan agar isi mudah ditemukan.
- Menyediakan mode gelap untuk kenyamanan penggunaan.
- Menjaga implementasi sederhana, stabil, dan mudah dijalankan.

## Non-Goals
- Sinkronisasi cloud.
- Login dan manajemen akun.
- Kolaborasi antar pengguna.
- Lampiran gambar, audio, atau file.
- Notifikasi, pengingat pintar, atau integrasi kalender.

## Target Users
- Mahasiswa yang ingin mencatat ide kuliah dan tugas.
- Pekerja yang ingin menyimpan agenda atau poin penting.
- Pengguna umum yang membutuhkan catatan harian sederhana.

## Problem Statement
Pengguna membutuhkan tempat menyimpan catatan secara cepat tanpa hambatan login, internet, atau setup tambahan. Banyak aplikasi catatan terlalu kompleks untuk kebutuhan harian sederhana. Catatan Harian menyelesaikan masalah itu dengan pengalaman offline-first yang ringan dan fokus.

## Success Metrics
- Aplikasi dapat berjalan langsung setelah `flutter pub get` dan `flutter run`.
- Catatan tetap tersimpan setelah aplikasi ditutup dan dibuka ulang.
- Pengguna dapat menambah, mengedit, menghapus, dan menandai favorit tanpa error.
- Pengguna dapat menemukan catatan melalui pencarian, filter, dan sort.

## Core Features

### 1. Splash Screen
- Menampilkan icon catatan.
- Menampilkan nama aplikasi dan subtitle.
- Otomatis berpindah ke Home Screen setelah 2 detik.

### 2. Home Screen
- Menampilkan daftar catatan dalam bentuk card.
- Menampilkan judul, potongan isi, kategori, tanggal dibuat, dan indikator favorit.
- Menampilkan empty state jika belum ada catatan.
- Menyediakan search bar, filter kategori, dan dropdown sort.
- Menyediakan menu ke halaman Pengaturan dan Tentang.

### 3. Add Note
- Form judul, isi, dan kategori.
- Validasi judul dan isi wajib diisi dengan batas minimal karakter.
- Data disimpan ke local storage dan halaman sebelumnya direfresh.

### 4. Detail Note
- Menampilkan detail catatan lengkap.
- Menampilkan tanggal dibuat, tanggal edit terakhir, kategori, dan status favorit.
- Menyediakan aksi edit, hapus, dan favorit.

### 5. Edit Note
- Menggunakan form yang sama dengan tambah catatan.
- Nilai lama otomatis muncul.
- Menyimpan perubahan ke local storage dengan `updatedAt`.

### 6. Delete Note
- Meminta konfirmasi sebelum menghapus.
- Setelah hapus, daftar di Home diperbarui.

### 7. Favorite
- Catatan dapat ditandai sebagai favorit dari halaman detail.
- Status favorit tersimpan secara lokal.

### 8. Settings
- Menyediakan switch mode gelap.
- Pilihan tema tersimpan dan dipulihkan saat aplikasi dibuka lagi.

### 9. About
- Menampilkan nama aplikasi, versi, deskripsi, teknologi, dan nama pembuat.

## Functional Requirements
- Aplikasi harus berjalan tanpa backend, API, Firebase, atau Supabase.
- Semua data catatan harus disimpan lokal dengan `shared_preferences`.
- Catatan harus disimpan sebagai JSON string.
- Catatan terbaru harus tampil paling atas pada mode sort default.
- Search harus bekerja pada judul dan isi catatan.
- Filter kategori harus memperbarui daftar secara langsung.
- Sort harus mendukung `Terbaru`, `Terlama`, `Judul A-Z`, dan `Judul Z-A`.
- Navigasi harus menggunakan `Navigator`.
- Jika ada perubahan data, halaman sebelumnya harus bisa reload menggunakan `Navigator.pop(context, true)`.

## Non-Functional Requirements
- UI harus sederhana, modern, dan responsif pada Android.
- Teks harus mudah dibaca dalam mode terang dan gelap.
- Struktur kode harus mudah dipahami pemula.
- Waktu akses data harus cepat karena seluruh data bersifat lokal.

## Data Model

### Note
- `String id`
- `String title`
- `String content`
- `String category`
- `bool isFavorite`
- `DateTime createdAt`
- `DateTime? updatedAt`

## Storage Strategy
- Semua catatan disimpan dalam satu key `SharedPreferences`.
- Value disimpan sebagai JSON array string.
- Tema dark mode disimpan terpisah sebagai boolean.

## User Flow
1. Pengguna membuka aplikasi dan melihat splash screen.
2. Pengguna masuk ke Home Screen.
3. Pengguna menambah catatan dari tombol `+`.
4. Catatan tersimpan lokal dan muncul di Home Screen.
5. Pengguna dapat membuka detail, edit, hapus, cari, filter, atau tandai favorit.
6. Pengguna dapat mengubah tema di halaman Pengaturan.

## Risks
- `shared_preferences` cocok untuk data ringan, tetapi kurang ideal jika jumlah catatan sangat besar.
- Jika struktur JSON berubah di masa depan, perlu strategi migrasi data sederhana.

## Future Enhancements
- Ekspor dan impor catatan.
- Penguncian aplikasi dengan PIN lokal.
- Lampiran gambar.
- Pengelompokan atau tag tambahan.
- Backup manual ke file lokal.
