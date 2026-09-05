import 'dart:io';

import 'package:flutter/services.dart';

/// Controls the Android-only foreground service that keeps the volume
/// buttons counting even while the screen is off or the app isn't in the
/// foreground (see VolumeCounterService.kt). Not supported on other
/// platforms, since Apple does not allow apps to capture hardware volume
/// keys system-wide.
class VolumeCountingService {
  static const _channel = MethodChannel('beadly/volume_service');

  /// Starts the service. Returns false if the user denied the Android 13+
  /// notification permission (the foreground service requires a persistent
  /// notification), or if this isn't Android.
  static Future<bool> start() async {
    if (!Platform.isAndroid) return false;
    final granted = await _channel.invokeMethod<bool>('start');
    return granted ?? true;
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('stop');
  }
}
