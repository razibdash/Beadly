import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../core/theme.dart';
import '../models/tradition.dart';
import '../state/app_state.dart';
import '../widgets/tradition_select_card.dart';
import 'root_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  TraditionId _selected = TraditionId.hindu;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = BeadlyStrings(appState.settings.languageCode);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/logo/beadly_logo_dark.png'
                      : 'assets/logo/beadly_logo.png',
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s.t('chooseTradition'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                s.t('chooseTraditionSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.65),
                    ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: Tradition.all.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tradition = Tradition.all[index];
                    return TraditionSelectCard(
                      tradition: tradition,
                      selected: _selected == tradition.id,
                      onTap: () => setState(() => _selected = tradition.id),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: BeadlyColors.accentRose,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await appState.completeOnboarding(Tradition.byId(_selected));
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RootShell()),
                        );
                      }
                    },
                    child: Text(s.t('continue')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
