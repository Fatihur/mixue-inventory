# Mixue Inventory

Aplikasi manajemen inventory untuk Mixue berbasis Flutter + Firebase.

## Fitur

### Admin
- Login & logout
- Manajemen barang (CRUD)
- Manajemen order (CRUD)
- Manajemen refund (CRUD)
- Melihat stok barang real-time
- Melihat laporan (harian, mingguan, bulanan)
- Cetak/export laporan (PDF/CSV)
- Melihat seluruh histori transaksi
- Manajemen User (tambah, edit, reset password, nonaktifkan/hapus)

### Karyawan
- Login & logout
- Input barang masuk (dengan scan barcode)
- Input barang terpakai
- Input barang expired
- Melihat daftar barang (read-only)

## Persyaratan

- Flutter SDK 3.10+
- Firebase Project dengan:
  - Firebase Authentication (Email/Password)
  - Cloud Firestore

## Setup

### 1. Clone repository

```bash
git clone <repository-url>
cd mixue-inventory
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

File `google-services.json` sudah tersedia di `android/app/`. Untuk konfigurasi iOS atau platform lain, jalankan:

```bash
flutterfire configure
```

### 4. Deploy Firestore Security Rules

Upload file `firestore.rules` ke Firebase Console atau gunakan Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

### 5. Buat Admin Pertama

Untuk membuat admin pertama, buat user melalui Firebase Console:
1. Buka Firebase Console > Authentication > Users
2. Add user dengan email dan password
3. Buka Firestore Database > users collection
4. Buat dokumen dengan ID = UID user yang baru dibuat:

```json
{
  "uid": "<user-uid>",
  "nama": "Admin",
  "email": "admin@mixue.com",
  "role": "admin",
  "status": "aktif",
  "dibuat_pada": <timestamp>,
  "diubah_pada": <timestamp>
}
```

### 6. Run aplikasi

```bash
flutter run
```

## Struktur Folder

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   ├── barang_model.dart
│   ├── barang_masuk_model.dart
│   ├── barang_terpakai_model.dart
│   ├── barang_expired_model.dart
│   ├── order_model.dart
│   └── refund_model.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── admin/
│   │   ├── dashboard_admin.dart
│   │   ├── manajemen_user_screen.dart
│   │   ├── manajemen_barang_screen.dart
│   │   ├── manajemen_order_screen.dart
│   │   ├── manajemen_refund_screen.dart
│   │   ├── laporan_screen.dart
│   │   └── histori_transaksi_screen.dart
│   └── karyawan/
│       ├── dashboard_karyawan.dart
│       ├── barang_masuk_screen.dart
│       ├── barang_terpakai_screen.dart
│       ├── barang_expired_screen.dart
│       └── daftar_barang_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── loading_widget.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## Koleksi Firestore

- `users` - Data pengguna
- `barang` - Master data barang
- `barang_masuk` - Histori barang masuk
- `barang_terpakai` - Histori barang terpakai
- `expired` - Histori barang expired
- `order` - Data order
- `refund` - Data refund

## Catatan

- Untuk fitur tambah user oleh admin, admin perlu login ulang setelah membuat user baru (keterbatasan Firebase Auth client SDK)
- Untuk solusi yang lebih baik, implementasikan Cloud Functions untuk membuat user tanpa logout admin
