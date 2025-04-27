import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

class FeedService {
  Future<List<Feed>> getFeeds(int page) async {
    final response = await HttpService()
        .get('feeds', queryParameters: {'page': page.toString()});

    final data = jsonDecode(response.body)['data'];
    return feedFromJson(jsonEncode(data));
  }

  Future<Comment> addComment(int id, String body) async {
    final user = await AuthService().getLoggedInUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final result = await HttpService().post(
      'feeds/$id/comments',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'body': body,
        'user_id': user.id,
      }),
    );

    if (result.statusCode != 200 && result.statusCode != 201) {
      throw Exception('Failed to add comment');
    }

    return Comment.fromJson(jsonDecode(result.body));
  }

  Future<List<Comment>> getComments(int id, int page) async {
    final result =
        await HttpService().get('feeds/$id/comments', queryParameters: {
      'page': page,
    });

    if (result.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final body = jsonDecode(result.body);
    final data = body['data'];

    return List<Comment>.from(data.map((e) => Comment.fromJson(e)));
  }

  Future<bool> likeFeed(Feed feed) async {
    final result = await HttpService().post('feeds/${feed.id}/like');
    return result.statusCode == 200;
  }
}
