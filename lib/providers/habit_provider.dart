import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/habit_model.dart';
import '../domain/repositories/habit_repository.dart';
import '../data/datasources/firestore_datasource.dart';
import '../data/repositories/habit_repository_impl.dart';
import 'auth_provider.dart';

// ── Category list (shared across the app) ──────────────────────────────────
const List<String> habitCategories = [
  'Health',
  'Education',
  'Mindfulness',
  'Productivity',
  'Social',
  'Finance',
  'Hobby',
  'Other',
];

// ── Data layer providers ────────────────────────────────────────────────────

/// Provides the Firestore data source (Data Layer)
final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSource();
});

/// Provides the concrete HabitRepository implementation (Data Layer)
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final dataSource = ref.watch(firestoreDataSourceProvider);
  return HabitRepositoryImpl(dataSource);
});

// ── Presentation providers ──────────────────────────────────────────────────

/// Real-time stream of all habits for the current user (Presentation Layer)
final habitProvider = StreamProvider<List<Habit>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabits(userId);
});

/// Derived provider: habit completion counts for the last 7 days.
/// Returns a list of 7 ints (index 0 = today-6, index 6 = today).
final habitCompletionStatsProvider = Provider<List<int>>((ref) {
  final habitsAsync = ref.watch(habitProvider);

  return habitsAsync.when(
    data: (habits) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        return habits
            .where((h) =>
                h.isCompleted &&
                DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day)
                    .isAtSameMomentAs(day))
            .length;
      });
    },
    loading: () => List.filled(7, 0),
    error: (_, __) => List.filled(7, 0),
  );
});

/// Provider exposing CRUD / toggle actions (Presentation Layer)
final habitActionsProvider = Provider<HabitActions>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return HabitActions(repository, userId);
});

class HabitActions {
  final HabitRepository _repository;
  final String? _userId;

  HabitActions(this._repository, this._userId);

  Future<void> addHabit(Habit habit) async {
    if (_userId == null) return;
    await _repository.addHabit(_userId, habit);
  }

  Future<void> updateHabit(String id, Habit habit) async {
    if (_userId == null) return;
    await _repository.updateHabit(_userId, id, habit);
  }

  Future<void> deleteHabit(String id) async {
    if (_userId == null) return;
    await _repository.deleteHabit(_userId, id);
  }

  Future<void> toggleHabit(String id, bool currentStatus) async {
    if (_userId == null) return;
    await _repository.toggleHabit(_userId, id, !currentStatus);
  }
}