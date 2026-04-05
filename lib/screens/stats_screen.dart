import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/habit_provider.dart';

/// StatsScreen – Presentation Layer
/// Displays a weekly bar chart of completed habits.
/// All data comes from [habitCompletionStatsProvider] via Riverpod.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitCompletionStatsProvider);
    final habitsAsync = ref.watch(habitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalHabits = habitsAsync.maybeWhen(
      data: (h) => h.length,
      orElse: () => 0,
    );
    final completedToday = stats.isNotEmpty ? stats.last : 0;
    final maxVal = stats.isEmpty ? 1 : (stats.reduce((a, b) => a > b ? a : b));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary cards ────────────────────────────────────────────
            Row(
              children: [
                _SummaryCard(
                  label: 'Total Habits',
                  value: totalHabits.toString(),
                  icon: Icons.list_alt_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  label: 'Done Today',
                  value: completedToday.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Bar chart header ─────────────────────────────────────────
            Text(
              'Last 7 Days',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Number of habits completed per day',
              style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: isDark ? AppColors.lightGrey : AppColors.grey),
            ),
            const SizedBox(height: 20),

            // ── Bar chart ────────────────────────────────────────────────
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  maxY: (maxVal + 1).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? AppColors.darkGrey : AppColors.primary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} done',
                          GoogleFonts.urbanist(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value == value.floorToDouble()) {
                            return Text(value.toInt().toString(),
                                style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.lightGrey
                                        : AppColors.grey));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = DateTime.now()
                              .subtract(Duration(days: 6 - value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('E').format(day),
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: value.toInt() == 6
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.lightGrey
                                        : AppColors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final isToday = i == 6;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stats[i].toDouble(),
                          color: isToday
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.4),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: (maxVal + 1).toDouble(),
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.04),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Legend ───────────────────────────────────────────────────
            Row(
              children: [
                Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Today',
                    style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: isDark ? AppColors.lightGrey : AppColors.grey)),
                const SizedBox(width: 20),
                Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.4),
                        shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Previous days',
                    style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: isDark ? AppColors.lightGrey : AppColors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widget ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.urbanist(
                        fontSize: 11,
                        color: isDark ? AppColors.lightGrey : AppColors.grey)),
                Text(value,
                    style: GoogleFonts.urbanist(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
