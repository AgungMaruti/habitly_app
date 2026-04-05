import 'package:flutter_test/flutter_test.dart';

// ── Input validation logic ───────────────────────────────────────────────────
// These functions mirror the validator callbacks used in AddHabitScreen &
// EditHabitScreen FormFields — no Flutter widget pump needed.

String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter habit title';
  }
  return null;
}

String? validateCategory(String? value) {
  if (value == null) {
    return 'Please select a category';
  }
  return null;
}

void main() {
  group('Input Validation – Title', () {
    // Test 12 ────────────────────────────────────────────────────────────────
    test('empty string fails validation', () {
      expect(validateTitle(''), isNotNull);
    });

    // Test 13 ────────────────────────────────────────────────────────────────
    test('whitespace-only string fails validation', () {
      expect(validateTitle('   '), isNotNull);
    });

    // Test 14 ────────────────────────────────────────────────────────────────
    test('non-empty title passes validation (returns null)', () {
      expect(validateTitle('Morning Run'), isNull);
    });

    // Test 15 ────────────────────────────────────────────────────────────────
    test('null input fails validation', () {
      expect(validateTitle(null), isNotNull);
    });
  });

  group('Input Validation – Category', () {
    // Test 16 ────────────────────────────────────────────────────────────────
    test('null category fails validation', () {
      expect(validateCategory(null), isNotNull);
    });

    // Test 17 ────────────────────────────────────────────────────────────────
    test('selected category passes validation (returns null)', () {
      expect(validateCategory('Health'), isNull);
    });
  });
}
