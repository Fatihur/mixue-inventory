import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/barang_model.dart';
import '../models/barang_masuk_model.dart';
import '../models/barang_terpakai_model.dart';
import '../models/barang_expired_model.dart';
import '../models/order_model.dart';
import '../models/refund_model.dart';
import '../models/kategori_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('dibuat_pada', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['diubah_pada'] = Timestamp.now();
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // Barang
  Stream<List<BarangModel>> getBarang() {
    return _firestore
        .collection('barang')
        .orderBy('nama')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BarangModel.fromFirestore(doc))
            .toList());
  }

  Future<BarangModel?> getBarangByBarcode(String barcode) async {
    QuerySnapshot snapshot = await _firestore
        .collection('barang')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return BarangModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  Future<String> addBarang(BarangModel barang) async {
    DocumentReference docRef = await _firestore.collection('barang').add(barang.toMap());
    return docRef.id;
  }

  Future<void> updateBarang(String id, Map<String, dynamic> data) async {
    data['diubah_pada'] = Timestamp.now();
    await _firestore.collection('barang').doc(id).update(data);
  }

  Future<void> deleteBarang(String id) async {
    await _firestore.collection('barang').doc(id).delete();
  }

  Future<void> updateStok(String barangId, int jumlah) async {
    await _firestore.collection('barang').doc(barangId).update({
      'stok': FieldValue.increment(jumlah),
      'diubah_pada': Timestamp.now(),
    });
  }

  // Barang Masuk
  Stream<List<BarangMasukModel>> getBarangMasuk({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('barang_masuk').orderBy('tanggal', descending: true);
    
    if (startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BarangMasukModel.fromFirestore(doc))
        .toList());
  }

  Future<void> addBarangMasuk(BarangMasukModel data) async {
    // Get pcsPerBox from barang
    final barangDoc = await _firestore.collection('barang').doc(data.barangId).get();
    final pcsPerBox = barangDoc.data()?['pcs_per_box'] as int? ?? 1;
    final totalPcs = data.jumlah * pcsPerBox;
    
    await _firestore.collection('barang_masuk').add(data.toMap());
    await updateStok(data.barangId, totalPcs);
  }

  // Barang Terpakai
  Stream<List<BarangTerpakaiModel>> getBarangTerpakai({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('barang_terpakai').orderBy('tanggal', descending: true);
    
    if (startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BarangTerpakaiModel.fromFirestore(doc))
        .toList());
  }

  Future<void> addBarangTerpakai(BarangTerpakaiModel data) async {
    // Jumlah sudah dalam satuan pcs
    await _firestore.collection('barang_terpakai').add(data.toMap());
    await updateStok(data.barangId, -data.jumlah);
  }

  // Barang Expired
  Stream<List<BarangExpiredModel>> getBarangExpired({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('expired').orderBy('tanggal_input', descending: true);
    
    if (startDate != null) {
      query = query.where('tanggal_input', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('tanggal_input', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => BarangExpiredModel.fromFirestore(doc))
        .toList());
  }

  Future<void> addBarangExpired(BarangExpiredModel data) async {
    // Get pcsPerBox from barang
    final barangDoc = await _firestore.collection('barang').doc(data.barangId).get();
    final pcsPerBox = barangDoc.data()?['pcs_per_box'] as int? ?? 1;
    final totalPcs = data.jumlah * pcsPerBox;
    
    await _firestore.collection('expired').add(data.toMap());
    await updateStok(data.barangId, -totalPcs);
  }

  // Order
  Stream<List<OrderModel>> getOrders({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('order').orderBy('tanggal', descending: true);
    
    if (startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList());
  }

  Future<String> addOrder(OrderModel order) async {
    DocumentReference docRef = await _firestore.collection('order').add(order.toMap());
    for (var item in order.items) {
      await updateStok(item.barangId, -item.jumlah);
    }
    return docRef.id;
  }

  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _firestore.collection('order').doc(id).update(data);
  }

  Future<void> deleteOrder(String id) async {
    await _firestore.collection('order').doc(id).delete();
  }

  // Refund
  Stream<List<RefundModel>> getRefunds({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('refund').orderBy('tanggal', descending: true);
    
    if (startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => RefundModel.fromFirestore(doc))
        .toList());
  }

  Future<String> addRefund(RefundModel refund) async {
    DocumentReference docRef = await _firestore.collection('refund').add(refund.toMap());
    return docRef.id;
  }

  Future<void> updateRefund(String id, Map<String, dynamic> data) async {
    await _firestore.collection('refund').doc(id).update(data);
  }

  Future<void> deleteRefund(String id) async {
    await _firestore.collection('refund').doc(id).delete();
  }

  // Generate Order Number
  Future<String> generateOrderNumber() async {
    String today = DateTime.now().toString().substring(0, 10).replaceAll('-', '');
    QuerySnapshot snapshot = await _firestore
        .collection('order')
        .where('nomor_order', isGreaterThanOrEqualTo: 'ORD-$today')
        .where('nomor_order', isLessThan: 'ORD-${today}z')
        .get();
    
    int count = snapshot.docs.length + 1;
    return 'ORD-$today-${count.toString().padLeft(4, '0')}';
  }

  // Kategori
  Stream<List<KategoriModel>> getKategori() {
    return _firestore
        .collection('kategori')
        .orderBy('nama')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KategoriModel.fromFirestore(doc))
            .toList());
  }

  Future<List<String>> getKategoriNames() async {
    QuerySnapshot snapshot = await _firestore
        .collection('kategori')
        .orderBy('nama')
        .get();
    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['nama'] as String)
        .toList();
  }

  Future<String> addKategori(KategoriModel kategori) async {
    DocumentReference docRef = await _firestore.collection('kategori').add(kategori.toMap());
    return docRef.id;
  }

  Future<void> updateKategori(String id, Map<String, dynamic> data) async {
    data['diubah_pada'] = Timestamp.now();
    await _firestore.collection('kategori').doc(id).update(data);
  }

  Future<void> deleteKategori(String id) async {
    await _firestore.collection('kategori').doc(id).delete();
  }
}
