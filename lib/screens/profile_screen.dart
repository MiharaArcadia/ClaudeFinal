import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutri_voice/models/user_profile.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late double _weight;
  late double _height;
  late int _age;
  late String _goal;
  late String _language;
  late int _calorieGoal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _weight = profile?.weight ?? 70.0;
    _height = profile?.height ?? 175.0;
    _age = profile?.age ?? 25;
    _goal = profile?.goal ?? 'maintain';
    _language = profile?.language ?? 'de';
    _calorieGoal = profile?.dailyCalorieGoal ?? 2000;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _recalculateCalories() {
    _calorieGoal = UserProfile.calculateTDEE(
      weight: _weight,
      height: _height,
      age: _age,
      goal: _goal,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final provider = context.read<UserProvider>();
    final existing = provider.profile;
    if (existing == null) {
      setState(() => _saving = false);
      return;
    }
    final updated = existing.copyWith(
      name: _nameCtrl.text.trim(),
      weight: _weight,
      height: _height,
      age: _age,
      goal: _goal,
      language: _language,
      dailyCalorieGoal: _calorieGoal,
    );
    await provider.updateProfile(updated);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _language == 'de' ? 'Gespeichert!' : 'Saved!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          lang == 'de' ? 'Profil' : 'Profile',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.orange, AppColors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 32),

          // Language switcher
          _SectionLabel(label: lang == 'de' ? 'Sprache' : 'Language'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _LangButton(
                  label: '🇩🇪 Deutsch',
                  selected: _language == 'de',
                  onTap: () => setState(() {
                    _language = 'de';
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LangButton(
                  label: '🇬🇧 English',
                  selected: _language == 'en',
                  onTap: () => setState(() {
                    _language = 'en';
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Name
          _SectionLabel(label: lang == 'de' ? 'Name' : 'Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: lang == 'de' ? 'Dein Name' : 'Your name',
              hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // Age
          _SliderField(
            label: lang == 'de' ? 'Alter' : 'Age',
            value: _age.toDouble(),
            min: 10,
            max: 100,
            divisions: 90,
            unit: lang == 'de' ? 'Jahre' : 'years',
            color: AppColors.teal,
            onChanged: (v) => setState(() {
              _age = v.round();
              _recalculateCalories();
            }),
          ),
          const SizedBox(height: 16),

          // Weight
          _SliderField(
            label: lang == 'de' ? 'Gewicht' : 'Weight',
            value: _weight,
            min: 30,
            max: 200,
            divisions: 170,
            unit: 'kg',
            color: AppColors.blue,
            onChanged: (v) => setState(() {
              _weight = v;
              _recalculateCalories();
            }),
          ),
          const SizedBox(height: 16),

          // Height
          _SliderField(
            label: lang == 'de' ? 'Größe' : 'Height',
            value: _height,
            min: 100,
            max: 220,
            divisions: 120,
            unit: 'cm',
            color: AppColors.purple,
            onChanged: (v) => setState(() {
              _height = v;
              _recalculateCalories();
            }),
          ),
          const SizedBox(height: 24),

          // Goal
          _SectionLabel(label: lang == 'de' ? 'Ziel' : 'Goal'),
          const SizedBox(height: 8),
          Row(
            children: [
              _GoalCard(
                icon: Icons.trending_down,
                label: lang == 'de' ? 'Abnehmen' : 'Lose',
                selected: _goal == 'lose',
                color: AppColors.blue,
                onTap: () => setState(() {
                  _goal = 'lose';
                  _recalculateCalories();
                }),
              ),
              const SizedBox(width: 8),
              _GoalCard(
                icon: Icons.trending_flat,
                label: lang == 'de' ? 'Halten' : 'Maintain',
                selected: _goal == 'maintain',
                color: AppColors.green,
                onTap: () => setState(() {
                  _goal = 'maintain';
                  _recalculateCalories();
                }),
              ),
              const SizedBox(width: 8),
              _GoalCard(
                icon: Icons.trending_up,
                label: lang == 'de' ? 'Zunehmen' : 'Gain',
                selected: _goal == 'gain',
                color: AppColors.orange,
                onTap: () => setState(() {
                  _goal = 'gain';
                  _recalculateCalories();
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Calorie goal preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == 'de' ? 'Tägliches Kalorienziel' : 'Daily calorie goal',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$_calorieGoal kcal',
                  style: GoogleFonts.inter(
                    color: AppColors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      lang == 'de' ? 'Speichern' : 'Save',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text(
                '${value.toInt()} $unit',
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            inactiveColor: AppColors.ringEmpty,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? AppColors.orange : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? color : AppColors.textSecondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: selected ? color : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
