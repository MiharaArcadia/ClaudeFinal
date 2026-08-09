/// Modern haptic feedback. Uses the platform [HapticFeedback] channel for
/// light UI taps and the `vibration` plugin for richer patterns during big
/// moments (combos, victories). Respects the user's haptic toggle.
library;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Intensity/semantic buckets so callers stay expressive.
enum Haptic { selection, light, medium, heavy, success, combo }

class HapticService {
  HapticService();

  bool _enabled = true;
  bool? _hasVibrator;

  void setEnabled({required bool enabled}) => _enabled = enabled;

  Future<bool> _canVibrate() async =>
      _hasVibrator ??= (await Vibration.hasVibrator());

  Future<void> fire(Haptic type) async {
    if (!_enabled) return;
    switch (type) {
      case Haptic.selection:
        await HapticFeedback.selectionClick();
      case Haptic.light:
        await HapticFeedback.lightImpact();
      case Haptic.medium:
        await HapticFeedback.mediumImpact();
      case Haptic.heavy:
        await HapticFeedback.heavyImpact();
      case Haptic.success:
        await _pattern(const [0, 30, 40, 60]);
      case Haptic.combo:
        // A rising double-buzz that scales the excitement.
        await _pattern(const [0, 24, 30, 40, 30, 70]);
    }
  }

  Future<void> _pattern(List<int> pattern) async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(pattern: pattern);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      // Never let haptics break gameplay.
    }
  }
}
