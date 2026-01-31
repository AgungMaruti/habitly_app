class Habit {
  String id;
  String title;
  String category;
  String time;
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