import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/hotel_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/customer/home_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/update_info_screen.dart';
import 'screens/splash_screen.dart';
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

class HotelManagerApp extends StatefulWidget {
  const HotelManagerApp({super.key});

  @override
  State<HotelManagerApp> createState() => _HotelManagerAppState();
}

class _HotelManagerAppState extends State<HotelManagerApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Ensure splash screen is shown for at least 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Show splash screen while initializing, loading role, or during the forced minimum delay
          if (_showSplash || auth.isAuthLoading) return const SplashScreen();

          // If not logged in, show HomeScreen as guest
          if (!auth.isLoggedIn) return const HomeScreen();
          
          // Email verification check for password providers
          final isEmailProvider = auth.user?.providerData.any((p) => p.providerId == 'password') ?? false;
          if (isEmailProvider && !auth.isEmailVerified) return const VerifyEmailScreen();
          
          // Check for mandatory profile info (Customers only)
          if (auth.role == 'customer' && !auth.isProfileComplete) return const UpdateInfoScreen();
          
          // All users land on HomeScreen. Admin can access dashboard via button there.
          return const HomeScreen();
        },
      ),
    );
  }
}
