import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clocky/models/entry.dart';
import 'package:clocky/models/project.dart';
import 'package:clocky/theme/app_theme.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final Project? project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight;
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final projectColor = project?.colorValue ?? AppColors.textSecondaryDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Colored dot
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 14, top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: projectColor,
                  ),
                ),

                // Center column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project name
                      Text(
                        project?.name ?? 'Kein Projekt',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Client name
                      if (project?.clientName != null && project!.clientName!.isNotEmpty)
                        Text(
                          project!.clientName!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Time range + pause
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.startTime} – ${entry.endTime}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                          if (entry.pauseMinutes > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: GoogleFonts.dmSans(color: secondaryText, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pause: ${entry.pauseMinutes} min',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Note
                      if (entry.note != null && entry.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note!,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      entry.formattedDuration,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    if (project != null && project!.hourlyRate > 0)
                      Text(
                        '${(entry.totalHours * project!.hourlyRate).toStringAsFixed(2)} €',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
