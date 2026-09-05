import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/tradition.dart';
import 'settings_repository.dart';

/// On-device implementation of [SettingsRepository], backed by
/// `shared_preferences` key-value storage.
class LocalSettingsRepository implements SettingsRepository {
  static const _onboardingComplete = 'beadly_onboarding_complete';
  static const _traditionId = 'beadly_tradition_id';
  static const _targetCount = 'beadly_target_count';
  static const _chantName = 'beadly_chant_name';
  static const _currentCount = 'beadly_current_count';
  static const _soundEnabled = 'beadly_sound_enabled';
  static const _vibrationEnabled = 'beadly_vibration_enabled';
  static const _themeMode = 'beadly_theme_mode';
  static const _languageCode = 'beadly_language_code';
  static const _screenOffCountingEnabled = 'beadly_screen_off_counting';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    // The Android screen-off counting service writes to the same
    // SharedPreferences file from native code; reload() is required to see
    // those writes instead of this isolate's cached snapshot.
    await prefs.reload();
    final defaults = AppSettings.initial();
    return AppSettings(
      onboardingComplete: prefs.getBool(_onboardingComplete) ?? defaults.onboardingComplete,
      traditionId: Tradition.fromName(
        prefs.getString(_traditionId) ?? defaults.traditionId.name,
      ).id,
      targetCount: prefs.getInt(_targetCount) ?? defaults.targetCount,
      chantName: prefs.getString(_chantName) ?? defaults.chantName,
      currentCount: prefs.getInt(_currentCount) ?? defaults.currentCount,
      soundEnabled: prefs.getBool(_soundEnabled) ?? defaults.soundEnabled,
      vibrationEnabled: prefs.getBool(_vibrationEnabled) ?? defaults.vibrationEnabled,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == (prefs.getString(_themeMode) ?? defaults.themeMode.name),
        orElse: () => defaults.themeMode,
      ),
      languageCode: prefs.getString(_languageCode) ?? defaults.languageCode,
      screenOffCountingEnabled: prefs.getBool(_screenOffCountingEnabled) ??
          defaults.screenOffCountingEnabled,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingComplete, settings.onboardingComplete);
    await prefs.setString(_traditionId, settings.traditionId.name);
    await prefs.setInt(_targetCount, settings.targetCount);
    await prefs.setString(_chantName, settings.chantName);
    await prefs.setInt(_currentCount, settings.currentCount);
    await prefs.setBool(_soundEnabled, settings.soundEnabled);
    await prefs.setBool(_vibrationEnabled, settings.vibrationEnabled);
    await prefs.setString(_themeMode, settings.themeMode.name);
    await prefs.setString(_languageCode, settings.languageCode);
    await prefs.setBool(_screenOffCountingEnabled, settings.screenOffCountingEnabled);
  }
}
