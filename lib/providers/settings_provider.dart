import 'package:flutter/material.dart';
import 'package:clocky/services/database_service.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  String _name = '';
  String _company = '';
  String _address = '';
  String _logoPath = '';
  double _defaultRate = 0.0;
  double _workHoursPerDay = 8.0;
  String _darkMode = 'system'; // 'system' | 'dark' | 'light'

  // ── Getters ─────────────────────────────────────────────────────────────────

  String get name => _name;
  String get company => _company;
  String get address => _address;
  String get logoPath => _logoPath;
  double get defaultRate => _defaultRate;
  double get workHoursPerDay => _workHoursPerDay;
  String get darkMode => _darkMode;

  ThemeMode get themeMode {
    switch (_darkMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  // ── Load ─────────────────────────────────────────────────────────────────────

  Future<void> load() async {
    final all = await _db.getAllSettings();
    _name = all['name'] ?? '';
    _company = all['company'] ?? '';
    _address = all['address'] ?? '';
    _logoPath = all['logo_path'] ?? '';
    _defaultRate = double.tryParse(all['default_rate'] ?? '') ?? 0.0;
    _workHoursPerDay = double.tryParse(all['work_hours_per_day'] ?? '') ?? 8.0;
    _darkMode = all['dark_mode'] ?? 'system';
    notifyListeners();
  }

  // ── Generic update ───────────────────────────────────────────────────────────

  Future<void> update(String key, String value) async {
    await _db.setSetting(key, value);
    // Reload all settings so everything is in sync
    await load();
  }

  // ── Convenience setters ──────────────────────────────────────────────────────

  Future<void> setName(String value) => update('name', value);
  Future<void> setCompany(String value) => update('company', value);
  Future<void> setAddress(String value) => update('address', value);
  Future<void> setLogoPath(String value) => update('logo_path', value);
  Future<void> setDefaultRate(double value) =>
      update('default_rate', value.toString());
  Future<void> setWorkHoursPerDay(double value) =>
      update('work_hours_per_day', value.toString());
  Future<void> setDarkMode(String value) => update('dark_mode', value);
}
