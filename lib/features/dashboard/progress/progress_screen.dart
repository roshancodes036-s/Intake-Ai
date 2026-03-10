import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_keys.dart';
import '../../../services/local_storage/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  bool _isAILoading = false;
  List<int> _weeklyCalories = [];
  List<String> _weekDays = [];
  String _aiInsight = '';

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  // डेटाबेस से पिछले 7 दिन का असली डेटा निकालना
  Future<void> _loadWeeklyData() async {
    List<int> cals = [];
    List<String> days = [];
    final db = DatabaseHelper.instance;

    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String formattedDate = date.toIso8601String().split('T').first;
      
      // हमारे असली डेटाबेस फंक्शन को कॉल कर रहे हैं
      int dayCal = await db.getDailyTotalCalories(formattedDate);
      cals.add(dayCal);
      days.add(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1]);
    }

    if (mounted) {
      setState(() {
        _weeklyCalories = cals;
        _weekDays = days;
        _isLoading = false;
      });
    }
  }

  // Gemini AI को डेटा भेजकर Body Progress पूछना
  Future<void> _askGeminiAboutBody() async {
    setState(() => _isAILoading = true);
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: ApiKeys.geminiApiKey);
      
      String prompt = '''
        I am tracking my nutrition. My daily goal is 2500 calories. 
        Over the last 7 days, my daily calorie intake was: $_weeklyCalories.
        As a professional nutritionist and fitness coach, analyze this trend. 
        Tell me exactly how this specific diet trend will affect my body development, muscle growth, and fat loss in the next 1 month. 
        Keep it highly professional, scientific, but easy to understand. Give me exactly 3 bullet points. No markdown asterisks.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted) {
        setState(() {
          _aiInsight = response.text ?? 'Could not generate insight.';
          _isAILoading = false;
        });
      }
    } catch (e) {
      debugPrint('AI Error: $e');
      if (mounted) setState(() => _isAILoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Weekly Progress', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. कस्टम Bar Chart (बिना किसी fl_chart पैकेज के)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calorie Intake (Last 7 Days)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          // ग्राफ की ऊंचाई कैलोरी के हिसाब से तय होगी
                          double height = (_weeklyCalories[index] / 3000) * 150; 
                          if (height > 150) height = 150; // Max height
                          if (height < 5) height = 5; // Min height
                          return Column(
                            children: [
                              Text('${_weeklyCalories[index]}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(width: 30, height: height, decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8))),
                              const SizedBox(height: 8),
                              Text(_weekDays[index], style: TextStyle(fontSize: 12, color: textColor)),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. AI Body Analysis Button
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    icon: const Icon(Icons.auto_awesome, color: Colors.amber),
                    label: const Text('Analyze Body Development with AI', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    onPressed: _askGeminiAboutBody,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. AI का असली रिज़ल्ट बॉक्स
                if (_isAILoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                if (_aiInsight.isNotEmpty && !_isAILoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.health_and_safety, color: AppColors.primaryGreen),
                            const SizedBox(width: 8),
                            Text('AI Body Insight', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_aiInsight, style: TextStyle(color: textColor, fontSize: 14, height: 1.5)),
                      ],
                    ),
                  ),
                  
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }
}