import 'package:cloud_firestore/cloud_firestore.dart';

class BarangTerpakaiModel {
  final String id;
  final String barangId;
  final String namaBarang;
  final int jumlah;
  final String keterangan;
  final String userId;
  final String namaUser;
  final DateTime tanggal;

  BarangTerpakaiModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.jumlah,
    required this.keterangan,
    required this.userId,
    required this.namaUser,
    required this.tanggal,
  });

  factory BarangTerpakaiModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BarangTerpakaiModel(
      id: doc.id,
      barangId: data['barang_id'] ?? '',
      namaBarang: data['nama_barang'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      keterangan: data['keterangan'] ?? '',
      userId: data['user_id'] ?? '',
      namaUser: data['nama_user'] ?? '',
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}
