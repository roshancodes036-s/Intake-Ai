import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // अगर आप भविष्य में कोई कस्टम बैकएंड बनाते हैं, तो उसका URL यहाँ आएगा
  static const String baseUrl = 'https://your-custom-backend.com/api';

  // GET Request (सर्वर से डेटा लाने के लिए)
  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // POST Request (सर्वर पर डेटा भेजने के लिए, जैसे नई मील सेव करना)
  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // अगर ऑथेंटिकेशन चाहिए
        },
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // API रिस्पॉन्स और एरर हैंडल करने का लॉजिक
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body); // डेटा सफलतापूर्वक मिल गया
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
      case 403:
        throw Exception('Unauthorized: कृपया दोबारा लॉगिन करें');
      case 500:
        throw Exception('Server Error: सर्वर में कुछ खराबी है');
      default:
        throw Exception('Unexpected Error: ${response.statusCode}');
    }
  }
}
