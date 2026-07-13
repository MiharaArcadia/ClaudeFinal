import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carby/models/user_profile.dart';
import 'package:carby/services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  static const _profileKey = 'user_profile';

  final FirebaseService _firebase;
  UserProfile? _profile;
  bool _loading = true;
  bool _onboardingComplete = false;

  UserProvider(this._firebase);

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  bool get onboardingComplete => _onboardingComplete;
  String get lang => _profile?.language ?? 'de';
  ThemeMode get themeMode {
    return switch (_profile?.themeMode ?? 'dark') {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Persist the profile locally so it survives restarts without Firebase.
  Future<void> _saveLocal(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    // 1) Load the locally-cached profile first — works fully offline / without Firebase.
    final localJson = prefs.getString(_profileKey);
    if (localJson != null) {
      try {
        _profile =
            UserProfile.fromMap(jsonDecode(localJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    if (!_firebase.isSignedIn) {
      await _firebase.signInAnonymously();
    }

    // 2) If Firebase is reachable, prefer the cloud copy (multi-device sync)
    //    and refresh the local cache with it.
    final uid = _firebase.currentUid;
    if (uid != null && _onboardingComplete) {
      final remote = await _firebase.getUserProfile(uid);
      if (remote != null) {
        _profile = remote;
        await _saveLocal(remote);
      }
    }

    // 3) Apply the locally-stored theme choice on top.
    if (_profile != null) {
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null && savedTheme != _profile!.themeMode) {
        _profile = _profile!.copyWith(themeMode: savedTheme);
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
    await prefs.setBool('onboarding_complete', true);
    _onboardingComplete = true;
    notifyListeners();
    // Cloud sync in the background — never blocks or breaks local save.
    _firebase.saveUserProfile(profile).catchError((_) {});
  }

  Future<void> updateLanguage(String lang) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(language: lang);
    notifyListeners();
    await _saveLocal(_profile!);
    _firebase.saveUserProfile(_profile!).catchError((_) {});
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    notifyListeners();
    await _saveLocal(updated);
    _firebase.saveUserProfile(updated).catchError((_) {});
  }

  Future<void> updateThemeMode(String mode) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(themeMode: mode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
    await prefs.setString(_profileKey, jsonEncode(_profile!.toMap()));
    _firebase.saveUserProfile(_profile!).catchError((_) {});
  }
}
