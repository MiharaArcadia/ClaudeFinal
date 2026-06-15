import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutri_voice/models/food_model.dart';
import 'package:nutri_voice/providers/nutrition_provider.dart';
import 'package:nutri_voice/providers/user_provider.dart';
import 'package:nutri_voice/screens/food_detail_screen.dart';
import 'package:nutri_voice/screens/food_log_screen.dart';
import 'package:nutri_voice/screens/profile_screen.dart';
import 'package:nutri_voice/services/open_food_facts_service.dart';
import 'package:nutri_voice/services/speech_service.dart';
import 'package:nutri_voice/theme/app_theme.dart';
import 'package:nutri_voice/widgets/pulsing_mic_button.dart';

class DesktopLayout extends StatefulWidget {
  final Widget mainContent;
  final int selectedIndex;
  final void Function(int) onNavTap;

  const DesktopLayout({
    super.key,
    required this.mainContent,
    required this.selectedIndex,
    required this.onNavTap,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final SpeechService _speech = SpeechService();
  final OpenFoodFactsService _foodApi = OpenFoodFactsService();
  final TextEditingController _textCtrl = TextEditingController();

  bool _listening = false;
  bool _searching = false;
  String _recognizedText = '';
  List<Food> _results = [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  @override
  void dispose() {
    _speech.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  String get _lang =>
      context.read<UserProvider>().profile?.language ?? 'de';

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stopListening();
      setState(() => _listening = false);
    } else {
      setState(() {
        _listening = true;
        _recognizedText = '';
        _results = [];
        _searched = false;
        _textCtrl.clear();
      });
      await _speech.startListening(
        language: _lang,
        onResult: (words) {
          setState(() => _recognizedText = words);
          _textCtrl.text = words;
        },
        onFinalResult: (words) {
          setState(() {
            _listening = false;
            _recognizedText = words;
          });
          if (words.isNotEmpty) _search(words);
        },
      );
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _searched = false;
      _results = [];
    });
    final results = await _foodApi.searchFood(query.trim(), lang: _lang);
    setState(() {
      _results = results;
      _searching = false;
      _searched = true;
    });
  }

  void _openDetail(Food food) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    final nutrition = context.watch<NutritionProvider>();
    final calorieGoal =
        context.watch<UserProvider>().profile?.dailyCalorieGoal ?? 2000;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── LEFT SIDEBAR ──
          _Sidebar(
            selectedIndex: widget.selectedIndex,
            onNavTap: widget.onNavTap,
            calorieGoal: calorieGoal,
            totalCalories: nutrition.totalCalories,
            lang: lang,
          ),

          // Divider
          const VerticalDivider(
              width: 1, color: AppColors.ringEmpty, thickness: 1),

          // ── MAIN CONTENT ──
          Expanded(child: widget.mainContent),

          // Divider
          const VerticalDivider(
              width: 1, color: AppColors.ringEmpty, thickness: 1),

          // ── RIGHT PANEL: Voice + Log ──
          _RightPanel(
            lang: lang,
            listening: _listening,
            searching: _searching,
            recognizedText: _recognizedText,
            textCtrl: _textCtrl,
            results: _results,
            searched: _searched,
            onMicTap: _toggleListening,
            onSearch: _search,
            onFoodTap: _openDetail,
            nutrition: nutrition,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNavTap;
  final int calorieGoal;
  final double totalCalories;
  final String lang;

  const _Sidebar({
    required this.selectedIndex,
    required this.onNavTap,
    required this.calorieGoal,
    required this.totalCalories,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (calorieGoal - totalCalories).clamp(0.0, calorieGoal.toDouble());
    final pct = (totalCalories / calorieGoal).clamp(0.0, 1.0);

    final items = [
      (Icons.donut_large, lang == 'de' ? 'Dashboard' : 'Dashboard', 0),
      (Icons.list_alt, lang == 'de' ? 'Tagebuch' : 'Food log', 1),
      (Icons.person, lang == 'de' ? 'Profil' : 'Profile', 2),
    ];

    return Container(
      width: 200,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.orange, AppColors.teal],
                  ).createShader(b),
                  child: const Icon(Icons.donut_large,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 10),
                Text('NutriVoice',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [AppColors.orange, AppColors.teal],
                        ).createShader(const Rect.fromLTWH(0, 0, 120, 20)),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Nav items
          ...items.map((item) {
            final selected = selectedIndex == item.$3;
            return GestureDetector(
              onTap: () => onNavTap(item.$3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.orange.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(item.$1,
                        size: 20,
                        color: selected
                            ? AppColors.orange
                            : AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(item.$2,
                        style: GoogleFonts.inter(
                          color: selected
                              ? AppColors.orange
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          // Calorie summary at bottom of sidebar
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'de' ? 'Kalorien heute' : 'Today\'s calories',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalCalories.toInt()} kcal',
                  style: GoogleFonts.inter(
                    color: AppColors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.ringEmpty,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.orange),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == 'de'
                      ? '${remaining.toInt()} kcal verbleibend'
                      : '${remaining.toInt()} kcal remaining',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RIGHT PANEL
// ─────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final String lang;
  final bool listening;
  final bool searching;
  final String recognizedText;
  final TextEditingController textCtrl;
  final List<Food> results;
  final bool searched;
  final VoidCallback onMicTap;
  final void Function(String) onSearch;
  final void Function(Food) onFoodTap;
  final NutritionProvider nutrition;

  const _RightPanel({
    required this.lang,
    required this.listening,
    required this.searching,
    required this.recognizedText,
    required this.textCtrl,
    required this.results,
    required this.searched,
    required this.onMicTap,
    required this.onSearch,
    required this.onFoodTap,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final log = nutrition.log;

    return Container(
      width: 300,
      color: AppColors.surface,
      child: Column(
        children: [
          // Voice section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              lang == 'de' ? 'Lebensmittel hinzufügen' : 'Add food',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Mic button
          PulsingMicButton(
            listening: listening,
            onPressed: onMicTap,
          ),

          const SizedBox(height: 6),
          Text(
            listening
                ? (lang == 'de' ? 'Höre zu...' : 'Listening...')
                : (lang == 'de' ? 'Klicken zum Sprechen' : 'Click to speak'),
            style: GoogleFonts.inter(
              color: listening ? AppColors.orange : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: listening ? FontWeight.w600 : FontWeight.w400,
            ),
          ),

          // Recognized text
          if (recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  '"$recognizedText"',
                  style: GoogleFonts.inter(
                    color: AppColors.orange,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Text input field below mic
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: lang == 'de'
                          ? 'Lebensmittel eingeben...'
                          : 'Type food name...',
                      hintStyle: GoogleFonts.inter(
                          color: AppColors.textSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search,
                            color: AppColors.orange, size: 20),
                        onPressed: () => onSearch(textCtrl.text),
                      ),
                    ),
                    onSubmitted: onSearch,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search results
          if (searching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  color: AppColors.orange, strokeWidth: 2),
            )
          else if (results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final food = results[i];
                  return GestureDetector(
                    onTap: () => onFoodTap(food),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food.name,
                                    style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                if (food.brand.isNotEmpty)
                                  Text(food.brand,
                                      style: GoogleFonts.inter(
                                          color: AppColors.textSecondary,
                                          fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Text('${food.calories.toInt()} kcal',
                              style: GoogleFonts.inter(
                                color: AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              )),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else if (searched && results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                lang == 'de' ? 'Keine Ergebnisse' : 'No results',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            // Today's log summary
            const Divider(color: AppColors.ringEmpty, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'de' ? 'Heute gegessen' : 'Eaten today',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${nutrition.totalCalories.toInt()} kcal',
                    style: GoogleFonts.inter(
                      color: AppColors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: log.isEmpty
                  ? Center(
                      child: Text(
                        lang == 'de'
                            ? 'Noch nichts hinzugefügt'
                            : 'Nothing logged yet',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: log.length,
                      itemBuilder: (_, i) {
                        final entry = log[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.food.name,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text('${entry.grams.toInt()}g',
                                        style: GoogleFonts.inter(
                                            color: AppColors.textSecondary,
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                              Text(
                                '${entry.totalCalories.toInt()} kcal',
                                style: GoogleFonts.inter(
                                  color: AppColors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
