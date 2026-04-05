import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/habit_model.dart';

/// Data Source – directly communicates with Cloud Firestore.
/// Only the Data Layer should know about Firebase.
class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _habitsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  /// Real-time stream of all habits for [userId].
  Stream<List<Habit>> getHabits(String userId) {
    return _habitsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addHabit(String userId, Habit habit) async {
    await _habitsCollection(userId).doc(habit.id).set(_toFirestore(habit));
  }

  Future<void> updateHabit(
      String userId, String habitId, Habit habit) async {
    await _habitsCollection(userId).doc(habitId).update(_toFirestore(habit));
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    await _habitsCollection(userId).doc(habitId).delete();
  }

  Future<void> toggleHabit(
      String userId, String habitId, bool isCompleted) async {
    await _habitsCollection(userId)
        .doc(habitId)
        .update({'isCompleted': isCompleted});
  }

  // ── Private converters (Firestore ↔ domain model) ──────────────────────

  Map<String, dynamic> _toFirestore(Habit habit) {
    return {
      'title': habit.title,
      'category': habit.category,
      'time': habit.time,
      'isCompleted': habit.isCompleted,
      'createdAt': Timestamp.fromDate(habit.createdAt),
    };
  }

  Habit _fromFirestore(Map<String, dynamic> map, String docId) {
    return Habit(
      id: docId,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      time: map['time'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
