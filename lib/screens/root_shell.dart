import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../state/app_state.dart';
import 'counter_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// Bottom-nav shell hosting the three main tabs: Counter, History, Settings.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void goToSettings() => setState(() => _index = 2);

  @override
  Widget build(BuildContext context) {
    final s = BeadlyStrings(context.watch<AppState>().settings.languageCode);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CounterScreen(onOpenSettings: goToSettings),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.circle_outlined),
            label: s.t('counter'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            label: s.t('history'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            label: s.t('settings'),
          ),
        ],
      ),
    );
  }
}
