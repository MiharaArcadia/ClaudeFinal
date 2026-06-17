import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/providers/nutrition_provider.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/services/open_food_facts_service.dart';
import 'package:carby/theme/app_theme.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late double _portion;
  final _offService = OpenFoodFactsService();

  @override
  void initState() {
    super.initState();
    _portion = widget.food.defaultPortionGrams ??
        _offService.getDefaultPortionWeight(widget.food.name);
  }

  String get _lang =>
      context.read<UserProvider>().profile?.language ?? 'de';

  String _t(Map<String, String> de, Map<String, String> en) {
    return _lang == 'de' ? de[_lang] ?? de.values.first : en[_lang] ?? en.values.first;
  }

  Future<void> _addToLog() async {
    final nutritionProvider = context.read<NutritionProvider>();
    final uid = context.read<UserProvider>().profile?.uid;
    if (uid == null) return;

    await nutritionProvider.addEntry(uid, widget.food, _portion);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _lang == 'de' ? 'Hinzugefügt!' : 'Added!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final lang = _lang;

    final rows = [
      _NutrientRow(
        label: lang == 'de' ? 'Energie' : 'Energy',
        per100: '${food.calories.toInt()} kcal',
        perPortion: '${food.nutrientPer('calories', _portion).toInt()} kcal',
        color: AppColors.orange,
      ),
      _NutrientRow(
        label: lang == 'de' ? 'Protein' : 'Protein',
        per100: '${food.protein.toStringAsFixed(1)}g',
        perPortion: '${food.nutrientPer('protein', _portion).toStringAsFixed(1)}g',
        color: AppColors.blue,
      ),
      _NutrientRow(
        label: lang == 'de' ? 'Kohlenhydrate' : 'Carbohydrates',
        per100: '${food.carbs.toStringAsFixed(1)}g',
        perPortion: '${food.nutrientPer('carbs', _portion).toStringAsFixed(1)}g',
        color: AppColors.teal,
      ),
      _NutrientRow(
        label: lang == 'de' ? '  davon Zucker' : '  of which sugar',
        per100: '${food.sugar.toStringAsFixed(1)}g',
        perPortion: '${food.nutrientPer('sugar', _portion).toStringAsFixed(1)}g',
        color: AppColors.teal.withOpacity(0.6),
      ),
      _NutrientRow(
        label: lang == 'de' ? 'Fett' : 'Fat',
        per100: '${food.fat.toStringAsFixed(1)}g',
        perPortion: '${food.nutrientPer('fat', _portion).toStringAsFixed(1)}g',
        color: AppColors.pink,
      ),
      _NutrientRow(
        label: lang == 'de' ? 'Ballaststoffe' : 'Fiber',
        per100: '${food.fiber.toStringAsFixed(1)}g',
        perPortion: '${food.nutrientPer('fiber', _portion).toStringAsFixed(1)}g',
        color: AppColors.green,
      ),
      _NutrientRow(
        label: lang == 'de' ? 'Salz' : 'Salt',
        per100: '${food.salt.toStringAsFixed(2)}g',
        perPortion: '${food.nutrientPer('salt', _portion).toStringAsFixed(2)}g',
        color: AppColors.textSecondary,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: food.imageUrl.isNotEmpty
                  ? Image.network(
                      food.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + brand
                  Text(food.name,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      )),
                  if (food.brand.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(food.brand,
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                  const SizedBox(height: 20),

                  // Calorie highlight
                  Row(
                    children: [
                      _InfoChip(
                        label: lang == 'de' ? 'pro 100g' : 'per 100g',
                        value: '${food.calories.toInt()} kcal',
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        label: lang == 'de' ? 'Ø Portion' : 'Avg. portion',
                        value: '${_portion.toInt()}g',
                        color: AppColors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Portion slider
                  Container(
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
                            Text(
                              lang == 'de' ? 'Portionsgröße' : 'Portion size',
                              style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                            Text(
                              '${_portion.toInt()}g',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _portion,
                          min: 10,
                          max: 500,
                          divisions: 49,
                          activeColor: AppColors.orange,
                          inactiveColor: AppColors.ringEmpty,
                          onChanged: (v) => setState(() => _portion = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('10g',
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                            Text('500g',
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            '= ${food.nutrientPer('calories', _portion).toInt()} kcal',
                            style: GoogleFonts.inter(
                              color: AppColors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Nutrition table
                  Text(
                    lang == 'de' ? 'Nährwerttabelle' : 'Nutrition facts',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  '100g',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                              ),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  '${_portion.toInt()}g',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                      color: AppColors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                            height: 1, color: AppColors.ringEmpty),
                        ...rows.asMap().entries.map((e) {
                          final isLast = e.key == rows.length - 1;
                          return Column(
                            children: [
                              e.value,
                              if (!isLast)
                                const Divider(
                                    height: 1,
                                    color: AppColors.ringEmpty,
                                    indent: 16),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _addToLog,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text(
                lang == 'de' ? 'Zum Tagebuch hinzufügen' : 'Add to food log',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.card,
      child: const Center(
        child: Icon(Icons.restaurant_menu,
            color: AppColors.textSecondary, size: 60),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final String per100;
  final String perPortion;
  final Color color;

  const _NutrientRow({
    required this.label,
    required this.per100,
    required this.perPortion,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
          SizedBox(
            width: 90,
            child: Text(per100,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 90,
            child: Text(perPortion,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          Text(label,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
