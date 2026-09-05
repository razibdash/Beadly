import '../models/app_settings.dart';

/// Persists user settings and current in-progress count.
///
/// Kept behind an interface so on-device storage can later be swapped for a
/// remote-synced implementation without any UI changes.
abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
