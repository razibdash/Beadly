import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A 7-bar soft-gradient chart, one bar per day (Mon-Sun), with today
/// highlighted.
class WeeklyBarChart extends StatelessWidget {
  final List<int> roundsByDay; // length 7, Mon..Sun
  final int todayIndex; // 0..6, Mon=0

  const WeeklyBarChart({
    super.key,
    required this.roundsByDay,
    required this.todayIndex,
  });

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = roundsByDay.fold<int>(1, (a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.3).clamp(3, double.infinity).toDouble();
    final mutedColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index > 6) return const SizedBox.shrink();
                  final isToday = index == todayIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? BeadlyColors.accentRose : mutedColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            final isToday = i == todayIndex;
            final value = roundsByDay[i].toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value == 0 ? 0.05 : value,
                  width: 20,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isToday
                        ? const [BeadlyColors.accentGold, BeadlyColors.accentRose]
                        : [
                            BeadlyColors.accentGold.withValues(alpha: 0.35),
                            BeadlyColors.accentRose.withValues(alpha: 0.35),
                          ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
