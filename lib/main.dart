import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hotel_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HotelProvider()),
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
      home: const HomeScreen(),
    );
  }
}
