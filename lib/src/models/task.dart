class Task {
  final int? id;
  final int? parentId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  bool isChecked;
  final int userId;
  final int? projectId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    this.parentId,
    required this.userId,
    this.projectId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 4,
    this.isChecked = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'user_id': userId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'is_checked': isChecked,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      parentId: map['parent_id'],
      userId: map['user_id'],
      projectId: map['project_id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      priority: map['priority'],
      isChecked: map['is_checked'] == 1 ? true : false,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Task copyWith({
    int? id,
    int? parentId,
    int? userId,
    int? projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
