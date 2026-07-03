/// App-wide [ThemeData] built from the design tokens. Provides a dark (primary)
/// and light theme; the light theme doubles as a battery-saver / accessibility
/// friendly surface.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _base(Brightness.dark);
  static ThemeData get light => _base(Brightness.light);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? BlockzyColors.bgDeep : BlockzyColors.bgDeepLight;
    final surface = isDark ? BlockzyColors.bgPanel : BlockzyColors.bgPanelLight;
    final textColor =
        isDark ? BlockzyColors.textPrimary : BlockzyColors.textOnLight;

    final textTheme = GoogleFonts.baloo2TextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: textColor, displayColor: textColor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BlockzyColors.primary,
        brightness: brightness,
        surface: surface,
      ),
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
    );
  }
}
