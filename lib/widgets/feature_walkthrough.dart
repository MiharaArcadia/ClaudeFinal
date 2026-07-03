import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carby/theme/app_theme.dart';

const _prefKey = 'walkthrough_shown';

Future<bool> shouldShowWalkthrough() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_prefKey) ?? false);
}

Future<void> markWalkthroughShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefKey, true);
}

Future<void> showFeatureWalkthrough(BuildContext context, String lang) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    builder: (_) => _WalkthroughDialog(lang: lang),
  );
  await markWalkthroughShown();
}

class _WalkthroughDialog extends StatefulWidget {
  final String lang;
  const _WalkthroughDialog({required this.lang});

  @override
  State<_WalkthroughDialog> createState() => _WalkthroughDialogState();
}

class _WalkthroughDialogState extends State<_WalkthroughDialog>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _anim;
  late Animation<double> _fade;

  late final List<_Step> _steps;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();

    final de = widget.lang == 'de';
    _steps = [
      _Step(
        icon: Icons.donut_large_rounded,
        color: AppColors.orange,
        title: de ? 'Dein Kalorienring' : 'Your Calorie Ring',
        body: de
            ? 'Der animierte Ring zeigt dir auf einen Blick wie viel von deinem Tagesziel du schon erreicht hast.'
            : 'The animated ring shows you at a glance how much of your daily goal you have already reached.',
      ),
      _Step(
        icon: Icons.mic_rounded,
        color: AppColors.teal,
        title: de ? 'Spracheingabe' : 'Voice Input',
        body: de
            ? 'Tippe auf das Mikrofon-Symbol und sage einfach was du gegessen hast — Carby sucht es automatisch.'
            : 'Tap the microphone icon and say what you ate — Carby searches it automatically.',
      ),
      _Step(
        icon: Icons.book_rounded,
        color: AppColors.purple,
        title: de ? 'Dein Tagebuch' : 'Your Food Log',
        body: de
            ? 'Im Tagebuch-Tab siehst du alle Mahlzeiten des Tages und kannst Einträge löschen oder bearbeiten.'
            : 'In the food log tab you can see all meals of the day and delete or edit entries.',
      ),
    ];
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _next() async {
    if (_step < _steps.length - 1) {
      await _anim.reverse();
      setState(() => _step++);
      _anim.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _skip() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final de = widget.lang == 'de';
    final s = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: s.color.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _step ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _step
                            ? s.color
                            : AppColors.ringEmpty,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.icon, color: s.color, size: 34),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  s.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                // Body
                Text(
                  s.body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          de ? 'Überspringen' : 'Skip',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: s.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isLast
                            ? (de ? 'Los geht\'s! 🚀' : 'Let\'s go! 🚀')
                            : (de ? 'Weiter' : 'Next'),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}
