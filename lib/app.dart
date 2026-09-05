import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/strings.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'state/app_state.dart';

class BeadlyApp extends StatefulWidget {
  const BeadlyApp({super.key});

  @override
  State<BeadlyApp> createState() => _BeadlyAppState();
}

class _BeadlyAppState extends State<BeadlyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Picks up any count/log changes the Android screen-off counting
      // service made to on-device storage while this isolate was paused.
      context.read<AppState>().refreshFromStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.isLoading) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final languageCode = appState.settings.languageCode;
        final isRtl = languageCode == 'ar';
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: BeadlyStrings(languageCode).t('appName'),
          theme: BeadlyTheme.light(),
          darkTheme: BeadlyTheme.dark(),
          themeMode: appState.settings.themeMode,
          builder: (context, child) => Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
          home: appState.settings.onboardingComplete
              ? const RootShell()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
