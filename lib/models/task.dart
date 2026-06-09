// lib/models/task.dart

import 'customer_measurement.dart';

class Task {
  String title;
  String description;
  bool isCompleted;
  DateTime? deliveryDate;
  CustomerMeasurement customer;

  Task({
    required this.title,
    required this.description,
    required this.customer,
    this.isCompleted = false,
    this.deliveryDate,
  });

  // --- PACK ---
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'customer': customer.toJson(), // We pack the customer inside the task
    };
  }

  // --- UNPACK ---
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      customer: CustomerMeasurement.fromJson(json['customer']),
    );
  }
}
