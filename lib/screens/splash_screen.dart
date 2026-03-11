import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/lobby.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withAlpha(100),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hotel_class_rounded,
                  size: 80,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 20),
                const Text(
                  'G-Hotel',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sự Sang Trọng Trong Từng Khoảnh Khắc',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(200),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
