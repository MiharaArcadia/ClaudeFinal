import 'package:nutri_voice/models/food_model.dart';

class FoodLogEntry {
  final String id;
  final Food food;
  final double grams;
  final DateTime timestamp;

  const FoodLogEntry({
    required this.id,
    required this.food,
    required this.grams,
    required this.timestamp,
  });

  double get totalCalories => food.nutrientPer('calories', grams);
  double get totalProtein => food.nutrientPer('protein', grams);
  double get totalCarbs => food.nutrientPer('carbs', grams);
  double get totalFat => food.nutrientPer('fat', grams);
  double get totalFiber => food.nutrientPer('fiber', grams);
  double get totalSugar => food.nutrientPer('sugar', grams);
  double get totalSalt => food.nutrientPer('salt', grams);

  Map<String, dynamic> toMap() => {
        'id': id,
        'food': food.toMap(),
        'grams': grams,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FoodLogEntry.fromMap(Map<String, dynamic> m) => FoodLogEntry(
        id: m['id'] ?? '',
        food: Food.fromMap(m['food'] as Map<String, dynamic>),
        grams: (m['grams'] as num?)?.toDouble() ?? 100,
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
}
