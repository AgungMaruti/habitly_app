import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitly_app/models/habit_model.dart';
import 'package:habitly_app/services/firestore_service.dart';
import 'package:habitly_app/providers/auth_provider.dart';

// Categories centralized
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

// Provider untuk FirestoreService instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// StreamProvider: habits real-time dari Firestore (berdasarkan userId)
final habitProvider = StreamProvider<List<Habit>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getHabits(userId);
});

// Provider untuk aksi CRUD (add, update, delete, toggle)
final habitActionsProvider = Provider<HabitActions>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return HabitActions(firestoreService, userId);
});

class HabitActions {
  final FirestoreService _firestoreService;
  final String? _userId;

  HabitActions(this._firestoreService, this._userId);

  // CREATE
  Future<void> addHabit(Habit habit) async {
    if (_userId == null) return;
    await _firestoreService.addHabit(_userId, habit);
  }

  // UPDATE
  Future<void> updateHabit(String id, Habit habit) async {
    if (_userId == null) return;
    await _firestoreService.updateHabit(_userId, id, habit);
  }

  // DELETE
  Future<void> deleteHabit(String id) async {
    if (_userId == null) return;
    await _firestoreService.deleteHabit(_userId, id);
  }

  // TOGGLE
  Future<void> toggleHabit(String id, bool currentStatus) async {
    if (_userId == null) return;
    await _firestoreService.toggleHabit(_userId, id, !currentStatus);
  }
}