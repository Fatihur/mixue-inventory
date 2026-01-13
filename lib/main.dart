import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard_admin.dart';
import 'screens/karyawan/dashboard_karyawan.dart';
import 'utils/constants.dart';
import 'widgets/loading_widget.dart';

// Global variable to track Firebase status
String firebaseStatus = 'Checking...';
bool firebaseConnected = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseStatus = 'Firebase Core: OK\n';
    firebaseStatus += 'Project: ${DefaultFirebaseOptions.currentPlatform.projectId}\n';
    firebaseConnected = true;
    debugPrint('=== FIREBASE STATUS ===');
    debugPrint('Firebase initialized successfully');
    debugPrint('Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    debugPrint('=======================');
  } catch (e) {
    firebaseStatus = 'Firebase Error: $e';
    firebaseConnected = false;
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..init()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while initializing
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: LoadingWidget(message: 'Memuat...'),
          );
        }

        // Check if logged in
        if (authProvider.isLoggedIn && authProvider.user != null) {
          if (authProvider.isAdmin) {
            return const DashboardAdmin();
          } else {
            return const DashboardKaryawan();
          }
        }

        // Show login screen
        return const LoginScreen();
      },
    );
  }
}
