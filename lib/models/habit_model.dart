import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String id;
  String title;
  String category;
  String time;
  bool isCompleted;
  DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Konversi Habit → Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'time': time,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Konversi Map dari Firestore → Habit
  factory Habit.fromMap(Map<String, dynamic> map, String documentId) {
    return Habit(
      id: documentId,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Other',
      time: map['time'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Method untuk toggle completed
  void toggleCompleted() {
    isCompleted = !isCompleted;
  }
}