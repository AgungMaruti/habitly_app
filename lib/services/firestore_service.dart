import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference ke collection habits berdasarkan userId
  CollectionReference<Map<String, dynamic>> _habitsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  // READ: Stream semua habits milik user (real-time)
  Stream<List<Habit>> getHabits(String userId) {
    return _habitsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // CREATE: Tambah habit baru
  Future<void> addHabit(String userId, Habit habit) async {
    await _habitsCollection(userId).doc(habit.id).set(habit.toMap());
  }

  // UPDATE: Edit habit
  Future<void> updateHabit(String userId, String habitId, Habit habit) async {
    await _habitsCollection(userId).doc(habitId).update(habit.toMap());
  }

  // DELETE: Hapus habit
  Future<void> deleteHabit(String userId, String habitId) async {
    await _habitsCollection(userId).doc(habitId).delete();
  }

  // TOGGLE: Centang/uncentang habit
  Future<void> toggleHabit(
      String userId, String habitId, bool isCompleted) async {
    await _habitsCollection(userId).doc(habitId).update({
      'isCompleted': isCompleted,
    });
  }
}
