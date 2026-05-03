import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =========================
  // 🔹 GET DATABASE
  // =========================
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // =========================
  // 🔹 INIT DATABASE
  // =========================
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 3, // 🔥 upgraded version (IMPORTANT)
      onCreate: (db, version) async {

        // 📁 RESOURCES TABLE (links + pdfs)
        await db.execute('''
          CREATE TABLE resources (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            value TEXT,
            name TEXT,
            category TEXT
          )
        ''');

        // 📝 TASKS TABLE
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            date TEXT,
            done INTEGER,
            priority TEXT
          )
        ''');
      },

      // 🔄 UPGRADE SAFETY
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {

          await db.execute('''
            CREATE TABLE IF NOT EXISTS resources (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT,
              value TEXT,
              name TEXT,
              category TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              desc TEXT,
              date TEXT,
              done INTEGER,
              priority TEXT
            )
          ''');
        }
      },
    );
  }

  // =================================================
  // 📁 RESOURCES (LINKS + PDF)
  // =================================================

  static Future<int> insertResource(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('resources', data);
  }

  static Future<List<Map<String, dynamic>>> getResources() async {
    final dbClient = await db;

    return await dbClient.query(
      'resources',
      orderBy: 'id DESC',
    );
  }

  static Future<void> deleteResource(int id) async {
    final dbClient = await db;

    await dbClient.delete(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearResources() async {
    final dbClient = await db;
    await dbClient.delete('resources');
  }

  // =================================================
  // 📝 TASKS
  // =================================================

  static Future<int> insertTask(Map<String, dynamic> task) async {
    final dbClient = await db;

    return await dbClient.insert('tasks', {
      'title': task['title'],
      'desc': task['desc'],
      'date': task['date'],
      'done': task['done'] ? 1 : 0,
      'priority': task['priority'],
    });
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final dbClient = await db;

    final result = await dbClient.query(
      'tasks',
      orderBy: 'id DESC',
    );

    return result.map((e) {
      return {
        'id': e['id'],
        'title': e['title'],
        'desc': e['desc'],
        'date': e['date'],
        'done': e['done'] == 1,
        'priority': e['priority'],
      };
    }).toList();
  }

  static Future<void> updateTaskDone(int id, bool done) async {
    final dbClient = await db;

    await dbClient.update(
      'tasks',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteTask(int id) async {
    final dbClient = await db;

    await dbClient.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearTasks() async {
    final dbClient = await db;
    await dbClient.delete('tasks');
  }

  // =================================================
  // 🧹 CLEAR ALL
  // =================================================

  static Future<void> clearAll() async {
    final dbClient = await db;

    await dbClient.delete('resources');
    await dbClient.delete('tasks');
  }
}