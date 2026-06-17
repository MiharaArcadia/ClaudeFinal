import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carby/models/nutrient_gap.dart';
import 'package:carby/theme/app_theme.dart';

class NutrientGapRow extends StatelessWidget {
  final NutrientGap gap;

  const NutrientGapRow({super.key, required this.gap});

  Color get _color {
    if (gap.percentage >= 0.8) return AppColors.green;
    if (gap.percentage >= 0.5) return AppColors.orange;
    return AppColors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              gap.name,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: gap.percentage,
                backgroundColor: AppColors.ringEmpty,
                valueColor: AlwaysStoppedAnimation(_color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              '${gap.current.toInt()} / ${gap.target.toInt()}${gap.unit}',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
