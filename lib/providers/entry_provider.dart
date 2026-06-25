import 'package:flutter/material.dart';
import 'package:clocky/models/entry.dart';
import 'package:clocky/services/database_service.dart';

class EntryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Entry> _entries = [];
  String _currentMonth = _nowMonth();

  List<Entry> get entries => List.unmodifiable(_entries);
  String get currentMonth => _currentMonth;

  static String _nowMonth() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> loadEntries({String? month}) async {
    if (month != null) {
      _currentMonth = month;
    }
    _entries = await _db.getEntries(month: _currentMonth);
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async {
    final id = await _db.insertEntry(entry);
    final newEntry = entry.copyWith(id: id);
    _entries.insert(0, newEntry);
    _sortEntries();
    notifyListeners();
  }

  Future<void> updateEntry(Entry entry) async {
    await _db.updateEntry(entry);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    }
    _sortEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ── Computed ─────────────────────────────────────────────────────────────────

  double getTodayHours() {
    final today = _todayStr();
    return _entries
        .where((e) => e.date == today)
        .fold(0.0, (sum, e) => sum + e.totalHours);
  }

  double getWeekHours() {
    final now = DateTime.now();
    // Monday of current week
    final weekday = now.weekday; // 1=Mon...7=Sun
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final mondayStr = _dateStr(monday);
    final sundayStr = _dateStr(sunday);

    return _entries
        .where((e) => e.date >= mondayStr && e.date <= sundayStr)
        .fold(0.0, (sum, e) => sum + e.totalHours);
  }

  double getTotalHoursForMonth() {
    return _entries.fold(0.0, (sum, e) => sum + e.totalHours);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _sortEntries() {
    _entries.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      return b.startTime.compareTo(a.startTime);
    });
  }

  String _todayStr() {
    final now = DateTime.now();
    return _dateStr(now);
  }

  String _dateStr(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
