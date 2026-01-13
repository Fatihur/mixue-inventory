import 'package:cloud_firestore/cloud_firestore.dart';

class BarangModel {
  final String id;
  final String nama;
  final String barcode;
  final String kategori;
  final String satuan;
  final int stok;
  final int stokMinimal;
  final int pcsPerBox; // Jumlah pcs per box/dus
  final double harga;
  final String deskripsi;
  final DateTime dibuatPada;
  final DateTime diubahPada;

  BarangModel({
    required this.id,
    required this.nama,
    required this.barcode,
    required this.kategori,
    required this.satuan,
    required this.stok,
    required this.stokMinimal,
    required this.pcsPerBox,
    required this.harga,
    required this.deskripsi,
    required this.dibuatPada,
    required this.diubahPada,
  });

  factory BarangModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BarangModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      barcode: data['barcode'] ?? '',
      kategori: data['kategori'] ?? '',
      satuan: data['satuan'] ?? 'pcs',
      stok: data['stok'] ?? 0,
      stokMinimal: data['stok_minimal'] ?? 0,
      pcsPerBox: data['pcs_per_box'] ?? 1,
      harga: (data['harga'] ?? 0).toDouble(),
      deskripsi: data['deskripsi'] ?? '',
      dibuatPada: (data['dibuat_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diubahPada: (data['diubah_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'barcode': barcode,
      'kategori': kategori,
      'satuan': satuan,
      'stok': stok,
      'stok_minimal': stokMinimal,
      'pcs_per_box': pcsPerBox,
      'harga': harga,
      'deskripsi': deskripsi,
      'dibuat_pada': Timestamp.fromDate(dibuatPada),
      'diubah_pada': Timestamp.fromDate(diubahPada),
    };
  }

  BarangModel copyWith({
    String? id,
    String? nama,
    String? barcode,
    String? kategori,
    String? satuan,
    int? stok,
    int? stokMinimal,
    int? pcsPerBox,
    double? harga,
    String? deskripsi,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) {
    return BarangModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      barcode: barcode ?? this.barcode,
      kategori: kategori ?? this.kategori,
      satuan: satuan ?? this.satuan,
      stok: stok ?? this.stok,
      stokMinimal: stokMinimal ?? this.stokMinimal,
      pcsPerBox: pcsPerBox ?? this.pcsPerBox,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diubahPada: diubahPada ?? this.diubahPada,
    );
  }

  // Kalkulasi jumlah box/dus dari stok pcs
  int get jumlahBox => pcsPerBox > 0 ? (stok / pcsPerBox).floor() : 0;
  
  // Sisa pcs yang tidak cukup untuk 1 box
  int get sisaPcs => pcsPerBox > 0 ? stok % pcsPerBox : stok;
  
  // Format stok dalam box dan pcs
  String get stokFormatted {
    if (pcsPerBox <= 1) {
      return '$stok pcs';
    }
    if (sisaPcs > 0) {
      return '$jumlahBox box + $sisaPcs pcs';
    }
    return '$jumlahBox box';
  }
  
  // Cek apakah stok rendah (berdasarkan jumlah box)
  bool get isStokRendah => jumlahBox <= stokMinimal;
}

