/// Pure-Dart candy identity — no Flutter imports so the whole game engine
/// stays testable and portable to iOS.
///
/// A [CandyType] carries BOTH a distinct colour and a distinct shape id.
/// Relying on shape as well as colour keeps candies recognisable for
/// colour-blind players (see the accessibility settings).
library;

/// The set of candy colours/flavours used across the game.
///
/// Ordering is stable — persisted saves reference these by [index], so never
/// reorder or remove entries without a save-migration bump.
enum CandyType {
  strawberry, // red
  lemon, //     yellow
  blueberry, //  blue
  lime, //       green
  grape, //      purple
  orange, //     orange
  mint; //       teal

  /// A stable lowercase asset key, e.g. `candy_strawberry.png`.
  String get assetKey => 'candy_$name';

  /// The default palette entry (0xAARRGGBB) used by the procedural painter
  /// when no real PNG asset is present. Presentation may override via skins.
  int get defaultColorValue {
    switch (this) {
      case CandyType.strawberry:
        return 0xFFFF4D6D;
      case CandyType.lemon:
        return 0xFFFFD23F;
      case CandyType.blueberry:
        return 0xFF4D8AFF;
      case CandyType.lime:
        return 0xFF3DDC84;
      case CandyType.grape:
        return 0xFFB05CFF;
      case CandyType.orange:
        return 0xFFFF9F1C;
      case CandyType.mint:
        return 0xFF2EC4B6;
    }
  }

  /// A distinct shape id (0..6) used by the procedural painter so candies are
  /// distinguishable without colour.
  int get shapeId => index;
}

/// How many distinct candy types are unlocked at a given difficulty tier.
///
/// Fewer colours early (easier line-building), more colours later. Clamped to
/// the available [CandyType] count.
int candyPaletteSize(int difficulty) {
  // difficulty 0 -> 3 colours, grows by one roughly every 6 difficulty steps.
  final size = 3 + (difficulty ~/ 6);
  return size.clamp(3, CandyType.values.length);
}
