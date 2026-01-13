import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final double harga;
  final double subtotal;

  OrderItemModel({
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      barangId: data['barang_id'] ?? '',
      namaBarang: data['nama_barang'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      harga: (data['harga'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barang_id': barangId,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'harga': harga,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String id;
  final String nomorOrder;
  final List<OrderItemModel> items;
  final double totalHarga;
  final String status;
  final String keterangan;
  final String userId;
  final String namaUser;
  final DateTime tanggal;

  OrderModel({
    required this.id,
    required this.nomorOrder,
    required this.items,
    required this.totalHarga,
    required this.status,
    required this.keterangan,
    required this.userId,
    required this.namaUser,
    required this.tanggal,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<OrderItemModel> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => OrderItemModel.fromMap(item))
          .toList();
    }
    return OrderModel(
      id: doc.id,
      nomorOrder: data['nomor_order'] ?? '',
      items: items,
      totalHarga: (data['total_harga'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      keterangan: data['keterangan'] ?? '',
      userId: data['user_id'] ?? '',
      namaUser: data['nama_user'] ?? '',
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomor_order': nomorOrder,
      'items': items.map((item) => item.toMap()).toList(),
      'total_harga': totalHarga,
      'status': status,
      'keterangan': keterangan,
      'user_id': userId,
      'nama_user': namaUser,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}
