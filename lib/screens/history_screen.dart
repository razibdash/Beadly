import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/monthly_heatmap.dart';
import '../widgets/weekly_bar_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _HistoryView { weekly, monthly }

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryView _view = _HistoryView.weekly;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = BeadlyStrings(appState.settings.languageCode);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(s.t('history'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: BeadlyColors.accentGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToggleButton(
                      label: s.t('weekly'),
                      selected: _view == _HistoryView.weekly,
                      onTap: () => setState(() => _view = _HistoryView.weekly),
                    ),
                    _ToggleButton(
                      label: s.t('monthly'),
                      selected: _view == _HistoryView.monthly,
                      onTap: () => setState(() => _view = _HistoryView.monthly),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BeadlyColors.accentGold.withValues(alpha: 0.07),
                    BeadlyColors.accentRose.withValues(alpha: 0.07),
                  ],
                ),
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _view == _HistoryView.weekly
                  ? WeeklyBarChart(
                      roundsByDay: appState.weeklyBars(),
                      todayIndex: now.weekday - 1,
                    )
                  : MonthlyHeatmap(
                      month: now,
                      roundsByDay: appState.monthlyGrid(now),
                      todayDay: now.day,
                    ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _SummaryCard(
                  label: s.t('totalThisWeek'),
                  value: '${appState.thisWeekRounds}',
                  color: BeadlyColors.accentGold,
                  icon: Icons.calendar_view_week_rounded,
                ),
                _SummaryCard(
                  label: s.t('totalThisMonth'),
                  value: '${appState.thisMonthRounds}',
                  color: BeadlyColors.accentRose,
                  icon: Icons.calendar_month_rounded,
                ),
                _SummaryCard(
                  label: s.t('currentStreak'),
                  value: '${appState.currentStreak}',
                  color: BeadlyColors.streakGreen,
                  icon: Icons.local_fire_department_rounded,
                ),
                _SummaryCard(
                  label: s.t('bestDay'),
                  value: '${appState.bestDayRounds}',
                  color: BeadlyColors.bestDayBlue,
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? BeadlyColors.accentGradient : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.28 : 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
