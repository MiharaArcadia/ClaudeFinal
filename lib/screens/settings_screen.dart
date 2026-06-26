import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clocky/providers/settings_provider.dart';
import 'package:clocky/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final sectionBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Einstellungen',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section: Mein Profil ────────────────────────────────────────────
          _SectionHeader(title: 'Mein Profil', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              // Logo
              _LogoTile(settings: settings, isDark: isDark),
              _Divider(isDark: isDark),

              // Name
              _TextEditTile(
                icon: Icons.person_outline_rounded,
                title: 'Name',
                value: settings.name,
                hint: 'Max Mustermann',
                onSave: (v) => settings.setName(v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),

              // Company
              _TextEditTile(
                icon: Icons.business_outlined,
                title: 'Unternehmen',
                value: settings.company,
                hint: 'Musterfirma GmbH',
                onSave: (v) => settings.setCompany(v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),

              // Address
              _TextEditTile(
                icon: Icons.location_on_outlined,
                title: 'Adresse',
                value: settings.address,
                hint: 'Musterstraße 1, 12345 Musterstadt',
                multiline: true,
                onSave: (v) => settings.setAddress(v),
                isDark: isDark,
              ),
              _Divider(isDark: isDark),

              // Default rate
              _NumberEditTile(
                icon: Icons.euro_rounded,
                title: 'Standard-Stundensatz',
                value: settings.defaultRate,
                suffix: '€/h',
                onSave: (v) => settings.setDefaultRate(v),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Section: Arbeitszeit ────────────────────────────────────────────
          _SectionHeader(title: 'Arbeitszeit', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _NumberEditTile(
                icon: Icons.schedule_rounded,
                title: 'Stunden pro Tag',
                value: settings.workHoursPerDay,
                suffix: 'h',
                onSave: (v) => settings.setWorkHoursPerDay(v),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Section: Darstellung ────────────────────────────────────────────
          _SectionHeader(title: 'Darstellung', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_outlined,
                        size: 20, color: AppColors.primaryOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Erscheinungsbild',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                    ),
                    _ThemeToggle(
                      current: settings.darkMode,
                      onChanged: (v) => settings.setDarkMode(v),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Section: Über Clocky ────────────────────────────────────────────
          _SectionHeader(title: 'Über Clocky', isDark: isDark),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryOrange, size: 20),
                title: Text('Version',
                    style: GoogleFonts.dmSans(color: primaryText)),
                trailing: Text('1.0.0',
                    style: GoogleFonts.dmSans(color: secondaryText)),
              ),
              _Divider(isDark: isDark),
              ListTile(
                leading: const Icon(Icons.code_rounded,
                    color: AppColors.primaryOrange, size: 20),
                title: Text('GitHub',
                    style: GoogleFonts.dmSans(color: primaryText)),
                trailing: Icon(Icons.open_in_new_rounded,
                    size: 16, color: secondaryText),
                onTap: () async {
                  final uri = Uri.parse('https://github.com');
                  if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              _Divider(isDark: isDark),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: AppColors.primaryOrange, size: 20),
                title: Text('Datenschutz',
                    style: GoogleFonts.dmSans(color: primaryText)),
                trailing: Icon(Icons.chevron_right_rounded,
                    size: 20, color: secondaryText),
                onTap: () => _showPrivacyDialog(context),
              ),
              _Divider(isDark: isDark),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined,
                    color: AppColors.primaryOrange, size: 20),
                title: Text('Bug melden',
                    style: GoogleFonts.dmSans(color: primaryText)),
                trailing: Icon(Icons.open_in_new_rounded,
                    size: 16, color: secondaryText),
                onTap: () async {
                  final uri = Uri.parse(
                      'mailto:support@clocky.app?subject=Bug%20Report&body=Beschreibe%20den%20Fehler%20hier...');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
            ],
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              'Clocky · Kostenlos & werbefrei · Vollständig offline',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datenschutz'),
        content: Text(
          'Clocky speichert alle Daten ausschließlich lokal auf deinem Gerät. '
          'Es werden keine Daten an Server übertragen, keine Cookies gesetzt '
          'und keine Analyse-Tools verwendet.\n\n'
          'Deine Daten gehören dir.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.primaryOrange,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : Colors.grey.shade200,
      indent: 48,
    );
  }
}

class _LogoTile extends StatelessWidget {
  final SettingsProvider settings;
  final bool isDark;

  const _LogoTile({required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      leading: const Icon(Icons.image_outlined,
          size: 20, color: AppColors.primaryOrange),
      title: Text('Logo',
          style: GoogleFonts.dmSans(color: primaryText, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (settings.logoPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(settings.logoPath),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  size: 24,
                  color: secondaryText,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              size: 20, color: secondaryText),
        ],
      ),
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          await settings.setLogoPath(image.path);
        }
      },
    );
  }
}

class _TextEditTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String hint;
  final bool multiline;
  final Future<void> Function(String) onSave;
  final bool isDark;

  const _TextEditTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.hint,
    this.multiline = false,
    required this.onSave,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.primaryOrange),
      title: Text(title,
          style: GoogleFonts.dmSans(color: primaryText, fontWeight: FontWeight.w500)),
      subtitle: value.isNotEmpty
          ? Text(value,
              style: GoogleFonts.dmSans(color: secondaryText, fontSize: 13))
          : null,
      trailing: Icon(Icons.edit_outlined,
          size: 16, color: secondaryText),
      onTap: () => _showEditDialog(context, primaryText),
    );
  }

  void _showEditDialog(BuildContext context, Color primaryText) {
    final controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: multiline ? 3 : 1,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          style: GoogleFonts.dmSans(color: primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              await onSave(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

class _NumberEditTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final String suffix;
  final Future<void> Function(double) onSave;
  final bool isDark;

  const _NumberEditTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix,
    required this.onSave,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.primaryOrange),
      title: Text(title,
          style: GoogleFonts.dmSans(color: primaryText, fontWeight: FontWeight.w500,)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${value % 1 == 0 ? value.toInt() : value} $suffix',
            style: GoogleFonts.dmSans(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.edit_outlined,
              size: 16, color: secondaryText),
        ],
      ),
      onTap: () {
        final controller = TextEditingController(text: value.toString());
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(suffixText: suffix),
              style: GoogleFonts.dmSans(color: primaryText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () async {
                  final parsed = double.tryParse(controller.text);
                  if (parsed != null) await onSave(parsed);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final String current; // 'system' | 'dark' | 'light'
  final ValueChanged<String> onChanged;

  const _ThemeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppColors.surfaceDark.withOpacity(0.6)
        : Colors.grey.shade200;
    final inactiveTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    const options = [
      ('system', 'System'),
      ('light', 'Hell'),
      ('dark', 'Dunkel'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = current == opt.$1;
          return GestureDetector(
            onTap: () => onChanged(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt.$2,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : inactiveTextColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
