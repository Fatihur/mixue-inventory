# Penjelasan Activity Diagram - Sistem Inventory Mixue

## 1. Activity Diagram: Login dan Logout

Diagram ini menunjukkan proses autentikasi pengguna ke dalam sistem. Pengguna memasukkan email dan password, sistem memvalidasi kredensial melalui Firebase Auth. Jika valid, sistem memeriksa status akun. Jika aktif, pengguna diarahkan ke dashboard sesuai role (Admin/Karyawan). Jika nonaktif, sistem logout otomatis. Untuk logout, pengguna mengklik tombol Logout dan sistem menghapus session.

---

## 2. Activity Diagram: Tambah Barang dengan Scan QR Code

Diagram ini menunjukkan proses penambahan barang baru oleh Admin. Admin membuka menu Manajemen Barang, klik Tambah, lalu scan QR Code pada kemasan. Jika QR terdeteksi, barcode terisi otomatis. Admin melengkapi data barang dan klik Simpan. Jika form valid, data disimpan ke database.

---

## 3. Activity Diagram: Input Barang Masuk

Diagram ini menunjukkan proses pencatatan barang masuk oleh Karyawan. Karyawan scan barcode barang, sistem mencari data barang. Jika ditemukan, sistem menampilkan info barang. Karyawan input jumlah dan keterangan, lalu simpan. Sistem menyimpan transaksi dan update stok bertambah.

---

## 4. Activity Diagram: Input Barang Terpakai

Diagram ini menunjukkan proses pencatatan barang terpakai oleh Karyawan. Karyawan scan barcode, sistem menampilkan info barang. Karyawan input jumlah terpakai. Jika jumlah tidak melebihi stok, sistem menyimpan transaksi dan update stok berkurang. Jika melebihi, tampilkan error "Stok tidak mencukupi".

---

## 5. Activity Diagram: Input Barang Expired

Diagram ini menunjukkan proses pencatatan barang expired oleh Karyawan. Karyawan scan barcode, sistem menampilkan info barang. Karyawan input jumlah expired dan tanggal expired. Jika valid, sistem menyimpan transaksi dan update stok berkurang.

---

## 6. Activity Diagram: Manajemen User

Diagram ini menunjukkan proses pengelolaan user oleh Admin. Admin dapat melihat daftar user, menambah user baru dengan mengisi data dan menyimpan ke Firebase Auth, atau mengubah status user (aktif/nonaktif) dengan toggle.

---

## 7. Activity Diagram: Lihat Laporan

Diagram ini menunjukkan proses melihat laporan oleh Admin. Admin memilih rentang tanggal dan klik Filter. Sistem mengambil data transaksi, kalkulasi summary, dan menampilkan laporan. Admin dapat export laporan ke Excel/PDF.

---

## 8. Activity Diagram: Cek Stok Rendah

Diagram ini menunjukkan proses pengecekan stok rendah saat membuka Dashboard. Sistem mengambil data barang, menghitung jumlah box (stok/pcsPerBox), dan membandingkan dengan stok minimal. Jika ada stok rendah, tampilkan notifikasi warning.

---

## 9. Activity Diagram: Input Order

Diagram ini menunjukkan proses pembuatan order oleh Admin. Admin memilih barang dan input jumlah. Jika stok mencukupi, barang ditambahkan ke keranjang. Admin dapat menambah barang lain atau simpan order. Sistem menyimpan transaksi dan update stok berkurang.

---

## 10. Activity Diagram: Input Refund

Diagram ini menunjukkan proses pencatatan refund oleh Admin. Admin memilih order yang akan di-refund, input jumlah dan alasan refund. Jika valid, sistem menyimpan transaksi refund dan update status order menjadi 'refunded'.
