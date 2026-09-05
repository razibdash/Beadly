import 'package:audioplayers/audioplayers.dart';

/// Plays Beadly's bundled tap/completion sound effects.
///
/// Flutter's `SystemSound.play` is unreliable for this: on Android the
/// engine only implements `SystemSoundType.click` (a no-op for `.alert`,
/// which is what the completion chime used), and even `.click` is silently
/// muted whenever the device's "Touch sounds" system setting is off. Real
/// bundled audio sidesteps both problems - it only respects the media
/// volume/mute switch, like any other app sound.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _tickPlayer = AudioPlayer(playerId: 'beadly_tick');
  final AudioPlayer _chimePlayer = AudioPlayer(playerId: 'beadly_chime');
  bool _lowLatencyReady = false;

  Future<void> _ensureLowLatency() async {
    if (_lowLatencyReady) return;
    _lowLatencyReady = true;
    await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _chimePlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  /// Soft tick played on every count increment.
  Future<void> playTick() async {
    await _ensureLowLatency();
    await _tickPlayer.play(AssetSource('sounds/tick.wav'));
  }

  /// Ascending chime played when a round is completed.
  Future<void> playChime() async {
    await _ensureLowLatency();
    await _chimePlayer.play(AssetSource('sounds/chime.wav'));
  }
}
