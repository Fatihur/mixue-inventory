import 'package:cloud_firestore/cloud_firestore.dart';

class BarangExpiredModel {
  final String id;
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final String keterangan;
  final String userId;
  final String namaUser;
  final DateTime tanggalExpired;
  final DateTime tanggalInput;

  BarangExpiredModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.keterangan,
    required this.userId,
    required this.namaUser,
    required this.tanggalExpired,
    required this.tanggalInput,
  });

  factory BarangExpiredModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BarangExpiredModel(
      id: doc.id,
      barangId: data['barang_id'] ?? '',
      namaBarang: data['nama_barang'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      keterangan: data['keterangan'] ?? '',
      userId: data['user_id'] ?? '',
      namaUser: data['nama_user'] ?? '',
      tanggalExpired: (data['tanggal_expired'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tanggalInput: (data['tanggal_input'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barang_id': barangId,
      'nama_barang': namaBarang,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'user_id': userId,
      'nama_user': namaUser,
      'tanggal_expired': Timestamp.fromDate(tanggalExpired),
      'tanggal_input': Timestamp.fromDate(tanggalInput),
    };
  }
}
