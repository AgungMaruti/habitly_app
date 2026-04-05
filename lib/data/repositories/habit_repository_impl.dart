import '../../domain/models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/firestore_datasource.dart';

/// Concrete implementation of [HabitRepository].
/// Bridges the domain contract with the Firestore data source.
class HabitRepositoryImpl implements HabitRepository {
  final FirestoreDataSource _dataSource;

  HabitRepositoryImpl(this._dataSource);

  @override
  Stream<List<Habit>> getHabits(String userId) =>
      _dataSource.getHabits(userId);

  @override
  Future<void> addHabit(String userId, Habit habit) =>
      _dataSource.addHabit(userId, habit);

  @override
  Future<void> updateHabit(String userId, String habitId, Habit habit) =>
      _dataSource.updateHabit(userId, habitId, habit);

  @override
  Future<void> deleteHabit(String userId, String habitId) =>
      _dataSource.deleteHabit(userId, habitId);

  @override
  Future<void> toggleHabit(String userId, String habitId, bool isCompleted) =>
      _dataSource.toggleHabit(userId, habitId, isCompleted);
}
