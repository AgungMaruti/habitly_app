import 'package:flutter_test/flutter_test.dart';
import 'package:habitly_app/domain/models/habit_model.dart';

void main() {
  group('Habit Model – Serialization', () {
    final baseMap = {
      'title': 'Morning Run',
      'category': 'Health',
      'time': '07:00',
      'isCompleted': true,
      'createdAt': 1712000000000, // fixed epoch ms
    };

    // Test 1 ────────────────────────────────────────────────────────────────
    test('fromMap deserializes all fields correctly', () {
      final habit = Habit.fromMap(baseMap, 'doc-001');

      expect(habit.id, 'doc-001');
      expect(habit.title, 'Morning Run');
      expect(habit.category, 'Health');
      expect(habit.time, '07:00');
      expect(habit.isCompleted, isTrue);
      expect(habit.createdAt,
          DateTime.fromMillisecondsSinceEpoch(1712000000000));
    });

    // Test 2 ────────────────────────────────────────────────────────────────
    test('toMap serializes to correct plain Map', () {
      final habit = Habit(
        id: 'doc-002',
        title: 'Read Book',
        category: 'Education',
        time: '20:00',
        isCompleted: false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1712000000000),
      );

      final map = habit.toMap();

      expect(map['title'], 'Read Book');
      expect(map['category'], 'Education');
      expect(map['time'], '20:00');
      expect(map['isCompleted'], isFalse);
      expect(map['createdAt'], 1712000000000);
    });

    // Test 3 ────────────────────────────────────────────────────────────────
    test('fromMap uses default values when fields are missing', () {
      final habit = Habit.fromMap({}, 'doc-003');

      expect(habit.title, '');
      expect(habit.category, 'Other');
      expect(habit.time, '');
      expect(habit.isCompleted, isFalse);
    });

    // Test 4 ────────────────────────────────────────────────────────────────
    test('copyWith returns new Habit with overridden fields', () {
      final original = Habit(
        id: 'x',
        title: 'Meditate',
        category: 'Mindfulness',
        time: '06:00',
        isCompleted: false,
        createdAt: DateTime(2024),
      );

      final copy = original.copyWith(isCompleted: true, title: 'Meditate ✓');

      expect(copy.title, 'Meditate ✓');
      expect(copy.isCompleted, isTrue);
      // Original must be unchanged
      expect(original.title, 'Meditate');
      expect(original.isCompleted, isFalse);
    });
  });
}
