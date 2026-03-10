import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';

class AddMealScreen extends StatefulWidget {
  final String mealType; // जैसे: Breakfast, Lunch, Dinner

  const AddMealScreen({super.key, this.mealType = 'Breakfast'});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === नए डायनामिक थीम कलर्स ===
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add ${widget.mealType}',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Details',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Food Name Input
            _buildInputField(label: 'Food Name', controller: _nameController, hint: 'e.g., Avocado Toast', textColor: textColor, textLight: textLight, cardColor: cardColor),
            const SizedBox(height: 16),

            // Calories Input
            _buildInputField(label: 'Calories (kcal)', controller: _caloriesController, hint: 'e.g., 340', isNumber: true, textColor: textColor, textLight: textLight, cardColor: cardColor),
            const SizedBox(height: 32),

            Text(
              'Macros (Optional)',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Macros Inputs (Row में)
            Row(
              children: [
                Expanded(child: _buildInputField(label: 'Protein (g)', controller: _proteinController, hint: '0', isNumber: true, textColor: textColor, textLight: textLight, cardColor: cardColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField(label: 'Fat (g)', controller: _fatController, hint: '0', isNumber: true, textColor: textColor, textLight: textLight, cardColor: cardColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField(label: 'Carbs (g)', controller: _carbsController, hint: '0', isNumber: true, textColor: textColor, textLight: textLight, cardColor: cardColor)),
              ],
            ),
            
            const SizedBox(height: 40),

            // Save Button
            CustomButton(
              text: 'SAVE MEAL',
              onPressed: () {
                // यहाँ डेटाबेस में मील सेव करने का लॉजिक आएगा
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Meal saved manually!'), backgroundColor: AppColors.primaryGreen),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // इनपुट फील्ड्स बनाने के लिए कस्टम विजेट (डायनामिक कलर्स के साथ)
  Widget _buildInputField({
    required String label, 
    required TextEditingController controller, 
    required String hint, 
    bool isNumber = false,
    required Color textColor,
    required Color textLight,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textLight, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textLight.withOpacity(0.5)),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}