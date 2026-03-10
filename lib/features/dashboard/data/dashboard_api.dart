import 'dart:async';
// import '../../../core/network/api_client.dart'; // जब असली API हो तब इसे अनकमेंट करें

class DashboardApi {
  // final ApiClient _apiClient = ApiClient();

  /// आज की कैलोरी समरी (Calories & Macros) लाने का फंक्शन
  Future<Map<String, dynamic>> fetchDailySummary(DateTime date) async {
    // असली ऐप में हम यहाँ API कॉल करेंगे: 
    // return await _apiClient.getRequest('/summary?date=${date.toIso8601String()}');
    
    // अभी के लिए हम 1 सेकंड का डिले (Delay) देकर स्क्रीनशॉट वाला डेटा भेजेंगे
    await Future.delayed(const Duration(seconds: 1));

    return {
      'current_calories': 1420,
      'goal_calories': 2300,
      'protein': '128g',
      'fat': '52g',
      'carbs': '174g',
    };
  }

  /// आज के मील्स (Breakfast, Lunch, Dinner) लाने का फंक्शन
  Future<List<Map<String, dynamic>>> fetchTodayMeals(DateTime date) async {
    await Future.delayed(const Duration(seconds: 1));

    // स्क्रीनशॉट के हिसाब से Avocado Toast का डेटा
    return [
      {
        'id': '1',
        'meal_type': 'Breakfast',
        'food_name': 'Avocado Toast',
        'calories': 340,
        'protein': '8g',
        'fat': '18g',
        'carbs': '38g',
        'image_url': 'local_placeholder', // बाद में असली इमेज URL आएगा
        'is_verified': true,
      },
      // यहाँ Lunch और Dinner का डेटा भी आ सकता है
    ];
  }
}
