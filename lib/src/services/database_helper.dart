import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        avatar TEXT,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE projects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER,
        user_id INTEGER NOT NULL,
        project_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER,
        is_checked BOOLEAN NOT NULL DEFAULT false,

        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (parent_id) REFERENCES tasks (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (project_id) REFERENCES projects (id)
      );
    ''');

    await db.execute('''
        INSERT INTO users (username, name, email, password) VALUES ('test_user', 'Test User', 'user@example.com', 'password123');
    ''');
  }

  // Insert a task
  Future<int> insertTask(Map<String, dynamic> task) async {
    print("Insert Task::");
    print(task.toString());
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<User?> getUserByEmailOrUsername(String emailOrUsername) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [emailOrUsername, emailOrUsername],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  // Get all tasks (including subtasks)
  Future<List<Map<String, dynamic>>> getAllTasks(
      bool withSubTask, int? userId) async {
    final db = await database;
    var whereClauses = [];
    var whereArgs = [];

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }
    if (withSubTask) {
      whereClauses.add('parent_id IS NOT NULL');
    }

    return await db.query('tasks',
        where: whereClauses.join(' AND '), whereArgs: whereArgs);
  }

  // Get tasks by parent_id (for subtasks)
  Future<List<Map<String, dynamic>>> getSubtasks(int parentId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
  }

  // Get main tasks (tasks without parent)
  Future<List<Map<String, dynamic>>> getMainTasks() async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'parent_id IS NULL',
    );
  }

  // Update a task
  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    final id = task['id'];
    task.remove("id");
    print("Update Task::");
    print(task.toString());
    print("ID");
    print(id);
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a task and its subtasks
  Future<int> deleteTask(int id) async {
    print("DELETE");
    print(id);
    final db = await database;
    // First delete all subtasks
    await db.delete(
      'tasks',
      where: 'parent_id = ?',
      whereArgs: [id],
    );
    // Then delete the main task
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
