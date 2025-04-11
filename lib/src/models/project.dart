class Project {
  final int? id;
  final String name;
  final int userId;
  final int? taskCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    this.id,
    required this.name,
    required this.userId,
    this.taskCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      userId: map['user_id'],
      taskCount: map['task_count'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'task_count': taskCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
