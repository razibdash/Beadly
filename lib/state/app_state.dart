import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local_prayer_log_repository.dart';
import '../data/local_settings_repository.dart';
import '../data/prayer_log_repository.dart';
import '../data/settings_repository.dart';
import '../models/app_settings.dart';
import '../models/tradition.dart';
import '../services/sound_service.dart';
import '../services/volume_counting_service.dart';

/// Central app state: current settings + in-progress count, and the daily
/// round-completion log. Talks to storage only through the repository
/// interfaces, so the persistence layer can be swapped later.
class AppState extends ChangeNotifier {
  final SettingsRepository _settingsRepo;
  final PrayerLogRepository _logRepo;

  AppState({
    SettingsRepository? settingsRepository,
    PrayerLogRepository? logRepository,
  })  : _settingsRepo = settingsRepository ?? LocalSettingsRepository(),
        _logRepo = logRepository ?? LocalPrayerLogRepository();

  AppSettings _settings = AppSettings.initial();
  Map<String, int> _logs = {};
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _loading;
  Tradition get tradition => Tradition.byId(_settings.traditionId);
  Map<String, int> get logs => _logs;

  Future<void> load() async {
    _settings = await _settingsRepo.load();
    _logs = await _logRepo.getAllLogs();
    _loading = false;
    notifyListeners();
    // Restores the screen-off counting service after a cold start (it dies
    // with the process, unlike a plain background/home-button pause).
    if (_settings.screenOffCountingEnabled) {
      VolumeCountingService.start();
    }
  }

  /// Re-reads settings and logs from storage without touching the loading
  /// flag, picking up anything the screen-off counting service wrote to the
  /// same on-device storage while this isolate was backgrounded.
  Future<void> refreshFromStorage() async {
    _settings = await _settingsRepo.load();
    _logs = await _logRepo.getAllLogs();
    notifyListeners();
  }

  /// Returns false only when turning it on was refused (e.g. the user denied
  /// the Android 13+ notification permission the foreground service needs).
  Future<bool> setScreenOffCounting(bool value) async {
    if (value) {
      final granted = await VolumeCountingService.start();
      if (!granted) return false;
    } else {
      await VolumeCountingService.stop();
    }
    _settings = _settings.copyWith(screenOffCountingEnabled: value);
    notifyListeners();
    await _persistSettings();
    return true;
  }

  Future<void> _persistSettings() => _settingsRepo.save(_settings);

  Future<void> completeOnboarding(Tradition selected) async {
    _settings = _settings.copyWith(
      onboardingComplete: true,
      traditionId: selected.id,
      targetCount: selected.defaultTarget,
      chantName: selected.defaultChant,
    );
    notifyListeners();
    await _persistSettings();
  }

  Future<void> changeTradition(Tradition selected) async {
    _settings = _settings.copyWith(
      traditionId: selected.id,
      targetCount: selected.defaultTarget,
      chantName: selected.defaultChant,
      currentCount: 0,
    );
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setTargetCount(int target) async {
    if (target <= 0) return;
    _settings = _settings.copyWith(targetCount: target);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> renameChant(String name) async {
    if (name.trim().isEmpty) return;
    _settings = _settings.copyWith(chantName: name.trim());
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setLanguageCode(String code) async {
    _settings = _settings.copyWith(languageCode: code);
    notifyListeners();
    await _persistSettings();
  }

  /// Returns true if this tap completed a round (reached target).
  Future<bool> increment() async {
    final next = _settings.currentCount + 1;
    if (next >= _settings.targetCount) {
      _settings = _settings.copyWith(currentCount: 0);
      final today = DateTime.now();
      final key = LocalPrayerLogRepository.dateKey(today);
      _logs = {..._logs, key: (_logs[key] ?? 0) + 1};
      notifyListeners();
      await _persistSettings();
      await _logRepo.logRound(today);
      if (_settings.vibrationEnabled) {
        HapticFeedback.heavyImpact();
      }
      if (_settings.soundEnabled) {
        SoundService.instance.playChime();
      }
      return true;
    } else {
      _settings = _settings.copyWith(currentCount: next);
      notifyListeners();
      await _persistSettings();
      if (_settings.vibrationEnabled) {
        HapticFeedback.selectionClick();
      }
      if (_settings.soundEnabled) {
        SoundService.instance.playTick();
      }
      return false;
    }
  }

  Future<void> resetCount() async {
    _settings = _settings.copyWith(currentCount: 0);
    notifyListeners();
    await _persistSettings();
  }

  // --- Stats, computed from the daily log map ---

  int roundsOn(DateTime date) =>
      _logs[LocalPrayerLogRepository.dateKey(date)] ?? 0;

  int get todayRounds => roundsOn(DateTime.now());

  int get thisWeekRounds {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    var total = 0;
    for (var i = 0; i < 7; i++) {
      total += roundsOn(monday.add(Duration(days: i)));
    }
    return total;
  }

  int get thisMonthRounds {
    final now = DateTime.now();
    var total = 0;
    _logs.forEach((key, value) {
      final parts = key.split('-');
      if (parts.length == 3 &&
          int.parse(parts[0]) == now.year &&
          int.parse(parts[1]) == now.month) {
        total += value;
      }
    });
    return total;
  }

  int get currentStreak {
    var streak = 0;
    var day = DateTime.now();
    while (roundsOn(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestDayRounds {
    if (_logs.isEmpty) return 0;
    return _logs.values.reduce((a, b) => a > b ? a : b);
  }

  List<int> weeklyBars() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => roundsOn(monday.add(Duration(days: i))));
  }

  Map<int, int> monthlyGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final result = <int, int>{};
    for (var d = 1; d <= daysInMonth; d++) {
      result[d] = roundsOn(DateTime(month.year, month.month, d));
    }
    return result;
  }
}
