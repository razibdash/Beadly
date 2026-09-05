import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A calendar-heatmap grid for the current month, with rounded soft cells
/// colored by round-completion intensity for that day (GitHub-contributions
/// style, but gentler).
class MonthlyHeatmap extends StatelessWidget {
  final DateTime month;
  final Map<int, int> roundsByDay; // day-of-month -> rounds
  final int todayDay;

  const MonthlyHeatmap({
    super.key,
    required this.month,
    required this.roundsByDay,
    required this.todayDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon
    final daysInMonth = roundsByDay.length;
    final maxVal = roundsByDay.values.fold<int>(1, (a, b) => a > b ? a : b);
    final leadingBlanks = firstWeekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final trackColor = theme.colorScheme.onSurface.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final rounds = roundsByDay[day] ?? 0;
            final intensity = rounds == 0 ? 0.0 : (rounds / maxVal).clamp(0.15, 1.0);
            final isToday = day == todayDay;
            return AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: rounds == 0
                      ? trackColor
                      : Color.lerp(
                          BeadlyColors.accentGold.withValues(alpha: 0.25),
                          BeadlyColors.accentRose,
                          intensity,
                        ),
                  border: isToday
                      ? Border.all(color: BeadlyColors.accentRose, width: 1.6)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: rounds > 0.5 * maxVal
                        ? Colors.white
                        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
