import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  String time;

  @HiveField(4)
  bool isCompleted;


  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    this.isCompleted = false,
  });

  // Method untuk toggle completed
  void toggleCompleted() {
    isCompleted = !isCompleted;
  }
}