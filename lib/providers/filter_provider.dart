import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/habit_model.dart';
import 'habit_provider.dart';

// Filter status: All, Completed, Incomplete
final filterStatusProvider = StateProvider<String>((ref) => 'All');

// Filter category: null = semua kategori
final filterCategoryProvider = StateProvider<String?>((ref) => null);

// Sort order: Newest, Oldest, A-Z, Z-A
final sortOrderProvider = StateProvider<String>((ref) => 'Newest');

// Derived provider: gabungan habits + filter + sort
final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final habitsAsync = ref.watch(habitProvider);
  final filterStatus = ref.watch(filterStatusProvider);
  final filterCategory = ref.watch(filterCategoryProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  return habitsAsync.when(
    data: (habits) {
      List<Habit> filtered = List.from(habits);

      // Filter by status
      if (filterStatus == 'Completed') {
        filtered = filtered.where((h) => h.isCompleted).toList();
      } else if (filterStatus == 'Incomplete') {
        filtered = filtered.where((h) => !h.isCompleted).toList();
      }

      // Filter by category
      if (filterCategory != null) {
        filtered = filtered.where((h) => h.category == filterCategory).toList();
      }

      // Sort
      switch (sortOrder) {
        case 'Newest':
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'Oldest':
          filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'A-Z':
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Z-A':
          filtered.sort((a, b) => b.title.compareTo(a.title));
          break;
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
