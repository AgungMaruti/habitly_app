/// Domain model – DailyRecord
/// Tracks a single habit completion event for a specific date.
class DailyRecord {
  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
  final String? notes;

  const DailyRecord({
    required this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.notes,
  });
}
