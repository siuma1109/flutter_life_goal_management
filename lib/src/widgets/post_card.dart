import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    final user = post['user'];
    final content = post['content'];
    final interactions = post['interactions'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: user['avatar'] == null
                      ? Icon(Icons.person)
                      : ClipOval(
                          child: Image.network(
                            user['avatar'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person),
                          ),
                        ),
                ),
                SizedBox(width: 8),
                Text(user['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            if (content['text'] != null) Text(content['text']),
            if (content['image'] != null)
              Image.network(
                content['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            if (content['link'] != null)
              TextButton(
                onPressed: () {},
                child: Text('查看詳情'),
              ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(icon: Icon(Icons.thumb_up), onPressed: () {}),
                Text(interactions['likes'].toString()),
                IconButton(icon: Icon(Icons.comment), onPressed: () {}),
                Text(interactions['comments'].toString()),
                IconButton(icon: Icon(Icons.share), onPressed: () {}),
                Text(interactions['shares'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
