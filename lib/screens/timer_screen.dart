import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:clocky/providers/timer_provider.dart';
import 'package:clocky/providers/entry_provider.dart';
import 'package:clocky/providers/project_provider.dart';
import 'package:clocky/providers/settings_provider.dart';
import 'package:clocky/theme/app_theme.dart';
import 'package:clocky/widgets/time_ring.dart';
import 'package:clocky/widgets/stat_card.dart';
import 'package:clocky/widgets/project_chip.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _noteExpanded = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  String _formattedDate() {
    return DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(DateTime.now());
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
    final timerProvider = context.watch<TimerProvider>();
    final entryProvider = context.watch<EntryProvider>();
    final settings = context.watch<SettingsProvider>();

    final workSeconds = settings.workHoursPerDay * 3600;
    final progress = workSeconds > 0
        ? timerProvider.elapsed.inSeconds / workSeconds
        : 0.0;

    final todayHours = entryProvider.getTodayHours() +
        (timerProvider.state != TimerState.stopped
            ? timerProvider.elapsed.inSeconds / 3600
            : 0);
    final weekHours = entryProvider.getWeekHours() +
        (timerProvider.state != TimerState.stopped
            ? timerProvider.elapsed.inSeconds / 3600
            : 0);

    final primaryText = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryText = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '${_greeting()}${settings.name.isNotEmpty ? ', ${settings.name.split(' ').first}' : ''}',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formattedDate(),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: secondaryText,
                ),
              ),

              const SizedBox(height: 32),

              // Timer Ring
              Center(
                child: TimeRing(
                  progress: progress,
                  timeString: timerProvider.formattedTime,
                  color: timerProvider.state == TimerState.paused
                      ? secondaryText
                      : AppColors.primaryOrange,
                  size: 280,
                ),
              ),

              const SizedBox(height: 28),

              // Project Chip
              Center(
                child: ProjectChip(
                  selectedProjectId: timerProvider.currentProjectId,
                  onChanged: (id) {
                    context.read<TimerProvider>().setProject(id);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Stat Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Heute',
                      value: _formatHours(todayHours),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Diese Woche',
                      value: _formatHours(weekHours),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Note section (collapsible)
              _buildNoteSection(context, timerProvider, isDark, secondaryText),

              const SizedBox(height: 24),

              // Timer controls
              _buildControls(context, timerProvider, entryProvider),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection(
    BuildContext context,
    TimerProvider timerProvider,
    bool isDark,
    Color secondaryText,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _noteExpanded = !_noteExpanded),
          child: Row(
            children: [
              Icon(
                _noteExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 4),
              Text(
                _noteExpanded ? 'Notiz ausblenden' : 'Notiz hinzufügen',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (_noteExpanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            onChanged: (v) => timerProvider.setNote(v),
            maxLines: 2,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Was hast du gearbeitet?',
              hintStyle: GoogleFonts.dmSans(color: secondaryText),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    TimerProvider timerProvider,
    EntryProvider entryProvider,
  ) {
    final state = timerProvider.state;

    if (state == TimerState.stopped) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            timerProvider.start(timerProvider.currentProjectId);
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: Text(
            'Timer starten',
            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (state == TimerState.running) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => timerProvider.pause(),
              icon: const Icon(Icons.pause_rounded, size: 20),
              label: Text(
                'Pause',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleStop(context, timerProvider, entryProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              icon: const Icon(Icons.stop_rounded, size: 20),
              label: Text(
                'Stopp',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    // Paused
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => timerProvider.resume(),
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              'Fortsetzen',
              style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleStop(context, timerProvider, entryProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            icon: const Icon(Icons.stop_rounded, size: 20),
            label: Text(
              'Stopp',
              style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleStop(
    BuildContext context,
    TimerProvider timerProvider,
    EntryProvider entryProvider,
  ) async {
    final entry = await timerProvider.stop(entryProvider);
    _noteController.clear();
    if (entry != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Eintrag gespeichert: ${entry.formattedDuration}',
            style: GoogleFonts.dmSans(),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
