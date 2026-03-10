import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/ai_vision_service/vision_service.dart';
import '../../../services/local_storage/database_helper.dart';

class AnalyzingScreen extends StatefulWidget {
  final String imagePath;
  const AnalyzingScreen({super.key, required this.imagePath});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final VisionService _visionService = VisionService();
  bool _isAnalyzing = true;
  Map<String, dynamic>? _foodData;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final data = await _visionService.analyzeFoodImage(widget.imagePath, 'Meal');
      if (mounted) {
        setState(() {
          _foodData = data;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
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
        title: Text(_isAnalyzing ? 'Analyzing...' : 'Analysis Complete', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isAnalyzing ? _buildLoadingState(textColor) : _buildResultState(textColor, textLight),
    );
  }

  Widget _buildLoadingState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(File(widget.imagePath), width: 250, height: 250, fit: BoxFit.cover),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: AppColors.primaryGreen),
          const SizedBox(height: 20),
          Text('AI is analyzing your food...', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildResultState(Color textColor, Color textLight) {
    if (_foodData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Could not analyze food.\nPlease check your API Key and internet.', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(height: 24),
            CustomButton(text: 'RETRY', onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.file(File(widget.imagePath), width: double.infinity, height: 300, fit: BoxFit.cover),
          ),
          const SizedBox(height: 30),
          Text(_foodData!['food_name'] ?? 'Unknown Food', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${_foodData!['calories'] ?? 0}', style: TextStyle(color: textColor, fontSize: 56, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text('kcal', style: TextStyle(color: textLight, fontSize: 24, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroIndicator('Carbs', _foodData!['carbs_weight'] ?? '0g', AppColors.carbsColor, textColor, textLight),
              _buildMacroIndicator('Protein', _foodData!['protein_weight'] ?? '0g', AppColors.proteinColor, textColor, textLight),
              _buildMacroIndicator('Fat', _foodData!['fat_weight'] ?? '0g', AppColors.fatColor, textColor, textLight),
            ],
          ),
          const SizedBox(height: 50),
          CustomButton(
            text: 'ADD MEAL',
            onPressed: () async {
              try {
                String todayDate = DateTime.now().toIso8601String().split('T').first;
                final dbHelper = DatabaseHelper.instance;
                await dbHelper.insertMeal({
                  'meal_type': 'Scanned Meal',
                  'food_name': _foodData!['food_name'] ?? 'Unknown',
                  'calories': _foodData!['calories'] ?? 0,
                  'protein': _foodData!['protein_weight'] ?? '0g',
                  'fat': _foodData!['fat_weight'] ?? '0g',
                  'carbs': _foodData!['carbs_weight'] ?? '0g',
                  'date': todayDate,
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal Added Successfully!')));
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint("Save Error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(String title, String weight, Color color, Color textColor, Color textLight) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(weight, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}
