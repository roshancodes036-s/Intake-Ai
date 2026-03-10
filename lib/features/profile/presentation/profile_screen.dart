import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // 🔥 एनिमेशन पैकेज
import '../../../core/constants/colors.dart';
import '../../../core/constants/globals.dart'; 
import '../../../app.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // डेटाबेस से वैल्यू लाना
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      globalCalorieGoal.value = prefs.getInt('calorieGoal') ?? 2500;
      globalProteinGoal.value = prefs.getInt('proteinGoal') ?? 150;
      globalCarbsGoal.value = prefs.getInt('carbsGoal') ?? 275;
      globalFatGoal.value = prefs.getInt('fatGoal') ?? 70;
    });
  }

  // 1. Theme BottomSheet 
  void _showThemeBottomSheet(Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Text('Select Theme', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _themeOption('System Default', ThemeMode.system, Icons.brightness_auto, textColor),
              _themeOption('Light Mode', ThemeMode.light, Icons.light_mode, textColor),
              _themeOption('Dark Mode', ThemeMode.dark, Icons.dark_mode, textColor),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _themeOption(String title, ThemeMode mode, IconData icon, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
      onTap: () async {
        themeNotifier.value = mode;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('themeMode', mode.toString());
        if (mounted) Navigator.pop(context);
      },
    );
  }

  // 2. Calorie BottomSheet 
  void _showEditGoalBottomSheet(Color textColor, Color textLight, Color bgColor) {
    final TextEditingController controller = TextEditingController(text: globalCalorieGoal.value.toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                  const SizedBox(width: 10),
                  Text('Daily Calorie Goal', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: textColor),
                decoration: InputDecoration(
                  suffixText: 'kcal',
                  suffixStyle: TextStyle(fontSize: 20, color: textLight),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () async {
                    int? newGoal = int.tryParse(controller.text);
                    if (newGoal != null && newGoal > 0) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('calorieGoal', newGoal);
                      globalCalorieGoal.value = newGoal; 
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE GOAL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  // 3. Macros BottomSheet
  void _showMacrosBottomSheet(Color textColor, Color textLight, Color bgColor) {
    final proteinCtrl = TextEditingController(text: globalProteinGoal.value.toString());
    final carbsCtrl = TextEditingController(text: globalCarbsGoal.value.toString());
    final fatCtrl = TextEditingController(text: globalFatGoal.value.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Text('Macronutrients Goal', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _macroField('Protein (g)', proteinCtrl, AppColors.proteinColor, textColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _macroField('Carbs (g)', carbsCtrl, AppColors.carbsColor, textColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _macroField('Fat (g)', fatCtrl, AppColors.fatColor, textColor)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    globalProteinGoal.value = int.tryParse(proteinCtrl.text) ?? 150;
                    globalCarbsGoal.value = int.tryParse(carbsCtrl.text) ?? 275;
                    globalFatGoal.value = int.tryParse(fatCtrl.text) ?? 70;
                    
                    await prefs.setInt('proteinGoal', globalProteinGoal.value);
                    await prefs.setInt('carbsGoal', globalCarbsGoal.value);
                    await prefs.setInt('fatGoal', globalFatGoal.value);
                    
                    setState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('SAVE MACROS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _macroField(String label, TextEditingController ctrl, Color color, Color textColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl, keyboardType: TextInputType.number, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          decoration: InputDecoration(filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    String currentThemeName = themeNotifier.value == ThemeMode.system ? 'System' : (themeNotifier.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode');

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 🔥 1. Header Animation 🔥
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
                    Icon(Icons.settings, color: textColor),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // 🔥 2. Avatar Animation (पॉप होकर आएगा) 🔥
              ZoomIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: 100, height: 100, 
                  decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), 
                  child: Icon(Icons.person, size: 50, color: textLight)
                ),
              ),
              const SizedBox(height: 16),
              
              // 🔥 3. Name & Email Animation 🔥
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text('Roshan_IO', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('roshancodes036@gmail.com', style: TextStyle(color: textLight, fontSize: 14)), // मैंने इसे आपके असली ईमेल से अपडेट कर दिया है 😉
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 🔥 4. Nutrition Goals Section Animation 🔥
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: Align(alignment: Alignment.centerLeft, child: Text('NUTRITION GOALS', style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)))
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: _buildSettingsTile(Icons.local_fire_department, Colors.orange, 'Daily Calorie Goal', '${globalCalorieGoal.value} kcal', cardColor, textColor, textLight, () => _showEditGoalBottomSheet(textColor, textLight, bgColor))
              ),
              const SizedBox(height: 12),
              
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 500),
                child: _buildSettingsTile(Icons.fitness_center, AppColors.primaryGreen, 'Macronutrients', 'P: ${globalProteinGoal.value}  C: ${globalCarbsGoal.value}  F: ${globalFatGoal.value}', cardColor, textColor, textLight, () => _showMacrosBottomSheet(textColor, textLight, bgColor))
              ),

              const SizedBox(height: 40),
              
              // 🔥 5. Preferences Section Animation 🔥
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 500),
                child: Align(alignment: Alignment.centerLeft, child: Text('PREFERENCES', style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)))
              ),
              const SizedBox(height: 16),
              
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 500),
                child: _buildSettingsTile(Icons.brightness_6, Colors.blueAccent, 'Theme', currentThemeName, cardColor, textColor, textLight, () => _showThemeBottomSheet(bgColor, textColor))
              ),
              
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 6. Bouncy Touch Effect for Tiles 🔥
  Widget _buildSettingsTile(IconData icon, Color iconColor, String title, String value, Color cardColor, Color textColor, Color textLight, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold))),
            Text(value, style: TextStyle(color: textLight, fontSize: 14)),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: textLight, size: 14),
          ],
        ),
      ),
    );
  }
}