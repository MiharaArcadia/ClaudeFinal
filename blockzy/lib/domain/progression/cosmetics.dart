/// Cosmetic catalogue — purely decorative, coins-only, never pay-to-win.
///
/// Cosmetics are unlocked either by hitting a level milestone (see
/// [LevelRewards]) or bought with coins in the Shop. Ids here match the
/// milestone reward ids so both paths converge.
library;

enum CosmeticKind { candySkin, background, frame, effect }

class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.name,
    required this.kind,
    required this.coinCost,
    this.milestoneOnly = false,
  });

  final String id;
  final String name;
  final CosmeticKind kind;

  /// Coin price in the Shop. 0 = free/default.
  final int coinCost;

  /// If true, only obtainable via a level milestone (not purchasable).
  final bool milestoneOnly;
}

class Cosmetics {
  Cosmetics._();

  static const List<Cosmetic> all = [
    // Defaults (always owned).
    Cosmetic(id: 'default', name: 'Classic', kind: CosmeticKind.candySkin, coinCost: 0),

    // Candy skins.
    Cosmetic(id: 'skin_pastel', name: 'Pastel Pop', kind: CosmeticKind.candySkin, coinCost: 400),
    Cosmetic(id: 'skin_neon', name: 'Neon Rush', kind: CosmeticKind.candySkin, coinCost: 800),
    Cosmetic(id: 'skin_crystal', name: 'Crystal', kind: CosmeticKind.candySkin, coinCost: 1500, milestoneOnly: true),

    // Backgrounds.
    Cosmetic(id: 'bg_sunset', name: 'Sunset', kind: CosmeticKind.background, coinCost: 600),
    Cosmetic(id: 'bg_aurora', name: 'Aurora', kind: CosmeticKind.background, coinCost: 1000),
    Cosmetic(id: 'bg_galaxy', name: 'Galaxy', kind: CosmeticKind.background, coinCost: 2000, milestoneOnly: true),

    // Frames.
    Cosmetic(id: 'frame_gold', name: 'Gold Frame', kind: CosmeticKind.frame, coinCost: 500),
    Cosmetic(id: 'frame_neon', name: 'Neon Frame', kind: CosmeticKind.frame, coinCost: 1200),
    Cosmetic(id: 'frame_legend', name: 'Legend Frame', kind: CosmeticKind.frame, coinCost: 0, milestoneOnly: true),

    // Special effects.
    Cosmetic(id: 'fx_rainbow_trail', name: 'Rainbow Trail', kind: CosmeticKind.effect, coinCost: 900, milestoneOnly: true),
    Cosmetic(id: 'fx_starburst', name: 'Starburst', kind: CosmeticKind.effect, coinCost: 1600, milestoneOnly: true),
  ];

  static List<Cosmetic> ofKind(CosmeticKind kind) =>
      all.where((c) => c.kind == kind).toList();

  static Cosmetic? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
