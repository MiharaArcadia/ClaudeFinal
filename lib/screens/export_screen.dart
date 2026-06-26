import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:clocky/models/entry.dart';
import 'package:clocky/models/project.dart';
import 'package:clocky/providers/entry_provider.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/providers/settings_provider.dart';
import 'package:clocky/services/database_service.dart';
import 'package:clocky/services/export_service.dart';
import 'package:clocky/theme/app_theme.dart';
import 'package:clocky/widgets/month_selector.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _month = _nowMonth();
  int? _selectedProjectId; // null = all projects
  bool _isLoadingPdf = false;
  bool _isLoadingCsv = false;
  bool _isLoadingEmail = false;

  List<Entry> _entries = [];
  bool _entriesLoaded = false;

  static String _nowMonth() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseService.instance.getEntries(month: _month);
    if (mounted) {
      setState(() {
        _entries = entries;
        _entriesLoaded = true;
      });
    }
  }

  String _prevMonth(String month) {
    final dt = DateFormat('yyyy-MM').parse(month);
    final prev = DateTime(dt.year, dt.month - 1);
    return DateFormat('yyyy-MM').format(prev);
  }

  String _nextMonth(String month) {
    final dt = DateFormat('yyyy-MM').parse(month);
    final next = DateTime(dt.year, dt.month + 1);
    return DateFormat('yyyy-MM').format(next);
  }

  List<Entry> get _filteredEntries {
    if (_selectedProjectId == null) return _entries;
    return _entries.where((e) => e.projectId == _selectedProjectId).toList();
  }

  double get _totalHours =>
      _filteredEntries.fold(0.0, (s, e) => s + e.totalHours);

  double _totalEarnings(List<Project> projects) {
    final projectMap = {for (final p in projects) p.id: p};
    return _filteredEntries.fold(0.0, (s, e) {
      final p = projectMap[e.projectId];
      return s + e.totalHours * (p?.hourlyRate ?? 0);
    });
  }

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = context.watch<ProjectProvider>().projects;
    final settings = context.watch<SettingsProvider>();
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight;

    final earnings = _totalEarnings(projects);
    final filtered = _filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: MonthSelector(
              month: _month,
              onPrevious: () {
                setState(() {
                  _month = _prevMonth(_month);
                  _entriesLoaded = false;
                });
                _loadEntries();
              },
              onNext: () {
                setState(() {
                  _month = _nextMonth(_month);
                  _entriesLoaded = false;
                });
                _loadEntries();
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project filter
            if (projects.isNotEmpty) ...[
              Text(
                'Projekt filtern',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int?>(
                value: _selectedProjectId,
                dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                style: GoogleFonts.dmSans(color: primaryText),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.filter_list_rounded,
                      size: 18, color: AppColors.primaryOrange),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Alle Projekte',
                        style: GoogleFonts.dmSans(color: primaryText)),
                  ),
                  ...projects.map((p) => DropdownMenuItem<int?>(
                    value: p.id,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.colorValue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(p.name,
                            style: GoogleFonts.dmSans(color: primaryText)),
                      ],
                    ),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedProjectId = v),
              ),
              const SizedBox(height: 20),
            ],

            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stunden gesamt',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _entriesLoaded ? _formatHours(_totalHours) : '–',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${filtered.length} Einträge',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Betrag gesamt',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _entriesLoaded
                                ? NumberFormat.currency(
                                        locale: 'de_DE', symbol: '€')
                                    .format(earnings)
                                : '–',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Export buttons
            Text(
              'Exportieren',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryText,
              ),
            ),
            const SizedBox(height: 12),

            // PDF
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: filtered.isEmpty || _isLoadingPdf
                    ? null
                    : () => _exportPdf(projects, settings),
                icon: _isLoadingPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: Text(
                  'PDF Stundenzettel generieren',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // CSV
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: filtered.isEmpty || _isLoadingCsv
                    ? null
                    : () => _exportCsv(projects),
                icon: _isLoadingCsv
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : const Icon(Icons.table_chart_outlined, size: 20),
                label: Text(
                  'CSV exportieren',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Email
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: filtered.isEmpty || _isLoadingEmail
                    ? null
                    : () => _sendEmail(projects, settings),
                icon: _isLoadingEmail
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : const Icon(Icons.email_outlined, size: 20),
                label: Text(
                  'Per E-Mail senden',
                  style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            if (filtered.isEmpty && _entriesLoaded) ...[
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Keine Einträge für diesen Monat.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(List<Project> projects, SettingsProvider settings) async {
    setState(() => _isLoadingPdf = true);
    try {
      final settingsMap = await DatabaseService.instance.getAllSettings();
      final bytes = await ExportService.instance.generatePdf(
        _filteredEntries,
        projects,
        settingsMap,
        _month,
      );
      final filename = 'Stundenzettel_${_month.replaceAll('-', '_')}.pdf';
      await ExportService.instance.saveToDownloads(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$filename gespeichert'),
            action: SnackBarAction(
              label: 'Teilen',
              onPressed: () => ExportService.instance.shareFile(
                bytes,
                filename,
                'application/pdf',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPdf = false);
    }
  }

  Future<void> _exportCsv(List<Project> projects) async {
    setState(() => _isLoadingCsv = true);
    try {
      final csvString = await ExportService.instance.generateCsv(
        _filteredEntries,
        projects,
      );
      final bytes = Uint8List.fromList(csvString.codeUnits);
      final filename = 'Zeiten_${_month.replaceAll('-', '_')}.csv';
      await ExportService.instance.saveToDownloads(bytes, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$filename gespeichert'),
            action: SnackBarAction(
              label: 'Teilen',
              onPressed: () => ExportService.instance.shareFile(
                bytes,
                filename,
                'text/csv',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCsv = false);
    }
  }

  Future<void> _sendEmail(List<Project> projects, SettingsProvider settings) async {
    setState(() => _isLoadingEmail = true);
    try {
      final settingsMap = await DatabaseService.instance.getAllSettings();
      final bytes = await ExportService.instance.generatePdf(
        _filteredEntries,
        projects,
        settingsMap,
        _month,
      );

      final monthLabel = DateFormat('MMMM yyyy', 'de_DE').format(
        DateFormat('yyyy-MM').parse(_month),
      );
      final subject = 'Stundenzettel $monthLabel';
      final body = 'Anbei der Stundenzettel für $monthLabel.\n\n'
          'Stunden gesamt: ${_formatHours(_totalHours)}\n\n'
          'Mit freundlichen Grüßen\n${settings.name}';

      // Try to get client email from first project in filtered entries
      String? clientEmail;
      if (_selectedProjectId != null) {
        final p = projects.cast<Project?>().firstWhere(
              (p) => p?.id == _selectedProjectId,
              orElse: () => null,
            );
        clientEmail = p?.clientEmail;
      }

      await ExportService.instance.sendEmail(
        clientEmail,
        subject,
        body,
        bytes,
        'Stundenzettel_${_month.replaceAll('-', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }
}
