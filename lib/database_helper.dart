import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// LOGIC: All database code lives in this file (not mixed into the widgets)
class DatabaseHelper {
  // LOGIC: Holds the open database so we open it only once
  static Database? _database;

  // LOGIC: Open (or create) goals.db and create the goals table
  static Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    // Combine the databases folder with the file name using join()
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'goals.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            hours INTEGER,
            done INTEGER
          )
        ''');
      },
    );
    return _database!;
  }

  // LOGIC: Save a goal and return its new id
  static Future<int> insertGoal(Map<String, dynamic> goal) async {
    final db = await initDatabase();
    return await db.insert('goals', {
      'subject': goal['subject'],
      'hours': goal['hours'],
      // bool (Dart) -> int (SQLite): true = 1, false = 0
      'done': goal['done'] == true ? 1 : 0,
    });
  }

  // LOGIC: Return all saved goals as a list of Maps
  static Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await initDatabase();
    final List<Map<String, dynamic>> rows =
        await db.query('goals', orderBy: 'id ASC');

    return rows.map((row) {
      return {
        'id': row['id'],
        'subject': row['subject'],
        'hours': row['hours'],
        // int (SQLite) -> bool (Dart): compare to 1
        'done': row['done'] == 1,
      };
    }).toList();
  }

  // LOGIC: Change the done value of one goal
  static Future<void> updateGoal(int id, bool done) async {
    final db = await initDatabase();
    await db.update(
      'goals',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // LOGIC: Remove one goal
  static Future<void> deleteGoal(int id) async {
    final db = await initDatabase();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}