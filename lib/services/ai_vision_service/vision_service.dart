import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_keys.dart';

class VisionService {
  late final GenerativeModel _model;

  // Constructor: क्लास बनते ही मॉडल तैयार हो जाएगा (Great approach!)
  VisionService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // मैंने इसे 1.5-flash रखा है क्योंकि यह इमेज प्रोसेसिंग के लिए सबसे स्टेबल है
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  // CameraScanScreen के हिसाब से पैरामीटर्स (imagePath और mode)
  Future<Map<String, dynamic>?> analyzeFoodImage(String imagePath, String mode) async {
    try {
      if (ApiKeys.geminiApiKey.isEmpty) {
        debugPrint("Error: API Key is missing!");
        return null;
      }

      final imageBytes = await File(imagePath).readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      // 🔥 AI के लिए बेहद सख्त प्रॉम्प्ट (आपके नए JSON फॉर्मेट के साथ) 🔥
      final prompt = TextPart('''
        You are a highly advanced, strict, and professional AI Nutritionist and Food Analyzer.
        The user has scanned an image using the "$mode" mode.
        
        INSTRUCTIONS:
        If mode is "Meal", deeply analyze the food/meal shown in the image and calculate its exact nutritional value.
        If mode is "Barcode", read the nutritional label or barcode and extract the exact values.
        
        CRITICAL RULES:
        1. DO NOT output any text, markdown, explanation, or greetings.
        2. YOU MUST output ONLY a pure, valid JSON object.
        3. If you cannot identify the food perfectly, give your absolute best realistic estimate.
        4. Respond ONLY with a valid JSON object in the exact following format:
        {
          "food_name": "Name of the food (e.g., Spaghetti, Avocado Toast)",
          "calories": 679,
          "carbs_percent": "60%",
          "carbs_weight": "103g",
          "protein_percent": "16%",
          "protein_weight": "25g",
          "fat_percent": "24%",
          "fat_weight": "18g"
        }
      ''');

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final textResponse = response.text;

      if (textResponse != null && textResponse.isNotEmpty) {
        String cleanJson = textResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return jsonDecode(cleanJson) as Map<String, dynamic>;
      } else {
        debugPrint('AI did not return a valid response.');
        return null;
      }
    } catch (e) {
      debugPrint('Vision API Error: $e');
      return null;
    }
  }
}