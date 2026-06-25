import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clocky/models/entry.dart';
import 'package:clocky/providers/entry_provider.dart';

enum TimerState { stopped, running, paused }

class TimerProvider extends ChangeNotifier {
  Timer? _ticker;

  TimerState _state = TimerState.stopped;
  Duration _elapsed = Duration.zero;
  int? _currentProjectId;
  DateTime? _sessionStart;
  int _totalPausedSeconds = 0;
  String? _note;

  // When paused, records when the pause started so we can accumulate
  DateTime? _pauseStart;

  // Today hours set externally (from EntryProvider) for display
  double _todayExistingHours = 0.0;

  // ── Getters ─────────────────────────────────────────────────────────────────

  TimerState get state => _state;
  Duration get elapsed => _elapsed;
  int? get currentProjectId => _currentProjectId;
  DateTime? get sessionStart => _sessionStart;
  int get totalPausedSeconds => _totalPausedSeconds;
  String? get note => _note;
  double get todayExistingHours => _todayExistingHours;

  String get formattedTime {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Setters ──────────────────────────────────────────────────────────────────

  void setProject(int? id) {
    _currentProjectId = id;
    notifyListeners();
  }

  void setNote(String n) {
    _note = n;
    notifyListeners();
  }

  void setTodayExistingHours(double hours) {
    _todayExistingHours = hours;
    notifyListeners();
  }

  // ── Timer control ────────────────────────────────────────────────────────────

  void start(int? projectId) {
    if (_state == TimerState.running) return;

    _currentProjectId = projectId ?? _currentProjectId;

    if (_state == TimerState.stopped) {
      // Fresh start
      _sessionStart = DateTime.now();
      _elapsed = Duration.zero;
      _totalPausedSeconds = 0;
      _pauseStart = null;
    } else if (_state == TimerState.paused) {
      // Resume from pause — accumulate pause time
      if (_pauseStart != null) {
        _totalPausedSeconds +=
            DateTime.now().difference(_pauseStart!).inSeconds;
        _pauseStart = null;
      }
    }

    _state = TimerState.running;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
    _syncWidget();
  }

  void pause() {
    if (_state != TimerState.running) return;
    _state = TimerState.paused;
    _pauseStart = DateTime.now();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
    _syncWidget();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    start(_currentProjectId);
  }

  /// Stops the timer, saves an entry to the database, and returns the saved Entry.
  Future<Entry?> stop(EntryProvider entryProvider) async {
    if (_state == TimerState.stopped) return null;

    _ticker?.cancel();
    _ticker = null;

    final sessionEnd = DateTime.now();
    final sessionStartLocal = _sessionStart ?? sessionEnd;

    _state = TimerState.stopped;

    // If paused when stopped, accumulate final pause duration
    if (_pauseStart != null) {
      _totalPausedSeconds +=
          sessionEnd.difference(_pauseStart!).inSeconds;
      _pauseStart = null;
    }

    // Build entry fields
    final dateStr = _formatDate(sessionStartLocal);
    final startTimeStr = _formatTime(sessionStartLocal);
    final endTimeStr = _formatTime(sessionEnd);
    final pauseMin = (_totalPausedSeconds / 60).round();

    final entry = Entry(
      projectId: _currentProjectId,
      date: dateStr,
      startTime: startTimeStr,
      endTime: endTimeStr,
      pauseMinutes: pauseMin,
      note: _note?.isNotEmpty == true ? _note : null,
      createdAt: sessionEnd.toIso8601String(),
    );

    await entryProvider.addEntry(entry);

    // Reset state
    _elapsed = Duration.zero;
    _sessionStart = null;
    _totalPausedSeconds = 0;
    _note = null;
    // Keep _currentProjectId for convenience

    notifyListeners();
    _syncWidget();
    return entry;
  }

  void _tick() {
    if (_sessionStart == null) return;
    final gross = DateTime.now().difference(_sessionStart!).inSeconds;
    _elapsed = Duration(seconds: (gross - _totalPausedSeconds).clamp(0, gross));
    notifyListeners();
    _syncWidget();
  }

  // ── Widget SharedPreferences sync ────────────────────────────────────────────
  // Keys must match ClockWidget.kt constants (prefix: "flutter.")

  String? _widgetProjectName;

  void setWidgetProjectName(String? name) {
    _widgetProjectName = name;
  }

  Future<void> _syncWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateStr = _state == TimerState.running
          ? 'running'
          : _state == TimerState.paused
              ? 'paused'
              : 'stopped';
      await prefs.setString('clocky_timer_state', stateStr);
      await prefs.setInt('clocky_elapsed_seconds', _elapsed.inSeconds);
      await prefs.setString(
          'clocky_today_hours', _formatHoursLabel(_todayExistingHours + _elapsed.inSeconds / 3600));
      await prefs.setString('clocky_project_name', _widgetProjectName ?? '');
    } catch (_) {}
  }

  String _formatHoursLabel(double totalHours) {
    final h = totalHours.floor();
    final m = ((totalHours - h) * 60).round();
    return '${h}h ${m}m';
  }

  // ── Formatting helpers ───────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
