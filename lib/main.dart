import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/hotel_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/customer/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/verify_email_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HotelManagerApp(),
    ),
  );
}

class HotelManagerApp extends StatelessWidget {
  const HotelManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // If not logged in, show HomeScreen as guest
          if (!auth.isLoggedIn) return const HomeScreen();
          
          // Email verification check for password providers
          final isEmailProvider = auth.user?.providerData.any((p) => p.providerId == 'password') ?? false;
          if (isEmailProvider && !auth.isEmailVerified) return const VerifyEmailScreen();
          
          // Role-based routing: Admin goes to Dashboard, everyone else (including loading role) to Home
          // This avoids the "stuck" feeling of a full-screen spinner
          if (auth.role == 'admin') return const AdminDashboard();
          
          return const HomeScreen();
        },
      ),
    );
  }
}
