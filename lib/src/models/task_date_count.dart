class TaskDateCount {
  final String date;
  final int count;
  final List<dynamic> ids;

  TaskDateCount({required this.date, required this.count, required this.ids});

  factory TaskDateCount.fromJson(Map<String, dynamic> json) {
    return TaskDateCount(
        date: json['date'], count: json['count'], ids: json['ids']);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
      'ids': ids,
    };
  }
}
