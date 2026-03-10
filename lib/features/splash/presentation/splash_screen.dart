import 'dart:async';
import 'package:flutter/material.dart';
import '../../dashboard/presentation/main_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // आपका शानदार ज़ूम और फेड एनीमेशन
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      // पेज बदलते वक्त भी स्मूथ फेड इफ़ेक्ट
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 आपके स्क्रीनशॉट के एग्ज़ैक्ट कलर्स (Navy Blue & Cream) 🔥
    const Color customBgColor = Color(0xFF091219); 
    const Color customCreamColor = Color(0xFFF7F1E4);

    return Scaffold(
      backgroundColor: customBgColor, // डार्क नेवी ब्लू बैकग्राउंड
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 आपकी असली कस्टम लोगो इमेज 🔥
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  color: customCreamColor, // इमेज को क्रीम कलर देगा
                  errorBuilder: (context, error, stackTrace) {
                    // सेफगार्ड: अगर इमेज लोड न हो तो डिफ़ॉल्ट आइकॉन क्रीम कलर में दिखाएगा
                    return const Icon(Icons.apple, size: 100, color: customCreamColor);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Intake',
                  style: TextStyle(
                    fontSize: 48, 
                    fontWeight: FontWeight.w500, 
                    color: customCreamColor, // क्रीम कलर का टेक्स्ट
                    letterSpacing: -1.0
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}