/// Candy asset auto-loading layer.
///
/// Each [CandyType] maps to `assets/candies/candy_<name>.png`. On startup we
/// try to decode each of those files. If a real PNG is present it is used;
/// otherwise the board painter falls back to drawing a procedural candy
/// (distinct colour *and* shape per type).
///
/// This means the game is fully playable now with procedural candies, and the
/// moment the real art from `X:\Programming\Blockzy\assets` is copied into
/// `blockzy/assets/candies/` it is picked up with ZERO code changes.
library;

import 'dart:ui' as ui;

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/candy.dart';

class CandyAssetLoader {
  CandyAssetLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<CandyType, ui.Image?> _images = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The decoded images (or null per type → paint procedurally).
  Map<CandyType, ui.Image?> get images => Map.unmodifiable(_images);

  /// Decodes each candy PNG once. Safe to call multiple times.
  Future<void> load() async {
    if (_loaded) return;
    for (final type in CandyType.values) {
      final path = 'assets/candies/${type.assetKey}.png';
      _images[type] = await _tryDecode(path);
    }
    _loaded = true;
  }

  Future<ui.Image?> _tryDecode(String path) async {
    try {
      final data = await _bundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      // Asset absent / not declared — signal "paint procedurally".
      return null;
    }
  }

  ui.Image? imageFor(CandyType type) => _images[type];

  /// Whether ANY real candy art shipped (used for a settings note).
  bool get hasAnyRealArt => _images.values.any((v) => v != null);
}
