import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _dbName = 'calculator.db';
  static const String _tableName = 'history';

  static Database? _database;

  // Initialize or open the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT,
            result TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  // ✅ INSERT calculation (used in main.dart)
  Future<void> insertCalculation(String expression, String result) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'expression': expression,
        'result': result,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("✅ Saved to SQLite: $expression = $result");
  }

  // ✅ FETCH all calculations (used in history_screen.dart)
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> data =
    await db.query(_tableName, orderBy: 'id DESC');
    print("🧾 Loaded history: $data");
    return data;
  }

  // ✅ CLEAR all history (optional helper)
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(_tableName);
    print("🗑️ History cleared from SQLite.");
  }
}
