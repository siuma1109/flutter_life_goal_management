import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:go_router/go_router.dart';

enum FeedType {
  task,
  project,
  unknown,
}

class FeedUtils {
  static FeedType getFeedType(String typeString) {
    switch (typeString) {
      case 'App\\Models\\Task':
        return FeedType.task;
      case 'App\\Models\\Project':
        return FeedType.project;
      default:
        return FeedType.unknown;
    }
  }

  static String getFeedRelatedTypeKey(Feed feed) {
    switch (feed.feedableType) {
      case 'App\\Models\\Task':
        return 'task';
      case 'App\\Models\\Project':
        return 'project';
      default:
        return '';
    }
  }

  static String getFeedMessage(Feed feed) {
    final type = getFeedType(feed.feedableType);

    switch (type) {
      case FeedType.task:
        return 'Commented on your task';
      case FeedType.project:
        return 'Completed a task';
      case FeedType.unknown:
        return 'New activity';
    }
  }

  static IconData getFeedIcon(Feed feed) {
    final type = getFeedType(feed.feedableType);

    switch (type) {
      case FeedType.task:
        return Icons.comment;
      case FeedType.project:
        return Icons.check_circle;
      case FeedType.unknown:
        return Icons.notifications;
    }
  }

  static void handleFeedTap(
    BuildContext context,
    Feed feed,
  ) {
    final type = getFeedType(feed.feedableType);

    switch (type) {
      case FeedType.task:
        if (feed.feedableId != null) {
          context.pushNamed('taskDetail',
              pathParameters: {'taskId': feed.feedableId.toString()});
        }
        break;
      case FeedType.project:
        if (feed.feedableId != null) {
          context.pushNamed('projectDetail',
              pathParameters: {'projectId': feed.feedableId.toString()});
        }
        break;
      case FeedType.unknown:
        break;
    }
  }
}
