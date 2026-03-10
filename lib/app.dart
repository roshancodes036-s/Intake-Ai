import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/splash/presentation/splash_screen.dart';

// 1. यह ग्लोबल वेरिएबल (Controller) है जो पूरे ऐप का थीम कंट्रोल करेगा
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class IntakeApp extends StatelessWidget {
  const IntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. ValueListenableBuilder ऐप को तुरंत अपडेट करेगा जब थीम बदलेगी
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Intake App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // यहाँ असली थीम सेट हो रही है
          
          // === LIGHT THEME ===
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.lightBackground,
            cardColor: AppColors.lightCard,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
              bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
            ),
            iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
          ),
          
          // === DARK THEME ===
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            cardColor: AppColors.darkCard,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
              bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
            ),
            iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
          ),
          
          home: const SplashScreen(), 
        );
      },
    );
  }
}