import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:animate_do/animate_do.dart'; // 🔥 नया एनिमेशन पैकेज
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_keys.dart';
import '../../../core/constants/globals.dart';
import '../../../services/local_storage/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isAILoading = false;

  late AnimationController _bodyRotationController;

  List<FlSpot> _pastData = [];
  List<FlSpot> _futurePrediction = [];
  double _avgProtein = 0, _avgCarbs = 0, _avgFat = 0, _consistency = 0;
  List<Map<String, dynamic>> _weeklyData = []; 

  int _todayProtein = 0;
  int _todayCarbs = 0;
  int _todayFat = 0;

  Map<String, dynamic>? _aiAnalysis;

  static const Color accentGreen = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _bodyRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadGodLevelData();
  }

  @override
  void dispose() {
    _bodyRotationController.dispose();
    super.dispose();
  }

  Future<void> _loadGodLevelData() async {
    final db = DatabaseHelper.instance;
    List<FlSpot> past = [];
    List<Map<String, dynamic>> tempWeeklyData = [];

    int totalP = 0, totalC = 0, totalF = 0;
    int daysLogged = 0;

    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String formattedDate = date.toIso8601String().split('T').first;
      String dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

      int dayCal = await db.getDailyTotalCalories(formattedDate);
      final meals = await db.getMealsByDate(formattedDate);

      if (dayCal > 0) daysLogged++;

      int dailyP = 0, dailyC = 0, dailyF = 0;
      for (var meal in meals) {
        dailyP += _parseMacro(meal['protein'].toString());
        dailyC += _parseMacro(meal['carbs'].toString());
        dailyF += _parseMacro(meal['fat'].toString());
      }

      totalP += dailyP; totalC += dailyC; totalF += dailyF;

      past.add(FlSpot((6 - i).toDouble(), dayCal.toDouble()));
      tempWeeklyData.add({'day': dayName, 'calories': dayCal, 'protein': dailyP, 'carbs': dailyC, 'fat': dailyF});

      if (i == 0) {
        _todayProtein = dailyP;
        _todayCarbs = dailyC;
        _todayFat = dailyF;
      }
    }

    List<FlSpot> future = [];
    double lastCal = past.isNotEmpty && past.last.y > 0 ? past.last.y : globalCalorieGoal.value.toDouble();
    for (int i = 6; i <= 13; i++) {
      lastCal = lastCal + ((globalCalorieGoal.value - lastCal) * 0.3) + (math.Random().nextInt(100) - 50);
      future.add(FlSpot(i.toDouble(), lastCal));
    }

    if (mounted) {
      setState(() {
        _pastData = past;
        _futurePrediction = future;
        _weeklyData = tempWeeklyData;
        _avgProtein = globalProteinGoal.value > 0 ? (totalP / 7) / globalProteinGoal.value : 0;
        _avgCarbs = globalCarbsGoal.value > 0 ? (totalC / 7) / globalCarbsGoal.value : 0;
        _avgFat = globalFatGoal.value > 0 ? (totalF / 7) / globalFatGoal.value : 0;
        _consistency = daysLogged / 7.0;
        _isLoading = false;
      });
    }
  }

  int _parseMacro(String macroValue) {
    if (macroValue.isEmpty || macroValue == 'null') return 0;
    String cleanString = macroValue.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  Future<void> _askGeminiAboutBody() async {
    setState(() => _isAILoading = true);
    try {
      if (ApiKeys.geminiApiKey.isEmpty) throw Exception("API Key Missing");

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: ApiKeys.geminiApiKey);
      String weeklyDataJson = jsonEncode(_weeklyData);

      String prompt = '''
        You are an elite Sports Nutritionist and AI Data Analyst.
        My goals are: ${globalCalorieGoal.value} kcal, ${globalProteinGoal.value}g Protein, ${globalCarbsGoal.value}g Carbs, ${globalFatGoal.value}g Fat.
        Here is my intake for the last 7 days: $weeklyDataJson
        CRITICAL RULES:
        1. NO MARKDOWN, NO GREETINGS, NO EXPLANATIONS.
        2. RETURN ONLY PURE JSON.
        3. EXACT FORMAT:
        {
          "projection": "Detailed 1-month prediction of physical growth.",
          "composition": {
            "protein_impact": "Impact on muscle synthesis.",
            "carbs_impact": "Impact on energy.",
            "fat_impact": "Impact on hormones."
          },
          "bullets": ["Actionable insight 1", "Actionable insight 2"]
        }
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final textResponse = response.text;

      if (textResponse != null && textResponse.isNotEmpty) {
        String cleanJson = textResponse.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> parsedData = jsonDecode(cleanJson);
        if (mounted) setState(() { _aiAnalysis = parsedData; _isAILoading = false; });
      } else {
        throw Exception("Empty AI Response");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAILoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI failed. Check console.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF091219) : Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? const Color(0xFFF7F1E4) : Colors.black87;
    final boxBgColor = isDark ? const Color(0xFFF7F1E4).withAlpha(5) : Colors.grey.withAlpha(20);
    final borderColor = isDark ? const Color(0xFFF7F1E4).withAlpha(15) : Colors.grey.withAlpha(50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Intake AI Analytics',
          style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentGreen))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 1. 3D Body Animation 🔥
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _build3DHologramBody(textColor, accentGreen, boxBgColor, borderColor, isDark),
                  ),
                  const SizedBox(height: 40),

                  // 🔥 2. Spider Radar Animation 🔥
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Macro Balance Matrix', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildSpiderRadar(textColor, accentGreen, boxBgColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔥 3. Graph Animation 🔥
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('AI Caloric Forecast', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: accentGreen.withAlpha(51), borderRadius: BorderRadius.circular(10)),
                              child: const Text('AI FORECAST', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTradingGraph(textColor, accentGreen, boxBgColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔥 4. AI Button Animation 🔥
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity, height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: boxBgColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: borderColor),
                          elevation: isDark ? 0 : 2,
                        ),
                        icon: _isAILoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: accentGreen, strokeWidth: 2))
                            : const Icon(Icons.auto_awesome, color: Colors.amber),
                        label: Text(
                          _isAILoading ? 'Analyzing Body Data...' : 'Analyze Body Development with AI',
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isAILoading ? null : _askGeminiAboutBody,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔥 5. AI JSON Results UI Animation 🔥
                  if (_aiAnalysis != null && !_isAILoading)
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildAIResultUI(boxBgColor, textColor, isDark ? Colors.grey : Colors.grey.shade700, borderColor, isDark),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  // === UI Components ===

  Widget _build3DHologramBody(Color textColor, Color accentGreen, Color boxBgColor, Color borderColor, bool isDark) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: boxBgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: accentGreen.withAlpha(isDark ? 15 : 30), blurRadius: 50, spreadRadius: 5)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter(color: accentGreen.withAlpha(isDark ? 26 : 15)))),
          AnimatedBuilder(
            animation: _bodyRotationController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_bodyRotationController.value * 2 * math.pi),
                child: Image.asset('assets/images/body_3d.png', height: 380, fit: BoxFit.contain),
              );
            },
          ),
          Positioned(
            top: 60, left: 25, 
            child: _bodyTag('Protein', '${_todayProtein}g / ${globalProteinGoal.value}g', accentGreen, textColor, isDark)
          ),
          Positioned(
            bottom: 90, right: 25, 
            child: _bodyTag('Fat', '${_todayFat}g / ${globalFatGoal.value}g', Colors.orange, textColor, isDark)
          ),
          Positioned(
            top: 200, right: 35, 
            child: _bodyTag('Carbs', '${_todayCarbs}g / ${globalCarbsGoal.value}g', Colors.blue, textColor, isDark)
          ),
        ],
      ),
    );
  }

  Widget _bodyTag(String title, String value, Color color, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(38) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(128)),
        boxShadow: isDark ? [] : [BoxShadow(color: color.withAlpha(50), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor.withAlpha(179), fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpiderRadar(Color textColor, Color accentGreen, Color boxBgColor) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: boxBgColor, borderRadius: BorderRadius.circular(30)),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: accentGreen.withAlpha(51), borderColor: accentGreen, entryRadius: 4,
              dataEntries: [
                RadarEntry(value: _avgProtein.clamp(0.0, 1.0) * 100),
                RadarEntry(value: _avgCarbs.clamp(0.0, 1.0) * 100),
                RadarEntry(value: _avgFat.clamp(0.0, 1.0) * 100),
                RadarEntry(value: _consistency * 100),
                RadarEntry(value: 85.0),
              ],
            ),
          ],
          radarBackgroundColor: Colors.transparent, borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: textColor.withAlpha(26)), tickCount: 4,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          tickBorderData: BorderSide(color: textColor.withAlpha(26)),
          gridBorderData: BorderSide(color: textColor.withAlpha(50), width: 1),
          getTitle: (index, angle) {
            final titles = ['Protein', 'Carbs', 'Fat', 'Consistency', 'Health'];
            return RadarChartTitle(text: titles[index], angle: 0);
          },
          titleTextStyle: TextStyle(color: textColor.withAlpha(204), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  Widget _buildTradingGraph(Color textColor, Color accentGreen, Color boxBgColor) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(color: boxBgColor, borderRadius: BorderRadius.circular(30)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, drawVerticalLine: false, horizontalInterval: 1000,
            getDrawingHorizontalLine: (value) => FlLine(color: textColor.withAlpha(26), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: 30, interval: 3,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return _chartText('Past', textColor);
                  if (value == 6) return _chartText('Today', textColor);
                  if (value == 13) return _chartText('Future', accentGreen);
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: 45, interval: 1000,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: textColor.withAlpha(128), fontSize: 10)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false), minX: 0, maxX: 13, minY: 0, maxY: 4000,
          lineBarsData: [
            LineChartBarData(
              spots: _pastData, isCurved: true, color: accentGreen, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: accentGreen.withAlpha(26)),
            ),
            LineChartBarData(
              spots: _futurePrediction, isCurved: true, color: Colors.orangeAccent, barWidth: 3, isStrokeCapRound: true, dashArray: [10, 5], dotData: const FlDotData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem('${spot.y.toInt()} kcal', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartText(String text, Color color) {
    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }

  Widget _buildAIResultUI(Color boxBgColor, Color textColor, Color textLight, Color borderColor, bool isDark) {
    final comp = _aiAnalysis!['composition'];
    final bullets = _aiAnalysis!['bullets'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryGreen.withAlpha(isDark ? 51 : 26), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primaryGreen.withAlpha(77)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 28), const SizedBox(width: 10),
                  Text('1-Month Projection', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(_aiAnalysis!['projection'], style: TextStyle(color: textColor, fontSize: 15, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Nutrition Breakdown Impact', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildImpactCard('Muscle Synthesis (Protein)', comp['protein_impact'], AppColors.proteinColor, boxBgColor, textColor, textLight),
        const SizedBox(height: 12),
        _buildImpactCard('Energy & Glycogen (Carbs)', comp['carbs_impact'], AppColors.carbsColor, boxBgColor, textColor, textLight),
        const SizedBox(height: 12),
        _buildImpactCard('Hormone Health (Fat)', comp['fat_impact'], AppColors.fatColor, boxBgColor, textColor, textLight),
        const SizedBox(height: 24),
        Text('Actionable Insights', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...bullets.map((bullet) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20), const SizedBox(width: 12),
              Expanded(child: Text(bullet.toString(), style: TextStyle(color: textColor, fontSize: 15, height: 1.4))),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildImpactCard(String title, String description, Color indicatorColor, Color boxBgColor, Color textColor, Color textLight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: boxBgColor, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: indicatorColor, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: textLight, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width; i += 30) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 30) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}