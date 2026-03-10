import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../scanner/presentation/camera_scan_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // === नए डायनामिक थीम कलर्स (Dark/Light मोड के लिए) ===
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
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'Intake',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: AppColors.primaryGreen, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScanScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakfast',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              '8:30 AM',
              style: TextStyle(color: textLight, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // Macros Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroText('372', 'Carbs', textColor, textLight),
                _buildMacroText('30g', 'Fat', textColor, textLight),
                _buildMacroText('14g', 'Protein', textColor, textLight),
              ],
            ),
            const SizedBox(height: 30),

            // Food Card
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                children: [
                  // Food Image Placeholder
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: Center(
                        child: Text('Oatmeal Image Here', style: TextStyle(color: textLight)),
                      ),
                    ),
                  ),
                  // Ingredients List
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                         _buildIngredientRow('Oatmeal', '37 g', textColor, textLight),
                         const SizedBox(height: 12),
                         _buildIngredientRow('Greek Yogurt', '14 g', textColor, textLight),
                         const SizedBox(height: 12),
                         _buildIngredientRow('Banana', '37 g', textColor, textLight),
                         const SizedBox(height: 12),
                         _buildIngredientRow('Blueberries', '12 g', textColor, textLight),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryGreen,
          elevation: 8,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScanScreen()),
            );
          },
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bgColor,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: textLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  // Macros dikhane ke liye custom widget (updated with theme colors)
  Widget _buildMacroText(String value, String label, Color textColor, Color textLight) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: textLight, fontSize: 14),
        ),
      ],
    );
  }

  // Ingredients list ke liye custom widget (updated with theme colors)
  Widget _buildIngredientRow(String name, String weight, Color textColor, Color textLight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        Text(weight, style: TextStyle(color: textLight, fontSize: 14)),
      ],
    );
  }
}