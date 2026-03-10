import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/colors.dart';

class CalorieProgressRing extends StatelessWidget {
  final int currentCalories;
  final int goalCalories;

  const CalorieProgressRing({
    super.key,
    required this.currentCalories,
    required this.goalCalories,
  });

  @override
  Widget build(BuildContext context) {
    // === नए डायनामिक थीम कलर्स ===
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // प्रोग्रेस का प्रतिशत निकालें (0.0 से 1.0 के बीच)
    double progress = currentCalories / goalCalories;
    if (progress > 1.0) progress = 1.0;

    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          progressColor: AppColors.primaryGreen,
          backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200, // डार्क/लाइट के हिसाब से बैकग्राउंड रिंग का रंग
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Calorie goal',
                style: TextStyle(color: textLight, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                currentCalories.toString(),
                style: TextStyle(
                  color: textColor, // थीम के हिसाब से डार्क या लाइट
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'of $goalCalories goal',
                style: TextStyle(color: textLight, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// कस्टम पेंटर क्लास (रिंग को ड्रॉ करने के लिए)
class _RingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // बैकग्राउंड रिंग 
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // प्रोग्रेस रिंग (हरा कलर)
    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2) - 10;

    // एंगल सेट करना (ताकि रिंग नीचे से खुली रहे)
    // 135 डिग्री से शुरू होकर 270 डिग्री तक घूमेगी
    double startAngle = math.pi * 0.75; 
    double sweepAngle = math.pi * 1.5;

    // बैकग्राउंड आर्क ड्रॉ करें
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // प्रोग्रेस आर्क ड्रॉ करें
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}