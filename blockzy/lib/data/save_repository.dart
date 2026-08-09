/// Persists [PlayerData] to disk via shared_preferences, with schema migration
/// and a pluggable cloud-save hook.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_save_service.dart';
import 'models.dart';

class SaveRepository {
  SaveRepository({CloudSaveService? cloud})
      : _cloud = cloud ?? const NoOpCloudSaveService();

  static const String _key = 'blockzy_player_data_v1';

  final CloudSaveService _cloud;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Loads player data, running migrations and merging any newer cloud copy.
  Future<PlayerData> load() async {
    final prefs = await _p;
    final raw = prefs.getString(_key);
    PlayerData data;
    if (raw == null) {
      data = PlayerData();
    } else {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        data = _migrate(PlayerData.fromJson(json));
      } catch (_) {
        // Corrupt save — start fresh rather than crash.
        data = PlayerData();
      }
    }

    // Cloud is a no-op by default; when enabled this pulls a newer snapshot.
    final cloudCopy = await _cloud.fetch();
    if (cloudCopy != null &&
        cloudCopy.progress.totalXp > data.progress.totalXp) {
      data = cloudCopy;
      await save(data);
    }
    return data;
  }

  /// Persists player data locally and mirrors to the cloud service.
  Future<void> save(PlayerData data) async {
    final prefs = await _p;
    await prefs.setString(_key, jsonEncode(data.toJson()));
    await _cloud.push(data);
  }

  /// Applies forward migrations to reach [PlayerData.currentSaveVersion].
  PlayerData _migrate(PlayerData data) {
    // v1 is the initial schema. Future versions add cases here, e.g.:
    //   if (data.saveVersion < 2) { ...transform...; data.saveVersion = 2; }
    data.saveVersion = PlayerData.currentSaveVersion;
    return data;
  }
}
