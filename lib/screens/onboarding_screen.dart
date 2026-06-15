import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_voice/models/user_profile.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/screens/dashboard_screen.dart';
import 'package:nutri_voice/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  String _lang = 'de';
  String _name = '';
  double _age = 25;
  double _weight = 70;
  double _height = 175;
  String _goal = 'maintain';

  String _s(String key) {
    final de = {
      'welcome': 'Willkommen!',
      'subtitle': 'Lass uns dein Profil einrichten',
      'lang': 'Wähle deine Sprache',
      'name': 'Wie heißt du?',
      'namePlaceholder': 'Dein Name',
      'age': 'Wie alt bist du?',
      'weight': 'Gewicht (kg)',
      'height': 'Größe (cm)',
      'goal': 'Was ist dein Ziel?',
      'lose': 'Abnehmen',
      'maintain': 'Gewicht halten',
      'gain': 'Zunehmen',
      'calorieGoal': 'Dein Kalorienziel',
      'next': 'Weiter',
      'start': 'Loslegen!',
      'years': 'Jahre',
    };
    final en = {
      'welcome': 'Welcome!',
      'subtitle': 'Let\'s set up your profile',
      'lang': 'Choose your language',
      'name': 'What\'s your name?',
      'namePlaceholder': 'Your name',
      'age': 'How old are you?',
      'weight': 'Weight (kg)',
      'height': 'Height (cm)',
      'goal': 'What\'s your goal?',
      'lose': 'Lose weight',
      'maintain': 'Maintain weight',
      'gain': 'Gain weight',
      'calorieGoal': 'Your calorie goal',
      'next': 'Next',
      'start': 'Get started!',
      'years': 'years',
    };
    return (_lang == 'de' ? de : en)[key] ?? key;
  }

  int get _calorieGoal => UserProfile.calculateTDEE(
        weight: _weight,
        height: _height,
        age: _age.toInt(),
        goal: _goal,
      );

  void _next() {
    if (_page < 4) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final profile = UserProfile(
      uid: uid,
      name: _name.isEmpty ? 'User' : _name,
      age: _age.toInt(),
      weight: _weight,
      height: _height,
      goal: _goal,
      language: _lang,
      dailyCalorieGoal: _calorieGoal,
    );
    await context.read<UserProvider>().saveProfile(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(5, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _page
                            ? AppColors.orange
                            : AppColors.ringEmpty,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _buildLanguagePage(),
                  _buildNamePage(),
                  _buildAgePage(),
                  _buildGoalPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_page == 1 && _name.trim().isEmpty) ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor:
                        AppColors.orange.withOpacity(0.3),
                  ),
                  child: Text(
                    _page < 4 ? _s('next') : _s('start'),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(_s('welcome'),
              style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_s('subtitle'),
              style: GoogleFonts.inter(
                  fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          Text(_s('lang'),
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Row(
            children: [
              _langBtn('de', '🇩🇪 Deutsch'),
              const SizedBox(width: 12),
              _langBtn('en', '🇬🇧 English'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    final selected = _lang == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _lang = code),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected ? AppColors.orange.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.orange : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: selected
                    ? AppColors.orange
                    : AppColors.textPrimary,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(_s('name'),
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 30),
          TextField(
            autofocus: true,
            style: GoogleFonts.inter(
                color: AppColors.textPrimary, fontSize: 20),
            decoration: InputDecoration(
              hintText: _s('namePlaceholder'),
              hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (v) => setState(() => _name = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(_s('age'),
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 40),
          _sliderCard(_s('age'), _age, 15, 80, (v) => setState(() => _age = v),
              unit: _s('years'), divisions: 65),
          const SizedBox(height: 16),
          _sliderCard(_s('weight'), _weight, 40, 150,
              (v) => setState(() => _weight = v),
              unit: 'kg'),
          const SizedBox(height: 16),
          _sliderCard(_s('height'), _height, 140, 220,
              (v) => setState(() => _height = v),
              unit: 'cm'),
        ],
      ),
    );
  }

  Widget _sliderCard(String label, double value, double min, double max,
      ValueChanged<double> onChanged,
      {String unit = '', int? divisions}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('${value.toInt()} $unit',
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? (max - min).toInt(),
            activeColor: AppColors.orange,
            inactiveColor: AppColors.ringEmpty,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    final goals = [
      ('lose', _s('lose'), Icons.trending_down, AppColors.teal),
      ('maintain', _s('maintain'), Icons.trending_flat, AppColors.blue),
      ('gain', _s('gain'), Icons.trending_up, AppColors.orange),
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(_s('goal'),
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 30),
          ...goals.map((g) {
            final selected = _goal == g.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _goal = g.$1),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selected
                        ? g.$4.withOpacity(0.15)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? g.$4 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(g.$3, color: g.$4, size: 28),
                      const SizedBox(width: 16),
                      Text(g.$2,
                          style: GoogleFonts.inter(
                            color: selected
                                ? g.$4
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(_s('calorieGoal'),
              style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  '$_calorieGoal',
                  style: GoogleFonts.inter(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.orange, AppColors.pink],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 80)),
                  ),
                ),
                Text('kcal / Tag',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _summaryRow('Name', _name.isEmpty ? '-' : _name),
          _summaryRow('Alter', '${_age.toInt()} Jahre'),
          _summaryRow('Gewicht', '${_weight.toInt()} kg'),
          _summaryRow('Größe', '${_height.toInt()} cm'),
          _summaryRow('Ziel', _s(_goal)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
