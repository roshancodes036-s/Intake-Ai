import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';

class EditMealScreen extends StatelessWidget {
  const EditMealScreen({super.key});

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context), // वापस जाने के लिए
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Edit Breakfast',
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle (Calories)
            Text(
              '372 CALORIES',
              style: TextStyle(
                color: textLight,
                fontSize: 14,
                letterSpacing: 1.2, // थोड़ा स्पेस देने के लिए
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // View Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
              ],
            ),
            const SizedBox(height: 24),

            // List of Ingredients
            _buildIngredientTile('Oatmeal', cardColor, textColor),
            const SizedBox(height: 12),
            _buildIngredientTile('Greek Yogurt', cardColor, textColor),
            const SizedBox(height: 12),
            _buildIngredientTile('Banana', cardColor, textColor),
            
            const SizedBox(height: 24),

            // Add Item TextButton
            GestureDetector(
              onTap: () {
                // यहाँ नया आइटम जोड़ने का लॉजिक आएगा
              },
              child: Text(
                'Add item',
                style: TextStyle(
                  color: textLight,
                  fontSize: 16,
                ),
              ),
            ),
            
            const Spacer(), // यह सेव बटन को सबसे नीचे धकेल देगा
            
            // Save Button (Custom Button with dynamic color)
            CustomButton(
              text: 'Save',
              color: isDark ? const Color(0xFF152232) : Colors.grey.shade200, // डार्क/लाइट के हिसाब से
              textColor: textColor,
              onPressed: () {
                // यहाँ सेव करने का लॉजिक आएगा
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30), // Bottom spacing
          ],
        ),
      ),
    );
  }

  // इनग्रेडिएंट्स के लिए कस्टम टाइल विजेट (डायनामिक कलर्स के साथ)
  Widget _buildIngredientTile(String itemName, Color cardColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 5, offset: const Offset(0, 2))
        ]
      ),
      child: Text(
        itemName,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}