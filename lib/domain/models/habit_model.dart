/// Domain model – Habit
/// Pure Dart, no Firebase dependency.
class Habit {
  final String id;
  final String title;
  final String category;
  final String time;
  final bool isCompleted;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Creates a copy with optional overrides (immutable pattern)
  Habit copyWith({
    String? id,
    String? title,
    String? category,
    String? time,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialise to plain Map (Firestore / Hive / test)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'time': time,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Deserialise from plain Map
  factory Habit.fromMap(Map<String, dynamic> map, String documentId) {
    return Habit(
      id: documentId,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      time: map['time'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }
}
