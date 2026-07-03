/// Central design tokens: colours, gradients, radii, shadows, spacing, motion.
///
/// Everything visual references these so the app has one coherent, premium,
/// rounded, gradient-forward identity that's trivial to re-theme.
library;

import 'package:flutter/material.dart';

/// Brand colours. Deliberately original — a candy/berry palette on deep plum.
class BlockzyColors {
  BlockzyColors._();

  // Backgrounds (dark is the primary theme).
  static const Color bgDeep = Color(0xFF120A24); // deep plum
  static const Color bgPanel = Color(0xFF1E1440);
  static const Color bgPanelSoft = Color(0xFF271A54);
  static const Color grid = Color(0xFF2C2060);
  static const Color gridEmpty = Color(0xFF1A1140);

  // Light theme surfaces (accessibility / battery saver friendly).
  static const Color bgDeepLight = Color(0xFFF6F2FF);
  static const Color bgPanelLight = Color(0xFFFFFFFF);

  // Accents.
  static const Color primary = Color(0xFF8B5CF6); // violet
  static const Color secondary = Color(0xFF22D3EE); // cyan
  static const Color accentPink = Color(0xFFFF4D8D);
  static const Color accentGold = Color(0xFFFFD23F);
  static const Color success = Color(0xFF3DDC84);
  static const Color danger = Color(0xFFFF5C5C);

  // Text.
  static const Color textPrimary = Color(0xFFF4EEFF);
  static const Color textSecondary = Color(0xFFB9AEE0);
  static const Color textOnLight = Color(0xFF241B45);
}

/// Reusable gradients.
class BlockzyGradients {
  BlockzyGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
  );

  static const LinearGradient candyPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D8D), Color(0xFFFFB05C)],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE07A), Color(0xFFFFA62E)],
  );

  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: [Color(0xFF2A1C63), Color(0xFF120A24)],
  );
}

/// Corner radii — everything is generously rounded.
class BlockzyRadii {
  BlockzyRadii._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;

  static BorderRadius all(double r) => BorderRadius.circular(r);
}

/// Soft, layered shadows for depth.
class BlockzyShadows {
  BlockzyShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.55),
          blurRadius: 28,
          spreadRadius: 1,
        ),
      ];
}

/// Consistent spacing scale (4pt grid).
class BlockzySpacing {
  BlockzySpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Animation durations/curves so motion feels consistent and juicy.
class BlockzyMotion {
  BlockzyMotion._();
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
}
