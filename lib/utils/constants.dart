import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE31837);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color secondary = Color(0xFFFFD700);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class AppStrings {
  static const String appName = 'Mixue Inventory';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String nama = 'Nama';
  static const String role = 'Role';
  static const String admin = 'Admin';
  static const String karyawan = 'Karyawan';
  static const String dashboard = 'Dashboard';
  static const String manajemenUser = 'Manajemen User';
  static const String manajemenBarang = 'Manajemen Barang';
  static const String manajemenOrder = 'Manajemen Order';
  static const String manajemenRefund = 'Manajemen Refund';
  static const String laporan = 'Laporan';
  static const String barangMasuk = 'Barang Masuk';
  static const String barangTerpakai = 'Barang Terpakai';
  static const String barangExpired = 'Barang Expired';
  static const String daftarBarang = 'Daftar Barang';
  static const String scanBarcode = 'Scan QR Code';
}

class AppCategories {
  static const List<String> barangKategori = [
    'Bahan Baku',
    'Packaging',
    'Topping',
    'Peralatan',
    'Lainnya',
  ];

  static const List<String> satuanBarang = [
    'pcs',
    'kg',
    'gram',
    'liter',
    'ml',
    'pack',
    'box',
    'karton',
  ];

  static const List<String> orderStatus = [
    'pending',
    'diproses',
    'selesai',
    'dibatalkan',
  ];

  static const List<String> refundStatus = [
    'pending',
    'disetujui',
    'ditolak',
    'selesai',
  ];
}
