import 'dart:convert';

import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
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

  Future<List<User>> getUsers(
      {int page = 1, int limit = 10, String? search}) async {
    final result = await _httpService.get('users_list', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
    });

    final body = jsonDecode(result.body);
    final data = body['data'];

    return List<User>.from(data.map((e) => User.fromJson(e)));
  }

  Future<List<User>> getUserFollowers(
      {required User user, int page = 1, String? search}) async {
    final result =
        await _httpService.get('users/${user.id}/followers', queryParameters: {
      'page': page,
      if (search != null) 'search': search,
    });

    final body = jsonDecode(result.body);
    final data = body['data'];
    print('Data: $data');

    return List<User>.from(data.map((e) => User.fromJson(e)));
  }

  Future<List<User>> getUserFollowing(
      {required User user, int page = 1, String? search}) async {
    final result =
        await _httpService.get('users/${user.id}/following', queryParameters: {
      'page': page,
      if (search != null) 'search': search,
    });

    final body = jsonDecode(result.body);
    final data = body['data'];
    print('Data: $data');

    return List<User>.from(data.map((e) => User.fromJson(e)));
  }

  Future<bool> followUser(User user) async {
    final result = await _httpService.post('users/${user.id}/follow');
    if (result.statusCode == 200) {
      UserBroadcast().notifyUserChanged(user: user);
      return true;
    }

    return false;
  }

  Future<User?> getUser() async {
    final result = await _httpService.get('user', headers: {
      'Content-Type': 'application/json',
    });

    if (result.statusCode != 200) {
      return null;
    }

    AuthService().setLoggedInUser(User.fromJson(jsonDecode(result.body)));

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
