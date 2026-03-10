import '../data/dashboard_api.dart';

class DashboardRepository {
  final DashboardApi _dashboardApi;

  // Constructor में API क्लास को इंजेक्ट कर रहे हैं
  DashboardRepository({DashboardApi? dashboardApi}) 
      : _dashboardApi = dashboardApi ?? DashboardApi();

  /// आज की समरी (कैलोरी और मैक्रोज़) प्राप्त करने का फंक्शन
  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    try {
      // API से डेटा ला रहे हैं
      final summaryData = await _dashboardApi.fetchDailySummary(date);
      
      // यहाँ हम चाहें तो डेटा को अपने हिसाब से बदल सकते हैं (Data formatting)
      // अभी के लिए हम सीधा डेटा भेज रहे हैं
      return summaryData;
    } catch (e) {
      // अगर API में कोई दिक्कत आती है (जैसे इंटरनेट नहीं है), तो यहाँ एरर हैंडल करेंगे
      throw Exception('डैशबोर्ड समरी लोड करने में समस्या आई: $e');
    }
  }

  /// आज के मील्स (Breakfast, Lunch, Dinner) प्राप्त करने का फंक्शन
  Future<List<Map<String, dynamic>>> getTodayMeals(DateTime date) async {
    try {
      final mealsData = await _dashboardApi.fetchTodayMeals(date);
      return mealsData;
    } catch (e) {
      throw Exception('आज का खाना लोड करने में समस्या आई: $e');
    }
  }
}
