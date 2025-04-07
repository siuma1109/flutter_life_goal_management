class Task {
  final int? id;
  final int? parentId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority;
  bool isChecked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    this.parentId,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    this.isChecked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'is_checked': isChecked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      parentId: map['parent_id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      priority: map['priority'],
      isChecked: map['is_checked'] == 1 ? true : false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Task copyWith({
    int? id,
    int? parentId,
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
