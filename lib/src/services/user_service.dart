import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class UserService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // database start
  Future<User?> getUserByEmailOrUsername(String emailOrUsername) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [emailOrUsername, emailOrUsername],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }
  // database end
}
