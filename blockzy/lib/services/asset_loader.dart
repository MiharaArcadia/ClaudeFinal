/// Candy asset auto-loading layer.
///
/// The real candy art is dropped into `assets/candies/`. This loader DISCOVERS
/// whatever image files are there (via the asset manifest) and maps them to the
/// seven [CandyType]s — so it works no matter how the files are named:
///
///  1. exact:    `candy_strawberry.png` → CandyType.strawberry
///  2. keyword:  `red.png` / `berry.webp` → strawberry, `blue.png` → blueberry …
///  3. fallback: leftover files assigned to leftover types in sorted order
///               (handles numbered names like `1.png`, `2.png`).
///
/// Any type without a matching file is drawn procedurally (distinct colour AND
/// shape per type). Nothing else in the app changes when the real art arrives —
/// just copy the PNGs into `blockzy/assets/candies/` and rebuild.
library;

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/candy.dart';

/// Image extensions we recognise as candy art.
const _imageExts = {'.png', '.webp', '.jpg', '.jpeg'};

/// Colour/flavour synonyms used by the keyword matching pass.
const Map<CandyType, List<String>> _synonyms = {
  CandyType.strawberry: ['strawberry', 'red', 'berry'],
  CandyType.lemon: ['lemon', 'yellow'],
  CandyType.blueberry: ['blueberry', 'blue'],
  CandyType.lime: ['lime', 'green'],
  CandyType.grape: ['grape', 'purple', 'violet'],
  CandyType.orange: ['orange'],
  CandyType.mint: ['mint', 'teal', 'cyan'],
};

/// Lower-cased basename without its extension, e.g.
/// `assets/candies/Candy_Strawberry.PNG` → `candy_strawberry`.
String _stem(String path) {
  var name = path.split('/').last.toLowerCase();
  final dot = name.lastIndexOf('.');
  if (dot >= 0) name = name.substring(0, dot);
  return name;
}

bool _isImage(String path) {
  final lower = path.toLowerCase();
  return _imageExts.any(lower.endsWith);
}

/// Pure, testable mapping from a list of candy-image asset paths to a
/// `CandyType → path` assignment. See the class doc for the three passes.
Map<CandyType, String> matchCandyFiles(Iterable<String> paths) {
  // Deterministic order so the fallback pass is stable.
  final files = paths.where(_isImage).toList()..sort();
  final result = <CandyType, String>{};
  final used = <String>{};

  // Pass 1 — exact `candy_<name>`.
  for (final type in CandyType.values) {
    final target = 'candy_${type.name}';
    for (final f in files) {
      if (used.contains(f)) continue;
      if (_stem(f) == target) {
        result[type] = f;
        used.add(f);
        break;
      }
    }
  }

  // Pass 2 — keyword / synonym contains.
  for (final type in CandyType.values) {
    if (result.containsKey(type)) continue;
    final keys = _synonyms[type] ?? [type.name];
    for (final f in files) {
      if (used.contains(f)) continue;
      final stem = _stem(f);
      if (keys.any(stem.contains)) {
        result[type] = f;
        used.add(f);
        break;
      }
    }
  }

  // Pass 3 — sorted-order fallback for anything still unmatched.
  final leftoverTypes =
      CandyType.values.where((t) => !result.containsKey(t)).toList();
  final leftoverFiles = files.where((f) => !used.contains(f)).toList();
  for (var i = 0; i < leftoverTypes.length && i < leftoverFiles.length; i++) {
    result[leftoverTypes[i]] = leftoverFiles[i];
  }

  return result;
}

class CandyAssetLoader {
  CandyAssetLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<CandyType, ui.Image?> _images = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The decoded images (or null per type → paint procedurally).
  Map<CandyType, ui.Image?> get images => Map.unmodifiable(_images);

  /// Discovers and decodes candy art once. Safe to call multiple times.
  Future<void> load() async {
    if (_loaded) return;
    for (final type in CandyType.values) {
      _images[type] = null;
    }

    try {
      final paths = await _candyAssetPaths();
      final mapping = matchCandyFiles(paths);
      for (final entry in mapping.entries) {
        _images[entry.key] = await _tryDecode(entry.value);
      }
    } catch (e) {
      // Manifest unreadable / unexpected shape — stay fully procedural.
      if (kDebugMode) debugPrint('[assets] candy discovery skipped: $e');
    }

    _loaded = true;
  }

  /// Every declared asset path under `assets/candies/`.
  Future<List<String>> _candyAssetPaths() async {
    final manifestJson = await _bundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    return manifest.keys
        .where((k) => k.startsWith('assets/candies/') && _isImage(k))
        .toList();
  }

  Future<ui.Image?> _tryDecode(String path) async {
    try {
      final data = await _bundle.load(path);
      final codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      if (kDebugMode) debugPrint('[assets] could not decode $path: $e');
      return null;
    }
  }

  ui.Image? imageFor(CandyType type) => _images[type];

  /// Whether ANY real candy art shipped (used for a settings note).
  bool get hasAnyRealArt => _images.values.any((v) => v != null);
}
