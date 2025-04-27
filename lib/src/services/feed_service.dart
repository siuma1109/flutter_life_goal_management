import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

class FeedService {
  Future<List<Feed>> getFeeds(int page) async {
    final response = await HttpService()
        .get('feeds', queryParameters: {'page': page.toString()});

    final data = jsonDecode(response.body)['data'];
    return feedFromJson(jsonEncode(data));
  }
}
