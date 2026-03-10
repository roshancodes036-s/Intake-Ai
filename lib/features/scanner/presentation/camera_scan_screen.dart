import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:animate_do/animate_do.dart'; 
import 'package:flutter_animate/flutter_animate.dart'; 
import '../../../core/constants/colors.dart';
import '../../../services/camera_service/camera_helper.dart';
import '../../../services/ai_vision_service/vision_service.dart';
import '../../../services/local_storage/database_helper.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  final CameraHelper _cameraHelper = CameraHelper();
  final VisionService _visionService = VisionService();
  bool _isInitializing = true;
  bool _isScanning = false;

  bool _isShutterPressed = false;
  int _selectedMode = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    await _cameraHelper.initializeCamera();
    if (mounted) setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _cameraHelper.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndAnalyze() async {
    setState(() => _isScanning = true);
    try {
      final picture = await _cameraHelper.takePicture();
      if (picture != null) {
        String currentMode = _selectedMode == 0 ? "Meal" : "Barcode";

        final foodData = await _visionService.analyzeFoodImage(
          picture.path,
          currentMode,
        );

        setState(() => _isScanning = false);
        if (foodData != null && mounted) {
          _showResultBottomSheet(foodData, picture.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI failed to analyze. Please try a clearer picture!')),
          );
        }
      }
    } catch (e) {
      setState(() => _isScanning = false);
    }
  }

  void _showResultBottomSheet(Map<String, dynamic> data, String imagePath) {
    // 🔥 यहाँ हमने बाहरी context को सेव कर लिया ताकि ऐप क्रैश न हो 🔥
    final outerContext = context;

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      // 🔥 यहाँ हमने 'context' का नाम बदलकर 'sheetContext' कर दिया है 🔥
      builder: (sheetContext) {
        final textColor = Theme.of(outerContext).textTheme.bodyLarge?.color ?? Colors.black;
        final textLight = Theme.of(outerContext).textTheme.bodyMedium?.color ?? Colors.grey;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),

              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(File(imagePath), height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
                child: Text(
                  data['food_name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              ZoomIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${data['calories']}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: textColor)),
                    Text(' kcal', style: TextStyle(fontSize: 20, color: textLight)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _macroText('Protein', data['protein_weight']?.toString() ?? '0g', AppColors.proteinColor, textLight),
                    _macroText('Carbs', data['carbs_weight']?.toString() ?? '0g', AppColors.carbsColor, textLight),
                    _macroText('Fat', data['fat_weight']?.toString() ?? '0g', AppColors.fatColor, textLight),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: () async {
                      try {
                        String todayDate = DateTime.now().toIso8601String().split('T').first;

                        // 🔥 डेटा क्लीनिंग: अगर AI ने "172 kcal" भेजा है, तो यह सिर्फ "172" (नंबर) निकालेगा 🔥
                        int cleanCalories = int.tryParse(data['calories'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                        await DatabaseHelper.instance.insertMeal({
                          'meal_type': _selectedMode == 1 ? 'Barcode Scan' : 'Food Scan',
                          'food_name': data['food_name'] ?? 'Unknown Meal',
                          'calories': cleanCalories,
                          'protein': data['protein_weight']?.toString() ?? '0g',
                          'fat': data['fat_weight']?.toString() ?? '0g',
                          'carbs': data['carbs_weight']?.toString() ?? '0g',
                          'date': todayDate,
                          'image_path': imagePath, 
                        });

                        // 🔥 डबल पॉप फिक्स (सबसे सुरक्षित तरीका) 🔥
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext); // 1. बॉटम शीट बंद करो
                        }
                        if (mounted) {
                          Navigator.pop(outerContext); // 2. कैमरा बंद करो
                        }
                      } catch (e) {
                        debugPrint("Database Save Error: $e");
                        if (mounted) {
                          ScaffoldMessenger.of(outerContext).showSnackBar(const SnackBar(content: Text('Failed to save data.')));
                        }
                      }
                    },
                    child: const Text('ADD TO DASHBOARD', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _macroText(String title, String val, Color color, Color textLight) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: TextStyle(fontSize: 12, color: textLight)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Camera Feed
          Positioned.fill(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: Center(child: CameraPreview(_cameraHelper.controller!)),
                  ),
          ),

          // 2. Sci-Fi AI Laser Scanner
          if (_isScanning)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.7)),
                  Positioned(
                    left: 0, right: 0, top: 0,
                    child: Container(
                              height: 4,
                              decoration: BoxDecoration(color: AppColors.primaryGreen, boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.8), blurRadius: 20, spreadRadius: 5)]),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .moveY(begin: 50, end: MediaQuery.of(context).size.height - 100, duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.document_scanner_outlined, color: AppColors.primaryGreen, size: 60)
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.2, 1.2), duration: const Duration(milliseconds: 800))
                            .fade(begin: 0.5, end: 1.0),
                        const SizedBox(height: 20),
                        const Text('Intake AI Scanning...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5))
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .fade(duration: const Duration(milliseconds: 800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 3. UI Overlay
          if (!_isScanning)
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cardColor.withOpacity(0.8), shape: BoxShape.circle), child: Icon(Icons.close, color: textColor)),
                          ),
                          Text('Intake AI', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cardColor.withOpacity(0.8), shape: BoxShape.circle), child: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: textColor)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 30, top: 40),
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withOpacity(0.8), Colors.transparent])),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedMode == 0 ? 'Center meal in frame' : 'Focus on barcode or label', style: TextStyle(color: textLight, fontSize: 14)),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildModeBtn(0, Icons.restaurant, 'Meal Scan', textColor, cardColor, textLight),
                              const SizedBox(width: 20),
                              _buildModeBtn(1, Icons.qr_code_scanner, 'Barcode Scan', textColor, cardColor, textLight),
                            ],
                          ),
                          const SizedBox(height: 30),

                          GestureDetector(
                            onTapDown: (_) => setState(() => _isShutterPressed = true),
                            onTapUp: (_) {
                              setState(() => _isShutterPressed = false);
                              _takePictureAndAnalyze();
                            },
                            onTapCancel: () => setState(() => _isShutterPressed = false),
                            child: AnimatedScale(
                              scale: _isShutterPressed ? 0.85 : 1.0, 
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: cardColor, border: Border.all(color: AppColors.primaryGreen, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: Center(
                                  child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: textColor.withOpacity(0.1))),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(int index, IconData icon, String label, Color textColor, Color cardColor, Color textLight) {
    bool isSelected = _selectedMode == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryGreen : cardColor.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.transparent)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : textLight, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : textLight, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}