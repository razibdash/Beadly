import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../models/tradition.dart';
import '../state/app_state.dart';
import '../widgets/tradition_select_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTradition(BuildContext context, AppState appState) async {
    final s = BeadlyStrings(appState.settings.languageCode);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('changeTradition'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: Tradition.all.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tradition = Tradition.all[index];
                      return TraditionSelectCard(
                        tradition: tradition,
                        selected: appState.settings.traditionId == tradition.id,
                        onTap: () async {
                          await appState.changeTradition(tradition);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editTarget(BuildContext context, AppState appState, BeadlyStrings s) async {
    final controller = TextEditingController(text: '${appState.settings.targetCount}');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('targetCount')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
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
    final parsed = int.tryParse(result ?? '');
    if (parsed != null && parsed > 0) {
      await appState.setTargetCount(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = BeadlyStrings(appState.settings.languageCode);
    final settings = appState.settings;
    final tradition = appState.tradition;

    return Scaffold(
      appBar: AppBar(title: Text(s.t('settings'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _SectionHeader(s.t('tradition')),
            ListTile(
              leading: Icon(tradition.icon),
              title: Text(tradition.label),
              subtitle: Text(tradition.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTradition(context, appState),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(s.t('targetCount')),
              trailing: Text('${settings.targetCount}'),
              onTap: () => _editTarget(context, appState, s),
            ),
            const Divider(),
            _SectionHeader(s.t('settings')),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: Text(s.t('sound')),
              value: settings.soundEnabled,
              onChanged: appState.setSoundEnabled,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_outlined),
              title: Text(s.t('vibration')),
              value: settings.vibrationEnabled,
              onChanged: appState.setVibrationEnabled,
            ),
            if (Platform.isAndroid)
              SwitchListTile(
                secondary: const Icon(Icons.nightlight_outlined),
                title: Text(s.t('screenOffCounting')),
                subtitle: Text(s.t('screenOffCountingDesc')),
                value: settings.screenOffCountingEnabled,
                onChanged: (value) async {
                  final ok = await appState.setScreenOffCounting(value);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.t('notificationPermissionDenied'))),
                    );
                  }
                },
              ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(s.t('darkMode')),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) =>
                  appState.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(s.t('language')),
              trailing: DropdownButton<String>(
                value: settings.languageCode,
                underline: const SizedBox.shrink(),
                items: BeadlyStrings.supportedLanguages.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) appState.setLanguageCode(value);
                },
              ),
            ),
            const Divider(),
            _SectionHeader(s.t('comingSoon')),
            Opacity(
              opacity: 0.5,
              child: IgnorePointer(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.workspace_premium_outlined),
                      title: Text(s.t('premium')),
                      trailing: Text(s.t('comingSoon')),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_outlined),
                      title: Text(s.t('cloudSync')),
                      trailing: Text(s.t('comingSoon')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).textTheme.labelMedium?.color?.withValues(alpha: 0.5),
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}
