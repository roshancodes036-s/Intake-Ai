import 'dart:io'; // 🔥 असली फोटो दिखाने के लिए यह बहुत ज़रूरी है
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // 🔥 एनिमेशन पैकेज
import '../../../core/constants/colors.dart';
import '../../../core/constants/globals.dart';
import '../../scanner/presentation/camera_scan_screen.dart';
import '../../../services/local_storage/database_helper.dart';
import '../../../app.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  DateTime _selectedDate = DateTime.now();
  int _currentCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFat = 0;
  List<Map<String, dynamic>> _todayMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataForDate();
  }

  Future<void> _loadDataForDate() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      globalCalorieGoal.value = prefs.getInt('calorieGoal') ?? 2500;
      globalProteinGoal.value = prefs.getInt('proteinGoal') ?? 150;
      globalCarbsGoal.value = prefs.getInt('carbsGoal') ?? 275;
      globalFatGoal.value = prefs.getInt('fatGoal') ?? 70;

      String formattedDate = _selectedDate.toIso8601String().split('T').first;
      final dbHelper = DatabaseHelper.instance;

      final meals = await dbHelper.getMealsByDate(formattedDate);
      final totalCals = await dbHelper.getDailyTotalCalories(formattedDate);

      int protein = 0, fat = 0, carbs = 0;
      for (var meal in meals) {
        protein += _parseMacro(meal['protein'].toString());
        fat += _parseMacro(meal['fat'].toString());
        carbs += _parseMacro(meal['carbs'].toString());
      }

      if (mounted) {
        setState(() {
          _todayMeals = meals;
          _currentCalories = totalCals;
          _totalProtein = protein;
          _totalFat = fat;
          _totalCarbs = carbs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _parseMacro(String macroValue) {
    if (macroValue.isEmpty || macroValue == 'null') return 0;
    String cleanString = macroValue.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textLight =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: textColor))
            : RefreshIndicator(
                color: textColor,
                onRefresh: _loadDataForDate,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 1. Header Animation (FadeInDown)
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.apple, color: textColor, size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  'Intake',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '15',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔥 2. Calendar Animation
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 600),
                        child: _buildDynamicCalendarStrip(textColor, textLight),
                      ),
                      const SizedBox(height: 24),

                      AnimatedBuilder(
                        animation: Listenable.merge([
                          globalCalorieGoal,
                          globalProteinGoal,
                          globalCarbsGoal,
                          globalFatGoal,
                        ]),
                        builder: (context, child) {
                          return Column(
                            children: [
                              // 🔥 3. Main Calorie Card (FadeInUp)
                              FadeInUp(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          isDark ? 0.2 : 0.04,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                '$_currentCalories',
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '/${globalCalorieGoal.value}',
                                                style: TextStyle(
                                                  color: textLight,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Calories eaten',
                                            style: TextStyle(
                                              color: textLight,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: globalCalorieGoal.value > 0
                                                  ? (_currentCalories /
                                                            globalCalorieGoal
                                                                .value)
                                                        .clamp(0.0, 1.0)
                                                  : 0.0,
                                              strokeWidth: 8,
                                              backgroundColor: isDark
                                                  ? Colors.white10
                                                  : Colors.grey.shade100,
                                              color: textColor,
                                              strokeCap: StrokeCap.round,
                                            ),
                                            Center(
                                              child: Icon(
                                                Icons.local_fire_department,
                                                color: textColor,
                                                size: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 🔥 4. Macros Row (Staggered FadeInUp)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMacroCard(
                                    'Protein',
                                    _totalProtein,
                                    globalProteinGoal.value,
                                    AppColors.proteinColor,
                                    Icons.restaurant,
                                    cardColor,
                                    textColor,
                                    textLight,
                                    isDark,
                                    0,
                                  ),
                                  _buildMacroCard(
                                    'Carbs',
                                    _totalCarbs,
                                    globalCarbsGoal.value,
                                    AppColors.carbsColor,
                                    Icons.eco,
                                    cardColor,
                                    textColor,
                                    textLight,
                                    isDark,
                                    1,
                                  ),
                                  _buildMacroCard(
                                    'Fats',
                                    _totalFat,
                                    globalFatGoal.value,
                                    AppColors.fatColor,
                                    Icons.water_drop,
                                    cardColor,
                                    textColor,
                                    textLight,
                                    isDark,
                                    2,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // 🔥 5. Meals Title Animation
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          _isToday(_selectedDate)
                              ? 'Uploaded Today'
                              : 'Uploaded on ${_formatDate(_selectedDate)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_todayMeals.isEmpty)
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Text(
                                'No meals found for this date.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _todayMeals.length,
                          itemBuilder: (context, index) {
                            // 🔥 6. Staggered Meals List
                            return FadeInUp(
                              delay: Duration(
                                milliseconds: 700 + (index * 100),
                              ),
                              duration: const Duration(milliseconds: 600),
                              child: _buildMealCard(
                                _todayMeals[index],
                                cardColor,
                                textColor,
                                textLight,
                                isDark,
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDynamicCalendarStrip(Color textColor, Color textLight) {
    List<Widget> dayWidgets = [];
    DateTime today = DateTime.now();

    for (int i = -3; i <= 3; i++) {
      DateTime date = today.add(Duration(days: i));
      dayWidgets.add(_calendarDay(date, textColor, textLight));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dayWidgets,
    );
  }

  Widget _calendarDay(DateTime date, Color textColor, Color textLight) {
    bool isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
        _loadDataForDate();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            weekdays[date.weekday - 1],
            style: TextStyle(
              color: isSelected ? textColor : textLight,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? textColor.withOpacity(0.1)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(color: textColor, width: 2)
                  : null,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? textColor : textLight,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Widget _buildMacroCard(
    String title,
    int current,
    int goal,
    Color color,
    IconData icon,
    Color cardColor,
    Color textColor,
    Color textLight,
    bool isDark,
    int index,
  ) {
    return Expanded(
      child: FadeInUp(
        delay: Duration(milliseconds: 300 + (index * 100)),
        duration: const Duration(milliseconds: 600),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '/${goal}g',
                    style: TextStyle(fontSize: 10, color: textLight),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$title eaten',
                style: TextStyle(fontSize: 10, color: textLight),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                width: 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0,
                      strokeWidth: 4,
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(child: Icon(icon, color: color, size: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 यहाँ असली जादू है: कैमरे वाली फोटो दिखाने का कोड 🔥
  Widget _buildMealCard(
    Map<String, dynamic> meal,
    Color cardColor,
    Color textColor,
    Color textLight,
    bool isDark,
  ) {
    // डेटाबेस से फोटो का रास्ता (Path) निकालना
    String? imagePath = meal['image_path'] ?? meal['image'];

    Widget imageWidget;

    // अगर फोटो का रास्ता मौजूद है और असली फाइल फोन में है, तो असली फोटो दिखाएं
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync()) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath),
          width: 70,
          height: 70,
          fit: BoxFit
              .cover, // फोटो को एकदम परफेक्ट चौकोर आकार में फिट करने के लिए
        ),
      );
    } else {
      // अगर फोटो नहीं मिली, तो वही पुराना बर्गर का आइकॉन दिखाएं (Fallback)
      imageWidget = Icon(Icons.fastfood, color: textLight);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔥 यहाँ इमेज विजेट लगाया गया है 🔥
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageWidget,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal['food_name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(DateTime.parse(meal['date'])),
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: textColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal['calories']} Calories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '🍖 ${meal['protein']}',
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🌾 ${meal['carbs']}',
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🥑 ${meal['fat']}',
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
