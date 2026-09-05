import 'package:flutter/services.dart';

/// Bridges to the Android-side volume-key interception (see MainActivity's
/// `dispatchKeyEvent`), which consumes both volume buttons while the app is
/// foregrounded so they tap the bead counter instead of changing device
/// volume. No-op on platforms that never send this channel a message.
class VolumeButtonService {
  static const _channel = MethodChannel('beadly/volume_buttons');

  static void listen(VoidCallback onVolumeKeyPressed) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volumeKeyPressed') {
        onVolumeKeyPressed();
      }
    });
  }

  static void stopListening() {
    _channel.setMethodCallHandler(null);
  }
}
