import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../services/volume_button_service.dart';
import '../state/app_state.dart';
import '../widgets/bead_pattern_background.dart';
import '../widgets/counter_orb.dart';
import '../widgets/stat_chip.dart';

class CounterScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;
  const CounterScreen({super.key, required this.onOpenSettings});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final _orbKey = GlobalKey<CounterOrbState>();

  @override
  void initState() {
    super.initState();
    // Lets either physical volume button tap the counter (see MainActivity),
    // so a session can be counted one-handed without looking at the screen.
    VolumeButtonService.listen(() => _handleTap(context.read<AppState>()));
  }

  @override
  void dispose() {
    VolumeButtonService.stopListening();
    super.dispose();
  }

  Future<void> _handleTap(AppState appState) async {
    final completed = await appState.increment();
    if (completed) {
      _orbKey.currentState?.playCompletionPulse();
    }
  }

  Future<void> _confirmReset(BuildContext context, AppState appState, BeadlyStrings s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('reset')),
        content: Text(s.t('resetBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.t('reset')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.resetCount();
    }
  }

  Future<void> _renameChant(BuildContext context, AppState appState, BeadlyStrings s) async {
    final controller = TextEditingController(text: appState.settings.chantName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('renameChant')),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(s.t('save')),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await appState.renameChant(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = BeadlyStrings(appState.settings.languageCode);
    final settings = appState.settings;

    return Scaffold(
      body: BeadPatternBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          StatChip(
                            label: s.t('today'),
                            value: '${appState.todayRounds} ${s.t('rounds')}',
                          ),
                          const SizedBox(width: 10),
                          StatChip(
                            label: s.t('thisWeek'),
                            value: '${appState.thisWeekRounds} ${s.t('rounds')}',
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: CounterOrb(
                    key: _orbKey,
                    count: settings.currentCount,
                    target: settings.targetCount,
                    onTap: () => _handleTap(appState),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GestureDetector(
                  onTap: () => _renameChant(context, appState, s),
                  child: Text(
                    settings.chantName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.2),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'reset',
        onPressed: () => _confirmReset(context, appState, s),
        tooltip: s.t('reset'),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
