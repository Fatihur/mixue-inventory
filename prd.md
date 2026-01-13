

# 📘 PRODUCT REQUIREMENTS DOCUMENT (PRD)

## **Mixue Inventory – Flutter + Firebase**

---

# **1. Ringkasan Produk**

**Mixue Inventory** adalah aplikasi untuk mengelola stok barang Mixue berbasis Flutter + Firebase. Sistem memiliki dua role: **Admin** dan **Karyawan**, dengan akses fitur yang berbeda. Admin memiliki akses penuh termasuk **manajemen user**.

---

# **2. Tujuan Produk**

* Mengoptimalkan proses pencatatan stok secara real-time.
* Mengurangi kesalahan manual dengan barcode scanning.
* Menyediakan laporan secara berkala.
* Menerapkan autentikasi login/logout dan kontrol akses role.
* Memungkinkan admin untuk mengelola akun pengguna.

---

# **3. Peran Pengguna & Hak Akses**

---

## **3.1 Admin**

Akses penuh pada Mixue Inventory:

### **Fitur Admin:**

* Login & logout.
* Manajemen barang (CRUD).
* Manajemen order (CRUD).
* Manajemen refund (CRUD).
* Melihat stok barang real-time.
* Melihat laporan (harian, mingguan, bulanan).
* Cetak/export laporan (PDF/CSV).
* Melihat seluruh histori transaksi.
* **Manajemen User (Baru ditambahkan):**

  * Tambah user baru (admin atau karyawan).
  * Edit data user.
  * Reset password user.
  * Nonaktifkan / hapus user.
  * Melihat list seluruh user.

---

## **3.2 Karyawan**

Hak akses terbatas:

### **Fitur Karyawan:**

* Login & logout.
* Input barang masuk (scan barcode).
* Input barang expired.
* Input barang terpakai.
* Melihat daftar barang (read-only).

---

# **4. Fitur Manajemen User (Baru Ditambahkan)**

Fitur ini hanya muncul pada **Dashboard Admin**.

---

## **4.1 List User**

Admin dapat melihat seluruh user dalam aplikasi:

| Informasi Ditampilkan     |
| ------------------------- |
| nama                      |
| email                     |
| role (admin / karyawan)   |
| status (aktif / nonaktif) |
| tanggal dibuat            |
| tombol edit & hapus       |

---

## **4.2 Tambah User Baru**

Admin dapat membuat akun baru untuk karyawan/admin baru.

**Input form:**

* Nama lengkap
* Email
* Password awal
* Role (admin/karyawan)

**Proses teknis:**

1. Admin mengisi form.
2. Sistem memanggil Cloud Function / Firebase Admin SDK (opsional) untuk membuat user baru.
3. Data user otomatis dibuat pada koleksi `users`.
4. User bisa login menggunakan email & password yang diberikan admin.

> Catatan:
> Flutter **tidak bisa langsung membuat akun untuk orang lain** (kecuali membuat signUp normal).
> Solusi:
>
> * Menggunakan **Cloud Function** untuk membuat akun user lain tanpa logout admin.
> * Atau admin memberikan password awal, lalu user wajib reset password saat login pertama.

---

## **4.3 Edit User**

Admin dapat mengubah:

* nama
* role
* status (aktif / tidak aktif)

**Catatan:**

* Jika status user dinonaktifkan → sistem akan menolak login user tersebut.

---

## **4.4 Reset Password User**

Admin dapat melakukan tombol *"Reset Password"*:

**Opsi reset password:**

* Mengirim email reset password ke user.
* Atau admin menentukan password baru (menggunakan Cloud Function).

---

## **4.5 Hapus User**

Admin dapat menghapus akun user sepenuhnya.

**Dua opsi delete:**

1. Soft delete → ubah field `status = nonaktif` (lebih aman).
2. Hard delete → call Firebase Admin SDK → hapus dari Auth dan Firestore.

---

# **5. Flow Autentikasi Mixue Inventory**

### **Login**

1. User input email & password.
2. Firebase Auth verifikasi.
3. Sistem ambil role dari koleksi `users`.
4. Jika user status = nonaktif → login ditolak.
5. Arahkan ke dashboard sesuai role.

### **Logout**

* Admin/karyawan menekan tombol logout → FirebaseAuth.signOut() → kembali ke layar login.

---

# **6. Struktur Koleksi Database (Revisi)**

---

## **6.1 Koleksi: `users`**

Tambahan field untuk manajemen user.

| Field       | Tipe      | Deskripsi          |
| ----------- | --------- | ------------------ |
| uid         | String    | ID Firebase        |
| nama        | String    | Nama lengkap       |
| email       | String    | Email login        |
| role        | String    | admin / karyawan   |
| status      | String    | aktif / nonaktif   |
| dibuat_pada | Timestamp | Tanggal dibuat     |
| diubah_pada | Timestamp | Tanggal diperbarui |

---

## Koleksi lainnya **tetap sama** (barang, barang_masuk, barang_terpakai, expired, order, refund).

---

# **7. Interface Tambahan untuk Admin**

Admin akan memiliki menu baru:

### **Menu: Manajemen User**

* Daftar User
* Tambah User
* Edit User
* Hapus User
* Reset Password

Mockup UI bisa dibuat seperti:

```
-------------------------------------
|   Manajemen User – Mixue Inventory |
-------------------------------------
| [Tambah User]                      |
-------------------------------------
| Nama        | Role       | Aksi    |
-------------------------------------
| Budi        | Karyawan   | Edit ❘ Hapus |
| Sinta       | Admin      | Edit ❘ Hapus |
-------------------------------------
```

---

# **8. Keamanan & Role Access**

### **Route Guard (Dart)**

* Admin tidak bisa masuk area karyawan.
* Karyawan tidak bisa mengakses CRUD barang, laporan, atau manajemen user.

### **Firestore Security Rules**

* `users` koleksi hanya boleh dibaca/ubah oleh admin.
* Karyawan hanya bisa baca data dirinya sendiri.

---

# **9. Kesimpulan**

Dengan tambahan **Manajemen User**, Mixue Inventory menjadi sistem yang lengkap untuk operasional Mixue, terutama untuk:

* Mengelola pergantian karyawan
* Mengatur akses aplikasi
* Menjaga keamanan data

---

