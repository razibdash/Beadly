/// Persists completed-round history, keyed by calendar day.
///
/// Kept behind an interface so the on-device implementation can later be
/// swapped for one backed by a remote service, without any UI changes.
abstract class PrayerLogRepository {
  /// All logged rounds, keyed by day as `yyyy-MM-dd`.
  Future<Map<String, int>> getAllLogs();

  /// Adds one completed round to [date]'s tally.
  Future<void> logRound(DateTime date);
}
