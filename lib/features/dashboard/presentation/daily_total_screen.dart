import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';

class DailyTotalScreen extends StatelessWidget {
  const DailyTotalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // === नए डायनामिक थीम कलर्स ===
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'Intake',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Subtitle
            Text(
              'Daily Total',
              style: TextStyle(
                color: textLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            // Total Calories
            Text(
              '1340',
              style: TextStyle(
                color: textColor,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Macros Row (Protein, Fat, Carbs)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroItem('105g', 'Protein', textColor, textLight),
                _buildMacroItem('54g', 'Fat', textColor, textLight),
                _buildMacroItem('135g', 'Carbs', textColor, textLight),
              ],
            ),
            const SizedBox(height: 40),

            // Horizontal Progress Bars
            _buildProgressBar(0.8, cardColor), // 80% भरा हुआ (Protein के लिए)
            const SizedBox(height: 24),
            _buildProgressBar(0.3, cardColor), // 30% भरा हुआ (Fat के लिए)
            const SizedBox(height: 24),
            _buildProgressBar(0.9, cardColor), // 90% भरा हुआ (Carbs के लिए)

            const Spacer(),

            // View Summary Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'VIEW SUMMARY',
                style: TextStyle(
                  color: textLight,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Button
            CustomButton(
              text: 'VIEW SUMMARY',
              color: isDark ? const Color(0xFF152232) : Colors.grey.shade200, // थीम के हिसाब से बटन का रंग
              textColor: textColor,
              onPressed: () {
                // यहाँ समरी पेज पर जाने का लॉजिक आएगा
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // मैक्रोज़ के टेक्स्ट के लिए कस्टम विजेट (डायनामिक कलर्स के साथ)
  Widget _buildMacroItem(String weight, String label, Color textColor, Color textLight) {
    return Column(
      children: [
        Text(
          weight,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: textLight,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // हॉरिजॉन्टल प्रोग्रेस बार बनाने का लॉजिक (डायनामिक कलर्स के साथ)
  Widget _buildProgressBar(double percentage, Color cardColor) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor, // बैकग्राउंड डार्क या लाइट ग्रे
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage, // यह तय करेगा कि हरा हिस्सा कितना लंबा होगा
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}