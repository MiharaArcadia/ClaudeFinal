import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carby/layouts/desktop_layout.dart';
import 'package:carby/providers/nutrition_provider.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/food_log_screen.dart';
import 'package:carby/screens/profile_screen.dart';
import 'package:carby/screens/voice_search_screen.dart';
import 'package:carby/theme/app_theme.dart';
import 'package:carby/widgets/calorie_ring_chart.dart';
import 'package:carby/widgets/macro_card.dart';
import 'package:carby/widgets/nutrient_gap_row.dart';
import 'package:carby/widgets/pulsing_mic_button.dart';

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final nutritionProvider = context.read<NutritionProvider>();
      final uid = userProvider.profile?.uid;
      if (uid != null) {
        nutritionProvider.startListening(uid);
      }
    });
  }

  String _greeting(String lang) {
    final h = DateTime.now().hour;
    if (lang == 'de') {
      if (h < 12) return 'Guten Morgen';
      if (h < 17) return 'Guten Tag';
      return 'Guten Abend';
    } else {
      if (h < 12) return 'Good morning';
      if (h < 17) return 'Good afternoon';
      return 'Good evening';
    }
  }

  Widget get _currentPage {
    return switch (_navIndex) {
      1 => const FoodLogScreen(),
      2 => const ProfileScreen(),
      _ => _DashboardBody(greeting: _greeting),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      return DesktopLayout(
        selectedIndex: _navIndex,
        onNavTap: (i) => setState(() => _navIndex = i),
        mainContent: _currentPage,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _DashboardBody(greeting: _greeting),
          const FoodLogScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.donut_large), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Tagebuch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final String Function(String lang) greeting;

  const _DashboardBody({required this.greeting});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final nutrition = context.watch<NutritionProvider>();
    final lang = user?.language ?? 'de';
    final calorieGoal = user?.dailyCalorieGoal ?? 2000;
    final gaps = nutrition.getNutrientGaps(calorieGoal);
    final recommendations = nutrition.getRecommendations(calorieGoal);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greeting(lang)}, ${user?.name ?? ''}!',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _todayString(lang),
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none,
                          color: AppColors.textSecondary, size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // Calorie ring
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CalorieRingChart(
                    eaten: nutrition.totalCalories,
                    goal: calorieGoal.toDouble(),
                    size: 220,
                  ),
                ),
              ),
            ),

            // Macro cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: MacroCard(
                        label: lang == 'de' ? 'Protein' : 'Protein',
                        current: nutrition.totalProtein,
                        target: 50,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MacroCard(
                        label: lang == 'de' ? 'Kohlenhydrate' : 'Carbs',
                        current: nutrition.totalCarbs,
                        target: 260,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MacroCard(
                        label: lang == 'de' ? 'Fett' : 'Fat',
                        current: nutrition.totalFat,
                        target: 65,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nutrient gaps
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  lang == 'de' ? 'Nährstoff-Status' : 'Nutrient status',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: gaps.map((g) => NutrientGapRow(gap: g)).toList(),
                ),
              ),
            ),

            // Recommendations
            if (recommendations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    lang == 'de'
                        ? 'Was du noch essen solltest'
                        : 'What to eat next',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Chip(
                      label: Text(recommendations[i],
                          style: GoogleFonts.inter(
                              color: AppColors.textPrimary, fontSize: 13)),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.orange, width: 1),
                    ),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: PulsingMicButton(
        listening: false,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VoiceSearchScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _todayString(String lang) {
    final now = DateTime.now();
    final months_de = [
      '', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    if (lang == 'de') {
      return '${now.day}. ${months_de[now.month]} ${now.year}';
    } else {
      final months_en = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months_en[now.month]} ${now.day}, ${now.year}';
    }
  }
}
