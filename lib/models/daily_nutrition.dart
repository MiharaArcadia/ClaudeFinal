import 'package:carby/models/food_log_entry.dart';
import 'package:carby/models/nutrient_gap.dart';

class DailyNutrition {
  final List<FoodLogEntry> entries;

  const DailyNutrition(this.entries);

  double get totalCalories => entries.fold(0, (s, e) => s + e.totalCalories);
  double get totalProtein => entries.fold(0, (s, e) => s + e.totalProtein);
  double get totalCarbs => entries.fold(0, (s, e) => s + e.totalCarbs);
  double get totalFat => entries.fold(0, (s, e) => s + e.totalFat);
  double get totalFiber => entries.fold(0, (s, e) => s + e.totalFiber);
  double get totalSugar => entries.fold(0, (s, e) => s + e.totalSugar);
  double get totalSalt => entries.fold(0, (s, e) => s + e.totalSalt);

  List<NutrientGap> getNutrientGaps(int dailyCalorieGoal) {
    return [
      NutrientGap(
        key: 'protein',
        name: 'Protein',
        current: totalProtein,
        target: RDA.protein,
        unit: 'g',
        foodSuggestions: RDA.suggestions['protein']!,
      ),
      NutrientGap(
        key: 'carbs',
        name: 'Kohlenhydrate',
        current: totalCarbs,
        target: RDA.carbs,
        unit: 'g',
        foodSuggestions: RDA.suggestions['carbs']!,
      ),
      NutrientGap(
        key: 'fat',
        name: 'Fett',
        current: totalFat,
        target: RDA.fat,
        unit: 'g',
        foodSuggestions: RDA.suggestions['fat']!,
      ),
      NutrientGap(
        key: 'fiber',
        name: 'Ballaststoffe',
        current: totalFiber,
        target: RDA.fiber,
        unit: 'g',
        foodSuggestions: RDA.suggestions['fiber']!,
      ),
    ];
  }
}
