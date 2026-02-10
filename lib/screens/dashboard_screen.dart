import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/habit_model.dart';
import 'package:habitly_app/providers/habit_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/habitly_logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.track_changes, color: Colors.white, size: 32);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Habitly',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today',
                    style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: AppColors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Total Habits',
                        habits.length.toString(), Icons.list_alt),
                    const SizedBox(width: 12),
                    _buildStatCard(
                        'Completed',
                        habits.where((h) => h.isCompleted).length.toString(),
                        Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No habits yet',
                            style: GoogleFonts.urbanist(
                                fontSize: 18, color: AppColors.grey)),
                        const SizedBox(height: 8),
                        Text('Tap + button to add your first habit',
                            style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: AppColors.grey.withOpacity(0.7))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _buildHabitCard(context, habit, habitNotifier);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-habit'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: AppColors.white.withOpacity(0.9))),
                Text(value,
                    style: GoogleFonts.urbanist(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(
      BuildContext context, Habit habit, HabitNotifier habitNotifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () => habitNotifier.toggleHabit(habit.id),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: habit.isCompleted ? AppColors.primary : AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              habit.isCompleted ? Icons.check : Icons.circle_outlined,
              color: habit.isCompleted ? AppColors.white : AppColors.grey,
            ),
          ),
        ),
        title: Text(
          habit.title,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            decoration: habit.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.category_outlined, size: 14, color: AppColors.grey),
            const SizedBox(width: 4),
            Text(habit.category,
                style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.grey)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time, size: 14, color: AppColors.grey),
            const SizedBox(width: 4),
            Text(habit.time,
                style: GoogleFonts.urbanist(fontSize: 12, color: AppColors.grey)),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero,
                  () => Navigator.pushNamed(context, '/edit-habit', arguments: habit)),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Edit', style: GoogleFonts.urbanist()),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero,
                  () => _showDeleteDialog(context, habit.id, habitNotifier)),
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: AppColors.red),
                  const SizedBox(width: 8),
                  Text('Delete', style: GoogleFonts.urbanist()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String habitId, HabitNotifier habitNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this habit?',
            style: GoogleFonts.urbanist()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.urbanist(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              habitNotifier.deleteHabit(habitId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Habit deleted successfully')),
              );
            },
            child: Text('Delete',
                style: GoogleFonts.urbanist(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}