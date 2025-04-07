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
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER,
        is_checked BOOLEAN NOT NULL DEFAULT false,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES tasks (id)
      )
    ''');
  }

  // Insert a task
  Future<int> insertTask(Map<String, dynamic> task) async {
    print("Insert Task::");
    print(task.toString());
    final db = await database;
    return await db.insert('tasks', task);
  }

  // Get all tasks (including subtasks)
  Future<List<Map<String, dynamic>>> getAllTasks(bool withSubTask) async {
    final db = await database;
    if (withSubTask) {
      return await db.query('tasks');
    }
    return await db.query('tasks', where: 'parent_id IS NULL');
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
