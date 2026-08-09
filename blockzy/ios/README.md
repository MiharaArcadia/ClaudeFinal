# iOS readiness

The architecture is deliberately portable: all game logic is pure Dart and the
UI is Flutter, so an iOS release is close to "just build it".

To generate the iOS Runner project on a machine with Xcode:

    cd blockzy
    flutter create --platforms=ios .
    flutter build ios --release

Nothing in `lib/` is Android-specific. Platform-touching services degrade
gracefully:
- `HapticService` uses the cross-platform `HapticFeedback` channel plus the
  `vibration` plugin (iOS supported).
- `AudioService` uses `audioplayers` (iOS supported) and no-ops on missing files.
- `url_launcher` opens the PayPal link on both platforms.

The Support page copy already states the iOS release is the developer's goal.
