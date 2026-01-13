import 'package:cloud_firestore/cloud_firestore.dart';

class RefundModel {
  final String id;
  final String orderId;
  final String nomorOrder;
  final String alasan;
  final double jumlahRefund;
  final String status;
  final String userId;
  final String namaUser;
  final DateTime tanggal;

  RefundModel({
    required this.id,
    required this.orderId,
    required this.nomorOrder,
    required this.alasan,
    required this.jumlahRefund,
    required this.status,
    required this.userId,
    required this.namaUser,
    required this.tanggal,
  });

  factory RefundModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RefundModel(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      nomorOrder: data['nomor_order'] ?? '',
      alasan: data['alasan'] ?? '',
      jumlahRefund: (data['jumlah_refund'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      userId: data['user_id'] ?? '',
      namaUser: data['nama_user'] ?? '',
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'nomor_order': nomorOrder,
      'alasan': alasan,
      'jumlah_refund': jumlahRefund,
      'status': status,
      'user_id': userId,
      'nama_user': namaUser,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}
