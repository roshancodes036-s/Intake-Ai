import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // 🔥 एनिमेशन पैकेज
import '../../../core/constants/colors.dart';
import '../../scanner/presentation/camera_scan_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import 'home_dashboard.dart';
import '../../../app.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isCameraPressed = false; // 🔥 कैमरा बटन के बाउंस के लिए

  final List<Widget> _screens = [
    const HomeDashboard(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: Stack(
        children: [
          // 1. Screens (आपका मेन पेज)
          _screens[_currentIndex],

          // 🔥 2. Floating Bottom Bar (FadeInUp Animation) 🔥
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800), // स्मूथ एंट्री
              child: Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(0, Icons.home_filled, 'Home', isDark),
                          _buildNavItem(
                            1,
                            Icons.bar_chart_rounded,
                            'Progress',
                            isDark,
                          ),
                          _buildNavItem(2, Icons.settings, 'Settings', isDark),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      // 🔥 3. Tactile Camera Button (Bounce Effect) 🔥
                      child: GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _isCameraPressed = true),
                        onTapUp: (_) {
                          setState(() => _isCameraPressed = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScanScreen(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        onTapCancel: () =>
                            setState(() => _isCameraPressed = false),
                        child: AnimatedScale(
                          scale: _isCameraPressed
                              ? 0.85
                              : 1.0, // दबाने पर सिकुड़ेगा
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _currentIndex == index;
    Color activeColor = isDark ? Colors.white : Colors.black;
    Color inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      // 🔥 4. Tab Bounce Animation (जब सेलेक्ट होगा तो बड़ा होगा) 🔥
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0, // सेलेक्ट होने पर हल्का बड़ा होगा
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack, // स्प्रिंग जैसा इफ़ेक्ट
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
