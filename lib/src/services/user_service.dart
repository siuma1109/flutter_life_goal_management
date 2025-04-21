import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
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
    final result = await _httpService.get('user');
    return User.fromJson(jsonDecode(result.body));
  }
}
