import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final lang = profile?.language ?? 'de';

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          lang == 'de' ? 'Profil' : 'Profile',
          style: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.orange, AppColors.pink],
                ),
              ),
              child: Center(
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(profile.name,
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 32),

          // Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _stat(lang == 'de' ? 'Alter' : 'Age',
                    '${profile.age} ${lang == 'de' ? 'Jahre' : 'years'}'),
                _divider(),
                _stat(lang == 'de' ? 'Gewicht' : 'Weight',
                    '${profile.weight.toInt()} kg'),
                _divider(),
                _stat(lang == 'de' ? 'Größe' : 'Height',
                    '${profile.height.toInt()} cm'),
                _divider(),
                _stat(lang == 'de' ? 'Kalorienziel' : 'Calorie goal',
                    '${profile.dailyCalorieGoal} kcal'),
                _divider(),
                _stat(lang == 'de' ? 'Ziel' : 'Goal',
                    _goalLabel(profile.goal, lang)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang == 'de' ? 'Sprache' : 'Language',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _langBtn(context, '🇩🇪 Deutsch', 'de', lang),
                    const SizedBox(width: 12),
                    _langBtn(context, '🇬🇧 English', 'en', lang),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Row(
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
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.ringEmpty),
      );

  Widget _langBtn(
      BuildContext context, String label, String code, String current) {
    final selected = current == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<UserProvider>().updateLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.orange.withOpacity(0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.orange : Colors.transparent,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: selected ? AppColors.orange : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 14,
              )),
        ),
      ),
    );
  }

  String _goalLabel(String goal, String lang) {
    if (lang == 'de') {
      return switch (goal) {
        'lose' => 'Abnehmen',
        'gain' => 'Zunehmen',
        _ => 'Gewicht halten',
      };
    } else {
      return switch (goal) {
        'lose' => 'Lose weight',
        'gain' => 'Gain weight',
        _ => 'Maintain weight',
      };
    }
  }
}
