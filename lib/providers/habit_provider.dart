import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitly_app/models/habit_model.dart';

const String habitBoxName = 'habits';

// ✅ Riverpod v2: NotifierProvider (bukan StateNotifierProvider)
final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);

// ✅ Riverpod v2: Notifier (bukan StateNotifier)
class HabitNotifier extends Notifier<List<Habit>> {

  // ✅ build() menggantikan constructor + super([])
  @override
  List<Habit> build() {
    return _loadHabits();
  }

  // Ambil Hive Box
  Box<Habit> get _habitBox => Hive.box<Habit>(habitBoxName);

  // READ: Load semua habits dari Hive
  List<Habit> _loadHabits() {
    return _habitBox.values.toList();
  }

  // CREATE: Tambah habit baru
  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    state = [...state, habit];
  }

  // UPDATE: Edit habit yang sudah ada
  Future<void> updateHabit(String id, Habit updatedHabit) async {
    await _habitBox.put(id, updatedHabit);
    state = state.map((habit) {
      return habit.id == id ? updatedHabit : habit;
    }).toList();
  }

  // DELETE: Hapus habit
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    state = state.where((habit) => habit.id != id).toList();
  }

  // TOGGLE: Centang/uncentang habit
  Future<void> toggleHabit(String id) async {
    final index = state.indexWhere((habit) => habit.id == id);
    if (index == -1) return;

    final habit = state[index];
    final updatedHabit = Habit(
      id: habit.id,
      title: habit.title,
      category: habit.category,
      time: habit.time,
      isCompleted: !habit.isCompleted,
    );

    await _habitBox.put(id, updatedHabit);

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedHabit else state[i]
    ];
  }
}