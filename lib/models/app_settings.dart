import 'package:flutter/material.dart';
import 'tradition.dart';

class AppSettings {
  final bool onboardingComplete;
  final TraditionId traditionId;
  final int targetCount;
  final String chantName;
  final int currentCount;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ThemeMode themeMode;
  final String languageCode;
  final bool screenOffCountingEnabled;

  const AppSettings({
    required this.onboardingComplete,
    required this.traditionId,
    required this.targetCount,
    required this.chantName,
    required this.currentCount,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.themeMode,
    required this.languageCode,
    required this.screenOffCountingEnabled,
  });

  factory AppSettings.initial() => const AppSettings(
        onboardingComplete: false,
        traditionId: TraditionId.custom,
        targetCount: 108,
        chantName: 'My Chant',
        currentCount: 0,
        soundEnabled: true,
        vibrationEnabled: true,
        themeMode: ThemeMode.system,
        languageCode: 'en',
        screenOffCountingEnabled: false,
      );

  AppSettings copyWith({
    bool? onboardingComplete,
    TraditionId? traditionId,
    int? targetCount,
    String? chantName,
    int? currentCount,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ThemeMode? themeMode,
    String? languageCode,
    bool? screenOffCountingEnabled,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      traditionId: traditionId ?? this.traditionId,
      targetCount: targetCount ?? this.targetCount,
      chantName: chantName ?? this.chantName,
      currentCount: currentCount ?? this.currentCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      screenOffCountingEnabled:
          screenOffCountingEnabled ?? this.screenOffCountingEnabled,
    );
  }
}
