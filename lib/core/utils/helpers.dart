import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppHelpers {
  
  // 1. स्नैकबार (SnackBar) दिखाने के लिए (Success या Error मैसेज)
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    // पहले से खुला हुआ कोई स्नैकबार हो तो उसे हटा दें
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // नया स्नैकबार दिखाएं
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14), // यहाँ Colors.white कर दिया है
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating, // हवा में तैरता हुआ स्नैकबार
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 2. कीबोर्ड छिपाने के लिए (Hide Keyboard)
  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  // 3. स्क्रीन की चौड़ाई (Width) जानने के लिए (Responsive Design के लिए)
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // 4. स्क्रीन की ऊँचाई (Height) जानने के लिए
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // 5. स्ट्रिंग का पहला अक्षर बड़ा (Capitalize) करने के लिए
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}