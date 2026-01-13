import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/barang_model.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _barangMasukSubscription;
  StreamSubscription? _barangExpiredSubscription;
  StreamSubscription? _stokRendahSubscription;
  
  final Set<String> _notifiedStokRendahIds = {};
  
  DateTime? _lastBarangMasukTime;
  DateTime? _lastExpiredTime;
  bool _isFirstLoadStok = true;

  void init() {
    debugPrint('NotificationProvider: init called');
    _listenToNotifications();
    _initBarangMasukListener();
    _initExpiredListener();
    _listenToStokRendah();
  }

  void _listenToNotifications() {
    _notificationSubscription = _firestore
        .collection('notifications')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        _notifications = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
        debugPrint('NotificationProvider: loaded ${_notifications.length} notifications');
        notifyListeners();
      },
      onError: (e) => debugPrint('NotificationProvider: error listening notifications: $e'),
    );
  }

  void _initBarangMasukListener() async {
    // Get the latest timestamp to only listen for new data
    final latest = await _firestore
        .collection('barang_masuk')
        .orderBy('tanggal', descending: true)
        .limit(1)
        .get();
    
    if (latest.docs.isNotEmpty) {
      _lastBarangMasukTime = (latest.docs.first.data()['tanggal'] as Timestamp).toDate();
    } else {
      _lastBarangMasukTime = DateTime.now();
    }
    
    debugPrint('NotificationProvider: barang masuk listening from $_lastBarangMasukTime');
    
    // Now listen for new documents
    _barangMasukSubscription = _firestore
        .collection('barang_masuk')
        .orderBy('tanggal', descending: true)
        .limit(5)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final tanggal = (data['tanggal'] as Timestamp).toDate();
          
          // Only process if newer than our last known time
          if (_lastBarangMasukTime != null && tanggal.isAfter(_lastBarangMasukTime!)) {
            _lastBarangMasukTime = tanggal;
            
            final barangId = data['barang_id'] as String?;
            final jumlahBox = data['jumlah'] as int? ?? 0;
            
            String message = '${data['nama_barang']} +$jumlahBox box';
            
            if (barangId != null) {
              try {
                final barangDoc = await _firestore.collection('barang').doc(barangId).get();
                if (barangDoc.exists) {
                  final pcsPerBox = barangDoc.data()?['pcs_per_box'] as int? ?? 1;
                  final totalPcs = jumlahBox * pcsPerBox;
                  message = '${data['nama_barang']} +$jumlahBox box ($totalPcs pcs)';
                }
              } catch (e) {
                debugPrint('NotificationProvider: error fetching barang: $e');
              }
            }
            
            message += ' oleh ${data['nama_user']}';
            debugPrint('NotificationProvider: NEW barang masuk detected: $message');
            
            await _createNotification(
              title: 'Barang Masuk',
              message: message,
              type: NotificationType.barangMasuk,
              referenceId: doc.id,
            );
          }
        }
      },
      onError: (e) => debugPrint('NotificationProvider: error listening barang masuk: $e'),
    );
  }

  void _initExpiredListener() async {
    // Get the latest timestamp
    final latest = await _firestore
        .collection('expired')
        .orderBy('tanggal_input', descending: true)
        .limit(1)
        .get();
    
    if (latest.docs.isNotEmpty) {
      _lastExpiredTime = (latest.docs.first.data()['tanggal_input'] as Timestamp).toDate();
    } else {
      _lastExpiredTime = DateTime.now();
    }
    
    debugPrint('NotificationProvider: expired listening from $_lastExpiredTime');
    
    _barangExpiredSubscription = _firestore
        .collection('expired')
        .orderBy('tanggal_input', descending: true)
        .limit(5)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final tanggal = (data['tanggal_input'] as Timestamp).toDate();
          
          if (_lastExpiredTime != null && tanggal.isAfter(_lastExpiredTime!)) {
            _lastExpiredTime = tanggal;
            
            final barangId = data['barang_id'] as String?;
            final jumlahBox = data['jumlah'] as int? ?? 0;
            
            String message = '${data['nama_barang']} -$jumlahBox box (expired)';
            
            if (barangId != null) {
              try {
                final barangDoc = await _firestore.collection('barang').doc(barangId).get();
                if (barangDoc.exists) {
                  final pcsPerBox = barangDoc.data()?['pcs_per_box'] as int? ?? 1;
                  final totalPcs = jumlahBox * pcsPerBox;
                  message = '${data['nama_barang']} -$jumlahBox box ($totalPcs pcs) expired';
                }
              } catch (e) {
                debugPrint('NotificationProvider: error fetching barang: $e');
              }
            }
            
            debugPrint('NotificationProvider: NEW expired detected: $message');
            
            await _createNotification(
              title: 'Barang Expired',
              message: message,
              type: NotificationType.barangExpired,
              referenceId: doc.id,
            );
          }
        }
      },
      onError: (e) => debugPrint('NotificationProvider: error listening expired: $e'),
    );
  }

  void _listenToStokRendah() {
    _stokRendahSubscription = _firestore
        .collection('barang')
        .snapshots()
        .listen(
      (snapshot) {
        // Skip first load - only track existing low stock items
        if (_isFirstLoadStok) {
          _isFirstLoadStok = false;
          for (var doc in snapshot.docs) {
            final barang = BarangModel.fromFirestore(doc);
            if (barang.isStokRendah) {
              _notifiedStokRendahIds.add(barang.id);
            }
          }
          debugPrint('NotificationProvider: initialized with ${_notifiedStokRendahIds.length} low stock items');
          return;
        }
        
        for (var doc in snapshot.docs) {
          final barang = BarangModel.fromFirestore(doc);
          if (barang.isStokRendah && !_notifiedStokRendahIds.contains(barang.id)) {
            _notifiedStokRendahIds.add(barang.id);
            debugPrint('NotificationProvider: NEW low stock: ${barang.nama}');
            _createNotification(
              title: 'Stok Menipis',
              message: '${barang.nama} tersisa ${barang.stokFormatted} (min: ${barang.stokMinimal} box)',
              type: NotificationType.stokRendah,
              referenceId: barang.id,
            );
          } else if (!barang.isStokRendah && _notifiedStokRendahIds.contains(barang.id)) {
            _notifiedStokRendahIds.remove(barang.id);
          }
        }
      },
      onError: (e) => debugPrint('NotificationProvider: error listening stok: $e'),
    );
  }

  Future<void> _createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? referenceId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'type': type.name,
        'reference_id': referenceId,
        'is_read': false,
        'created_at': Timestamp.now(),
      });
      debugPrint('NotificationProvider: notification CREATED - $title: $message');
    } catch (e) {
      debugPrint('NotificationProvider: ERROR creating notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final unreadDocs = await _firestore
        .collection('notifications')
        .where('is_read', isEqualTo: false)
        .get();
    
    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> clearAllNotifications() async {
    final batch = _firestore.batch();
    final allDocs = await _firestore.collection('notifications').get();
    
    for (var doc in allDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _barangMasukSubscription?.cancel();
    _barangExpiredSubscription?.cancel();
    _stokRendahSubscription?.cancel();
    super.dispose();
  }
}
