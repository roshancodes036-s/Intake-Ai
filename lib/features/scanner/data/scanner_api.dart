import 'dart:io';
import '../../../services/ai_vision_service/vision_service.dart';

class ScannerApi {
  // असली AI सर्विस को यहाँ बुला रहे हैं
  final VisionService _visionService = VisionService();

  Future<Map<String, dynamic>?> analyzeFoodImage(String imagePath) async {
    try {
      // कैमरे से मिली असली फोटो को AI के पास भेज रहे हैं
      return await _visionService.analyzeFoodImage(imagePath, 'Meal');
    } catch (e) {
      throw Exception('इमेज एनालाइज़ करने में दिक्कत आई: $e');
    }
  }
}
