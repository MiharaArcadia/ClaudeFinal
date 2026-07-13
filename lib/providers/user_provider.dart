import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carby/models/user_profile.dart';
import 'package:carby/services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
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
    return switch (_profile?.themeMode ?? 'system') {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!_firebase.isSignedIn) {
      await _firebase.signInAnonymously();
    }

    final uid = _firebase.currentUid;
    if (uid != null && _onboardingComplete) {
      _profile = await _firebase.getUserProfile(uid);
    }

    // Apply locally-stored theme even if Firebase profile is unavailable
    if (_profile != null) {
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null && savedTheme != (_profile!.themeMode ?? 'system')) {
        _profile = _profile!.copyWith(themeMode: savedTheme);
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _firebase.saveUserProfile(profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    _onboardingComplete = true;
    notifyListeners();
  }

  Future<void> updateLanguage(String lang) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(language: lang);
    await _firebase.saveUserProfile(_profile!);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    notifyListeners();
    _firebase.saveUserProfile(updated).catchError((_) {});
  }

  Future<void> updateThemeMode(String mode) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(themeMode: mode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
    _firebase.saveUserProfile(_profile!).catchError((_) {});
  }
}
