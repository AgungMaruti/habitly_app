import '../models/habit_model.dart';

/// Repository interface (Domain Layer)
/// Defines the contract that the Data Layer must implement.
/// The Presentation Layer only depends on this abstraction.
abstract class HabitRepository {
  /// Returns a real-time stream of all habits for [userId].
  Stream<List<Habit>> getHabits(String userId);

  /// Persists a new [habit] for [userId].
  Future<void> addHabit(String userId, Habit habit);

  /// Updates an existing habit identified by [habitId].
  Future<void> updateHabit(String userId, String habitId, Habit habit);

  /// Permanently removes the habit identified by [habitId].
  Future<void> deleteHabit(String userId, String habitId);

  /// Flips the completion status to [isCompleted] for [habitId].
  Future<void> toggleHabit(String userId, String habitId, bool isCompleted);
}
