import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:clocky/models/entry.dart';
import 'package:clocky/models/project.dart';
import 'package:clocky/providers/entry_provider.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/theme/app_theme.dart';
import 'package:clocky/widgets/entry_card.dart';
import 'package:clocky/widgets/month_selector.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntryProvider>().loadEntries();
    });
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

  Map<String, List<Entry>> _groupByDate(List<Entry> entries) {
    final map = <String, List<Entry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.date, () => []).add(e);
    }
    return map;
  }

  String _formatDateHeader(String dateStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(dateStr);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      if (dateStr == today) return 'Heute';
      if (dateStr == yesterday) return 'Gestern';
      return DateFormat('EEEE, d. MMMM', 'de_DE').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entryProvider = context.watch<EntryProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final entries = entryProvider.entries;
    final currentMonth = entryProvider.currentMonth;

    final grouped = _groupByDate(entries);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final totalHours = entryProvider.getTotalHoursForMonth();
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Zeiteinträge',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: MonthSelector(
              month: currentMonth,
              onPrevious: () {
                entryProvider.loadEntries(month: _prevMonth(currentMonth));
              },
              onNext: () {
                entryProvider.loadEntries(month: _nextMonth(currentMonth));
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary bar
          if (entries.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entries.length} Einträge',
                    style: GoogleFonts.dmSans(color: secondaryText, fontSize: 13),
                  ),
                  Text(
                    _formatHours(totalHours),
                    style: GoogleFonts.dmSans(
                      color: AppColors.primaryOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // Entries list
          Expanded(
            child: entries.isEmpty
                ? _buildEmpty(primaryText, secondaryText)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: sortedDates.length,
                    itemBuilder: (ctx, i) {
                      final date = sortedDates[i];
                      final dayEntries = grouped[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateHeader(date),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryText,
                                  ),
                                ),
                                Text(
                                  _formatHours(dayEntries.fold(0.0, (s, e) => s + e.totalHours)),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Entry cards with swipe gestures
                          ...dayEntries.map((entry) {
                            final project = projectProvider.getById(entry.projectId ?? -1);
                            return Dismissible(
                              key: Key('entry_${entry.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                ),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  return await _confirmDelete(context);
                                }
                                // Edit
                                _showEntryForm(context, entry: entry);
                                return false;
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  context.read<EntryProvider>().deleteEntry(entry.id!);
                                }
                              },
                              child: EntryCard(
                                entry: entry,
                                project: project,
                                onTap: () => _showEntryForm(context, entry: entry),
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmpty(Color primaryText, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_rounded,
            size: 64,
            color: AppColors.textSecondaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Einträge',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Starte den Timer oder füge manuell\neinen Eintrag hinzu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Dieser Eintrag wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showEntryForm(BuildContext context, {Entry? entry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _EntryForm(entry: entry),
    );
  }

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}

// ── Entry Form Bottom Sheet ──────────────────────────────────────────────────

class _EntryForm extends StatefulWidget {
  final Entry? entry;

  const _EntryForm({this.entry});

  @override
  State<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  late String _date;
  late String _startTime;
  late String _endTime;
  late int _pauseMinutes;
  int? _projectId;
  late TextEditingController _noteController;
  late TextEditingController _pauseController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final e = widget.entry;
    _date = e?.date ?? DateFormat('yyyy-MM-dd').format(now);
    _startTime = e?.startTime ?? '09:00';
    _endTime = e?.endTime ?? '17:00';
    _pauseMinutes = e?.pauseMinutes ?? 0;
    _projectId = e?.projectId;
    _noteController = TextEditingController(text: e?.note ?? '');
    _pauseController = TextEditingController(text: _pauseMinutes.toString());
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final dt = DateFormat('yyyy-MM-dd').parse(_date);
    final picked = await showDatePicker(
      context: context,
      initialDate: dt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  Future<void> _save() async {
    final entryProvider = context.read<EntryProvider>();
    final pauseMin = int.tryParse(_pauseController.text) ?? 0;

    final entry = Entry(
      id: widget.entry?.id,
      projectId: _projectId,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      pauseMinutes: pauseMin,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: widget.entry?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.entry == null) {
      await entryProvider.addEntry(entry);
    } else {
      await entryProvider.updateEntry(entry);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = context.watch<ProjectProvider>().projects;
    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      color: sheetBg,
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.entry == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 20),

            // Date
            _FormField(
              label: 'Datum',
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark2 : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppColors.primaryOrange),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd.MM.yyyy')
                            .format(DateFormat('yyyy-MM-dd').parse(_date)),
                        style: GoogleFonts.dmSans(color: primaryText, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Project dropdown
            _FormField(
              label: 'Projekt',
              child: DropdownButtonFormField<int?>(
                value: _projectId,
                dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                style: GoogleFonts.dmSans(color: primaryText),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.folder_open_rounded,
                      size: 18, color: AppColors.primaryOrange),
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Kein Projekt',
                        style: GoogleFonts.dmSans(color: secondaryText)),
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
                        Text(p.name, style: GoogleFonts.dmSans(color: primaryText)),
                      ],
                    ),
                  )),
                ],
                onChanged: (v) => setState(() => _projectId = v),
              ),
            ),

            const SizedBox(height: 12),

            // Start / End times
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Beginn',
                    child: GestureDetector(
                      onTap: () => _pickTime(true),
                      child: _TimeDisplay(time: _startTime, isDark: isDark),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Ende',
                    child: GestureDetector(
                      onTap: () => _pickTime(false),
                      child: _TimeDisplay(time: _endTime, isDark: isDark),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pause
            _FormField(
              label: 'Pause (Minuten)',
              child: TextFormField(
                controller: _pauseController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.dmSans(color: primaryText),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.pause_circle_outline_rounded,
                      size: 18, color: AppColors.primaryOrange),
                  hintText: '0',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Note
            _FormField(
              label: 'Notiz (optional)',
              child: TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: GoogleFonts.dmSans(color: primaryText),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notes_rounded,
                      size: 18, color: AppColors.primaryOrange),
                  hintText: 'Was hast du gearbeitet?',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.entry == null ? 'Eintrag speichern' : 'Änderungen speichern',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            if (widget.entry != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eintrag löschen?'),
                        content:
                            const Text('Dieser Eintrag wird unwiderruflich gelöscht.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Löschen',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      await context
                          .read<EntryProvider>()
                          .deleteEntry(widget.entry!.id!);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(
                    'Eintrag löschen',
                    style: GoogleFonts.dmSans(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String time;
  final bool isDark;

  const _TimeDisplay({required this.time, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark2 : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.dmSans(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
