import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton Pattern: ताकि पूरे ऐप में डेटाबेस का एक ही इंस्टेंस इस्तेमाल हो
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // डेटाबेस को एक्सेस करने का गेटवे
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('intake_app.db');
    return _database!;
  }

  // डेटाबेस को इनिशियलाइज़ (Initialize) करना
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // 🔥 डेटाबेस वर्ज़न 1 से 2 कर दिया गया है 🔥
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade:
          _upgradeDB, // 🔥 यह पुराने यूज़र्स का डेटा क्रैश होने से बचाएगा
    );
  }

  // टेबल्स (Tables) क्रिएट करना (नए यूज़र्स के लिए)
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textNullType = 'TEXT'; // 🔥 फोटो के लिए (यह खाली भी हो सकता है)

    await db.execute('''
      CREATE TABLE meals (
        id $idType,
        meal_type $textType,
        food_name $textType,
        calories $intType,
        protein $textType,
        fat $textType,
        carbs $textType,
        date $textType,
        image_path $textNullType -- 🔥 यहाँ हमने नया 'चोर' पकड़ने वाला कॉलम जोड़ दिया!
      )
    ''');
  }

  // 🔥 अपग्रेड लॉजिक: अगर फोन में पहले से वर्ज़न 1 है, तो यह चुपके से नया कॉलम जोड़ देगा 🔥
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE meals ADD COLUMN image_path TEXT');
    }
  }

  // ---------------------------------------------------
  // CRUD Operations (Create, Read, Update, Delete)
  // ---------------------------------------------------

  /// नया खाना (Meal) डेटाबेस में सेव करना
  Future<int> insertMeal(Map<String, dynamic> meal) async {
    final db = await instance.database;
    return await db.insert('meals', meal);
  }

  /// किसी खास तारीख (Date) का सारा खाना मंगाना
  Future<List<Map<String, dynamic>>> getMealsByDate(String dateStr) async {
    final db = await instance.database;
    return await db.query('meals', where: 'date = ?', whereArgs: [dateStr]);
  }

  /// आज की कुल कैलोरी (Daily Total) कैलकुलेट करना
  Future<int> getDailyTotalCalories(String dateStr) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meals WHERE date = ?',
      [dateStr],
    );
    int total = result.first['total'] != null
        ? result.first['total'] as int
        : 0;
    return total;
  }

  /// किसी खाने को डिलीट करना
  Future<int> deleteMeal(int id) async {
    final db = await instance.database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  /// डेटाबेस को बंद करना
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
