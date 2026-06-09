// lib/models/task_model.dart

class TaskModel {
  String? id; // Added Cloud ID
  String title;
  DateTime date;
  bool isCompleted;
  String? customerId;

  TaskModel({
    this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.customerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.millisecondsSinceEpoch, // Save as number for sorting
      'isCompleted': isCompleted,
      'customerId': customerId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return TaskModel(
      id: docId ?? json['id'],
      title: json['title'] ?? "Unknown Job",
      date: json['date'] != null
          ? (json['date'] is int
                ? DateTime.fromMillisecondsSinceEpoch(json['date'])
                : DateTime.parse(
                    json['date'].toString(),
                  )) // Handle legacy string dates
          : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      customerId: json['customerId'],
    );
  }
}
