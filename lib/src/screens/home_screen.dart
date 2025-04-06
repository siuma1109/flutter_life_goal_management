import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/post_card.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAllTasks = false;
  final Map<String, bool> _completedTasks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('今日任務',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._buildTaskList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('動態牆',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityFeed(),
          ],
        ),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(),
    );
  }

  List<Widget> _buildTaskList() {
    final tasks = [
      {'title': '每天閱讀 30 分鐘', 'progress': 0.7},
      {'title': '每週運動三次', 'progress': 0.5},
      {'title': '學習 Flutter', 'progress': 0.3},
      {'title': '寫作 500 字', 'progress': 0.2},
    ];

    final displayedTasks = _showAllTasks ? tasks : tasks.take(2).toList();

    return [
      ...displayedTasks.map((task) {
        final title = task['title'] as String;
        return TaskCard(
          title: title,
          progress: (task['progress'] as num).toDouble(),
          isCompleted: _completedTasks[title] ?? false,
          onCompleted: () {
            setState(() {
              _completedTasks[title] = !(_completedTasks[title] ?? false);
            });
          },
        );
      }).toList(),
      if (!_showAllTasks && tasks.length > 2)
        Center(
          child: TextButton(
            onPressed: () => setState(() => _showAllTasks = true),
            child: Text('查看更多任務'),
          ),
        ),
      if (_showAllTasks)
        Center(
          child: TextButton(
            onPressed: () => setState(() => _showAllTasks = false),
            child: Text('收起'),
          ),
        ),
    ];
  }

  Widget _buildActivityFeed() {
    final posts = [
      {
        'user': {'name': '小明', 'avatar': null},
        'content': {'text': '今天完成了 30 分鐘閱讀！'},
        'timestamp': '2023-10-01T12:00:00Z',
        'interactions': {'likes': 12, 'comments': 3, 'shares': 1},
      },
      {
        'user': {'name': '系統推薦', 'avatar': 'system_avatar_url'},
        'content': {
          'text': '如何養成閱讀習慣',
          'image': 'assets/image1.jpg',
          'link': 'https://example.com',
        },
        'timestamp': '2023-10-01T11:00:00Z',
        'interactions': {'likes': 8, 'comments': 1, 'shares': 0},
      },
      {
        'user': {'name': '小華', 'avatar': 'avatar_url'},
        'content': {'text': '推薦一本好書：《原子習慣》'},
        'timestamp': '2023-10-01T10:00:00Z',
        'interactions': {'likes': 5, 'comments': 0, 'shares': 0},
      },
    ];

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: posts.map((post) => PostCard(post: post)).toList(),
    );
  }
}
