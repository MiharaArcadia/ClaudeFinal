import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:clocky/models/project.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/theme/app_theme.dart';

class ProjectChip extends StatelessWidget {
  final int? selectedProjectId;
  final ValueChanged<int?> onChanged;

  const ProjectChip({
    super.key,
    required this.selectedProjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = context.watch<ProjectProvider>().projects;
    final selected = selectedProjectId != null
        ? projects.cast<Project?>().firstWhere(
            (p) => p?.id == selectedProjectId,
            orElse: () => null,
          )
        : null;

    final chipBg = isDark ? AppColors.surfaceDark2 : const Color(0xFFF0F0F0);
    final borderColor = selected != null
        ? AppColors.primaryOrange
        : (isDark ? AppColors.borderDark : Colors.grey.shade300);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return GestureDetector(
      onTap: () => _showProjectPicker(context, projects),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected?.colorValue ?? AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(width: 8),
            // Project name
            Text(
              selected?.name ?? 'Kein Projekt',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected != null ? textColor : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectPicker(BuildContext context, List<Project> projects) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Projekt wählen',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // "No project" option
              ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textSecondaryDark.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
                title: Text(
                  'Kein Projekt',
                  style: GoogleFonts.dmSans(color: textColor),
                ),
                trailing: selectedProjectId == null
                    ? const Icon(Icons.check_rounded, color: AppColors.primaryOrange)
                    : null,
                onTap: () {
                  onChanged(null);
                  Navigator.pop(ctx);
                },
              ),
              if (projects.isNotEmpty)
                const Divider(height: 1),
              // Project list
              ...projects.map((project) => ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: project.colorValue,
                  ),
                ),
                title: Text(
                  project.name,
                  style: GoogleFonts.dmSans(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: project.clientName != null && project.clientName!.isNotEmpty
                    ? Text(
                        project.clientName!,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: selectedProjectId == project.id
                    ? const Icon(Icons.check_rounded, color: AppColors.primaryOrange)
                    : null,
                onTap: () {
                  onChanged(project.id);
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
