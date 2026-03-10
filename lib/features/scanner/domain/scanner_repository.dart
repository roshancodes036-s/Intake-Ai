import '../data/scanner_api.dart';

class ScannerRepository {
  final ScannerApi _scannerApi;

  // Constructor में ScannerApi को इंजेक्ट कर रहे हैं
  ScannerRepository({ScannerApi? scannerApi}) 
      : _scannerApi = scannerApi ?? ScannerApi();

  /// कैमरे से मिली इमेज पाथ (Image Path) को एनालाइज़ करने का फंक्शन
  Future<Map<String, dynamic>> analyzeFoodImage(String imagePath) async {
    try {
      // API लेयर से डेटा मंगवा रहे हैं
      final foodData = await _scannerApi.analyzeFoodImage(imagePath);
      
      // AI से कोई डेटा नहीं मिला तो एरर भेजें
      if (foodData == null) {
        throw Exception('AI service returned no data.');
      }
      
      // यहाँ आप चाहें तो डेटा को किसी मॉडल (Model) क्लास में मैप कर सकते हैं
      // अभी के लिए हम सीधा Map<String, dynamic> वापस भेज रहे हैं
      return foodData;
    } catch (e) {
      // अगर API में कोई दिक्कत आती है, तो यहाँ एरर को पकड़कर एक साफ़ मैसेज भेजेंगे
      throw Exception('खाना स्कैन करने में समस्या आई: $e');
    }
  }
}
