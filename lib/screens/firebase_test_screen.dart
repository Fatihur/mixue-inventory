import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../main.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _authStatus = 'Checking...';
  String _firestoreStatus = 'Checking...';
  String _testResult = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() => _isTesting = true);

    // Test Auth
    try {
      final auth = FirebaseAuth.instance;
      _authStatus = 'Auth: Connected\nCurrent User: ${auth.currentUser?.email ?? "None"}';
    } catch (e) {
      _authStatus = 'Auth Error: $e';
    }

    // Test Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to read from Firestore
      await firestore.collection('_test_connection').limit(1).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      _firestoreStatus = 'Firestore: Connected';
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('PERMISSION_DENIED')) {
        _firestoreStatus = 'Firestore: Connected (but needs rules setup)';
      } else if (errorMsg.contains('timeout')) {
        _firestoreStatus = 'Firestore: Connection Timeout\n(Check internet connection)';
      } else {
        _firestoreStatus = 'Firestore Error: $errorMsg';
      }
    }

    setState(() => _isTesting = false);
  }

  Future<void> _testLogin() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing login...';
    });

    try {
      // Try to sign in with test credentials
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'test123',
      );
      _testResult = 'Login successful!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _testResult = 'Auth Working! (User not found - expected)';
      } else if (e.code == 'wrong-password') {
        _testResult = 'Auth Working! (Wrong password - expected)';
      } else if (e.code == 'invalid-credential') {
        _testResult = 'Auth Working! (Invalid credential - expected)';
      } else {
        _testResult = 'Auth Error: ${e.code} - ${e.message}';
      }
    } catch (e) {
      _testResult = 'Error: $e';
    }

    setState(() => _isTesting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(
              'Firebase Core',
              firebaseStatus,
              firebaseConnected ? Colors.green : Colors.red,
              firebaseConnected ? Icons.check_circle : Icons.error,
            ),
            const SizedBox(height: 12),
            _buildStatusCard(
              'Firebase Auth',
              _authStatus,
              _authStatus.contains('Connected') ? Colors.green : Colors.orange,
              _authStatus.contains('Connected') ? Icons.check_circle : Icons.warning,
            ),
            const SizedBox(height: 12),
            _buildStatusCard(
              'Cloud Firestore',
              _firestoreStatus,
              _firestoreStatus.contains('Connected') ? Colors.green : Colors.orange,
              _firestoreStatus.contains('Connected') ? Icons.check_circle : Icons.warning,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _runTests,
                icon: _isTesting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isTesting ? 'Testing...' : 'Refresh Tests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testLogin,
                icon: const Icon(Icons.login),
                label: const Text('Test Auth Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            if (_testResult.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _testResult.contains('Working') || _testResult.contains('successful')
                      ? Colors.green.withAlpha(25)
                      : Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _testResult.contains('Working') || _testResult.contains('successful')
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Text(
                  _testResult,
                  style: TextStyle(
                    color: _testResult.contains('Working') || _testResult.contains('successful')
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Checklist Firebase Setup:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildChecklist('SHA-1 fingerprint added to Firebase Console'),
            _buildChecklist('Email/Password Auth enabled'),
            _buildChecklist('Firestore Database created'),
            _buildChecklist('Firestore Rules published'),
            _buildChecklist('Internet connection active'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600]))),
        ],
      ),
    );
  }
}
