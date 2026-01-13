import 'package:cloud_firestore/cloud_firestore.dart';

class KategoriModel {
  final String id;
  final String nama;
  final String deskripsi;
  final DateTime dibuatPada;
  final DateTime diubahPada;

  KategoriModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.dibuatPada,
    required this.diubahPada,
  });

  factory KategoriModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KategoriModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      dibuatPada: (data['dibuat_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diubahPada: (data['diubah_pada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'dibuat_pada': Timestamp.fromDate(dibuatPada),
      'diubah_pada': Timestamp.fromDate(diubahPada),
    };
  }

  KategoriModel copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diubahPada: diubahPada ?? this.diubahPada,
    );
  }
}
