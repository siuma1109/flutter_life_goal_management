class TaskDateCount {
  final String date;
  final int count;

  TaskDateCount({required this.date, required this.count});

  factory TaskDateCount.fromJson(Map<String, dynamic> json) {
    return TaskDateCount(date: json['date'], count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
    };
  }
}
