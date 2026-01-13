import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final String status;
  final DateTime dibuatPada;
  final DateTime diubahPada;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.status,
    required this.dibuatPada,
    required this.diubahPada,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'karyawan',
      status: data['status'] ?? 'aktif',
      dibuatPada: (data['dibuat_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diubahPada: (data['diubah_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
      'status': status,
      'dibuat_pada': Timestamp.fromDate(dibuatPada),
      'diubah_pada': Timestamp.fromDate(diubahPada),
    };
  }

  UserModel copyWith({
    String? uid,
    String? nama,
    String? email,
    String? role,
    String? status,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diubahPada: diubahPada ?? this.diubahPada,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'aktif';
}
