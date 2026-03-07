import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitProvider);
    final filteredHabits = ref.watch(filteredHabitsProvider);
    final habitActions = ref.read(habitActionsProvider);
    final filterStatus = ref.watch(filterStatusProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/habitly_logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.track_changes,
                    color: Colors.white, size: 32);
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
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: AppColors.white,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
            tooltip: 'Toggle Dark Mode',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              borderRadius: const BorderRadius.only(
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
                // Stats
                habitsAsync.when(
                  data: (habits) => Row(
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
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(color: AppColors.white)),
                ),
              ],
            ),
          ),

          // Filter & Sort Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Completed', 'Incomplete'].map((status) {
                      final isSelected = filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            status,
                            style: GoogleFonts.urbanist(
                              color: isSelected
                                  ? AppColors.white
                                  : (isDark ? AppColors.white : AppColors.black),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              isDark ? AppColors.darkCard : AppColors.lightGrey,
                          onSelected: (_) {
                            ref.read(filterStatusProvider.notifier).state =
                                status;
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Sort dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Sort: ',
                        style: GoogleFonts.urbanist(
                            fontSize: 14, color: AppColors.grey)),
                    DropdownButton<String>(
                      value: sortOrder,
                      underline: const SizedBox(),
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                      dropdownColor:
                          isDark ? AppColors.darkCard : AppColors.white,
                      items: ['Newest', 'Oldest', 'A-Z', 'Z-A']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(sortOrderProvider.notifier).state = value;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Habits List
          Expanded(
            child: habitsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: AppColors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error',
                        style: GoogleFonts.urbanist(color: AppColors.grey)),
                  ],
                ),
              ),
              data: (_) => filteredHabits.isEmpty
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
                      itemCount: filteredHabits.length,
                      itemBuilder: (context, index) {
                        final habit = filteredHabits[index];
                        return _buildHabitCard(
                            context, habit, habitActions, isDark);
                      },
                    ),
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
      BuildContext context, Habit habit, HabitActions habitActions, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () => habitActions.toggleHabit(habit.id, habit.isCompleted),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  habit.isCompleted ? AppColors.primary : (isDark ? AppColors.darkGrey : AppColors.lightGrey),
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
            color: isDark ? AppColors.white : AppColors.black,
            decoration: habit.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.category_outlined,
                size: 14,
                color: isDark ? AppColors.lightGrey : AppColors.grey),
            const SizedBox(width: 4),
            Text(habit.category,
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: isDark ? AppColors.lightGrey : AppColors.grey)),
            const SizedBox(width: 12),
            Icon(Icons.access_time,
                size: 14,
                color: isDark ? AppColors.lightGrey : AppColors.grey),
            const SizedBox(width: 4),
            Text(habit.time,
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: isDark ? AppColors.lightGrey : AppColors.grey)),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert,
              color: isDark ? AppColors.white : AppColors.black),
          color: isDark ? AppColors.darkCard : AppColors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero,
                  () => Navigator.pushNamed(context, '/edit-habit',
                      arguments: habit)),
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
                  () => _showDeleteDialog(context, habit.id, habitActions)),
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
      BuildContext context, String habitId, HabitActions habitActions) {
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
              habitActions.deleteHabit(habitId);
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.urbanist()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.urbanist(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text('Logout',
                style: GoogleFonts.urbanist(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}