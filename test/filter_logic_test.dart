import 'package:flutter_test/flutter_test.dart';
import 'package:habitly_app/domain/models/habit_model.dart';

// ── Pure filter / sort logic extracted for unit testing ─────────────────────
// These functions mirror the logic inside filteredHabitsProvider so that we
// can test them without spinning up a Riverpod container or Firebase.

List<Habit> applyFilter(
  List<Habit> habits, {
  required String status,         // 'All' | 'Completed' | 'Incomplete'
  String? category,
  required String sort,           // 'Newest' | 'Oldest' | 'A-Z' | 'Z-A'
}) {
  List<Habit> result = List.from(habits);

  if (status == 'Completed') {
    result = result.where((h) => h.isCompleted).toList();
  } else if (status == 'Incomplete') {
    result = result.where((h) => !h.isCompleted).toList();
  }

  if (category != null) {
    result = result.where((h) => h.category == category).toList();
  }

  switch (sort) {
    case 'Newest':
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'Oldest':
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case 'A-Z':
      result.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'Z-A':
      result.sort((a, b) => b.title.compareTo(a.title));
      break;
  }

  return result;
}

// ── Sample data ───────────────────────────────────────────────────────────────
final _h1 = Habit(
  id: '1',
  title: 'Yoga',
  category: 'Health',
  time: '07:00',
  isCompleted: true,
  createdAt: DateTime(2024, 4, 3),
);
final _h2 = Habit(
  id: '2',
  title: 'Read',
  category: 'Education',
  time: '20:00',
  isCompleted: false,
  createdAt: DateTime(2024, 4, 1),
);
final _h3 = Habit(
  id: '3',
  title: 'Meditate',
  category: 'Mindfulness',
  time: '06:00',
  isCompleted: true,
  createdAt: DateTime(2024, 4, 5),
);

void main() {
  final habits = [_h1, _h2, _h3];

  group('Filter Logic', () {
    // Test 5 ─────────────────────────────────────────────────────────────────
    test('filter "Completed" returns only completed habits', () {
      final result =
          applyFilter(habits, status: 'Completed', sort: 'Newest');
      expect(result.length, 2);
      expect(result.every((h) => h.isCompleted), isTrue);
    });

    // Test 6 ─────────────────────────────────────────────────────────────────
    test('filter "Incomplete" returns only non-completed habits', () {
      final result =
          applyFilter(habits, status: 'Incomplete', sort: 'Newest');
      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    // Test 7 ─────────────────────────────────────────────────────────────────
    test('filter "All" returns all habits', () {
      final result = applyFilter(habits, status: 'All', sort: 'Newest');
      expect(result.length, 3);
    });
  });

  group('Sort Logic', () {
    // Test 8 ─────────────────────────────────────────────────────────────────
    test('sort A-Z orders habits alphabetically', () {
      final result = applyFilter(habits, status: 'All', sort: 'A-Z');
      expect(result.map((h) => h.title).toList(),
          ['Meditate', 'Read', 'Yoga']);
    });

    // Test 9 ─────────────────────────────────────────────────────────────────
    test('sort Newest puts most recently created habit first', () {
      final result = applyFilter(habits, status: 'All', sort: 'Newest');
      expect(result.first.id, '3'); // createdAt 2024-04-05
    });

    // Test 10 ────────────────────────────────────────────────────────────────
    test('sort Oldest puts earliest created habit first', () {
      final result = applyFilter(habits, status: 'All', sort: 'Oldest');
      expect(result.first.id, '2'); // createdAt 2024-04-01
    });
  });

  group('Category Filter', () {
    // Test 11 ────────────────────────────────────────────────────────────────
    test('category filter "Health" returns only Health habits', () {
      final result = applyFilter(
        habits,
        status: 'All',
        category: 'Health',
        sort: 'Newest',
      );
      expect(result.length, 1);
      expect(result.first.category, 'Health');
    });
  });
}
