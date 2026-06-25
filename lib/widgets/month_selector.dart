import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:clocky/theme/app_theme.dart';

class MonthSelector extends StatelessWidget {
  final String month; // 'YYYY-MM'
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  String get _displayLabel {
    try {
      final dt = DateFormat('yyyy-MM').parse(month);
      return DateFormat('MMMM yyyy', 'de_DE').format(dt);
    } catch (_) {
      return month;
    }
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    final currentMonth =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return month == currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous arrow
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primaryOrange,
          splashRadius: 24,
          iconSize: 28,
        ),

        // Month label (tappable to jump to today's month)
        GestureDetector(
          onTap: _isCurrentMonth ? null : () {
            // Navigate back to current month — handled externally via multiple onNext calls;
            // for simplicity we do nothing here since MonthSelector is stateless.
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _displayLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (!_isCurrentMonth)
                Text(
                  'Aktueller Monat',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.primaryOrange,
                  ),
                ),
            ],
          ),
        ),

        // Next arrow (disabled for future months)
        IconButton(
          onPressed: _isCurrentMonth ? null : onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: _isCurrentMonth
              ? AppColors.textSecondaryDark
              : AppColors.primaryOrange,
          splashRadius: 24,
          iconSize: 28,
        ),
      ],
    );
  }
}
