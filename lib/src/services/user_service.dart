import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

class UserService {
  final HttpService _httpService = HttpService();

  Future<String?> login(String email, String password) async {
    final result = await _httpService.post(
      'login',
      body: {
        'email': email,
        'password': password,
      },
    );
    print("Result: ${result.body}");
    if (result.statusCode == 200) {
      final token = jsonDecode(result.body)['token'];
      return token;
    }

    return null;
  }

  Future<User?> getUser() async {
    final result = await _httpService.get('user', headers: {
      'Content-Type': 'application/json',
    });

    if (result.statusCode != 200) {
      return null;
    }

    return User.fromJson(jsonDecode(result.body));
  }

  Future<Map<String, dynamic>?> register(
      String email, String password, String name) async {
    final result = await _httpService.post('users', body: {
      'email': email,
      'password': password,
      'name': name,
    });

    return jsonDecode(result.body);
  }

  Future<Map<String, dynamic>?> updateUser(User user) async {
    final result = await _httpService.put(
      'users/${user.id}',
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    return jsonDecode(result.body);
  }
}
