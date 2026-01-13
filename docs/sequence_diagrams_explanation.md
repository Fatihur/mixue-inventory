# Penjelasan Sequence Diagram - Sistem Inventory Mixue

## 1. Sequence Diagram: Login

Diagram ini menunjukkan proses autentikasi pengguna. User memasukkan email dan password di LoginScreen, diteruskan ke AuthProvider dan AuthService untuk validasi via Firebase Auth. Sistem mengambil data user dari Firestore. Jika status nonaktif, logout otomatis. Jika aktif, redirect ke dashboard sesuai role.

---

## 2. Sequence Diagram: Tambah Barang dengan Scan QR Code

Diagram ini menunjukkan proses penambahan barang oleh Admin. Admin klik Tambah, scan QR Code via MobileScanner, barcode terisi otomatis. Admin lengkapi data dan simpan. FirestoreService menyimpan data ke collection 'barang'.

---

## 3. Sequence Diagram: Input Barang Masuk

Diagram ini menunjukkan proses pencatatan barang masuk oleh Karyawan. Karyawan scan barcode, sistem cari barang di Firestore. Jika ditemukan, tampilkan info barang. Karyawan input jumlah, sistem simpan transaksi ke 'barang_masuk' dan update stok bertambah.

---

## 4. Sequence Diagram: Input Barang Terpakai

Diagram ini menunjukkan proses pencatatan barang terpakai oleh Karyawan. Karyawan scan barcode, sistem tampilkan info barang. Karyawan input jumlah. Jika jumlah <= stok, sistem simpan transaksi ke 'barang_terpakai' dan update stok berkurang.

---

## 5. Sequence Diagram: Input Barang Expired

Diagram ini menunjukkan proses pencatatan barang expired oleh Karyawan. Karyawan scan barcode, input jumlah dan tanggal expired. Sistem simpan transaksi ke collection 'expired' dan update stok berkurang.

---

## 6. Sequence Diagram: Manajemen User

Diagram ini menunjukkan proses pengelolaan user oleh Admin. Admin dapat melihat daftar user via Stream Firestore, menambah user baru via Firebase Auth, atau toggle status user aktif/nonaktif.

---

## 7. Sequence Diagram: Lihat Laporan

Diagram ini menunjukkan proses melihat laporan oleh Admin. Admin pilih rentang tanggal, sistem ambil data dari collection barang_masuk, barang_terpakai, dan expired. Sistem kalkulasi summary dan tampilkan laporan. Admin dapat export ke Excel/PDF via ExportService.

---

## 8. Sequence Diagram: Cek Notifikasi Stok Rendah

Diagram ini menunjukkan proses pengecekan stok rendah saat membuka Dashboard. Sistem ambil data barang via Stream, hitung jumlahBox = stok/pcsPerBox, cek isStokRendah = (jumlahBox <= stokMinimal). Jika ada stok rendah, tampilkan notifikasi warning.

---

## 9. Sequence Diagram: Input Order

Diagram ini menunjukkan proses pembuatan order oleh Admin. Admin pilih barang dan input jumlah, dapat menambah multiple items. Sistem generate nomor order, simpan ke collection 'order', dan update stok berkurang untuk setiap item.

---

## 10. Sequence Diagram: Input Refund

Diagram ini menunjukkan proses pencatatan refund oleh Admin. Admin pilih order, input jumlah dan alasan refund. Sistem simpan ke collection 'refund' dan update status order menjadi 'refunded'.
