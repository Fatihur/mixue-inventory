import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        
        if (userDoc.exists) {
          UserModel user = UserModel.fromFirestore(userDoc);
          if (user.status == 'nonaktif') {
            await _auth.signOut();
            throw CustomAuthException(
              code: 'user-disabled',
              message: 'Akun Anda telah dinonaktifkan. Hubungi admin.',
            );
          }
          return user;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          nama: nama,
          email: email,
          role: role,
          status: 'aktif',
          dibuatPada: DateTime.now(),
          diubahPada: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> createUserByAdmin({
    required String email,
    required String password,
    required String nama,
    required String role,
  }) async {
    try {
      String? currentUserEmail = _auth.currentUser?.email;
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          nama: nama,
          email: email,
          role: role,
          status: 'aktif',
          dibuatPada: DateTime.now(),
          diubahPada: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        await _auth.signOut();

        if (currentUserEmail != null) {
          // Note: Admin needs to re-login after creating user
          // In production, use Cloud Functions for this
        }

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
    }
    return null;
  }
}

class CustomAuthException implements Exception {
  final String code;
  final String message;

  CustomAuthException({required this.code, required this.message});

  @override
  String toString() => message;
}
