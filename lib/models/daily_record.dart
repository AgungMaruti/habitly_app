class DailyRecord {
  String id;
  String habitId;
  DateTime date;
  bool isCompleted;
  String? notes;

  DailyRecord({
    required this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.notes,
  });
}