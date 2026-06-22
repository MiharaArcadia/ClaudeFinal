import 'package:carby/models/food_model.dart';

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

  factory FoodLogEntry.fromMap(Map<String, dynamic> m) {
    DateTime timestamp = DateTime.now();
    try {
      if (m['timestamp'] != null) timestamp = DateTime.parse(m['timestamp'] as String);
    } catch (_) {}
    Food food;
    try {
      food = Food.fromMap(m['food'] as Map<String, dynamic>);
    } catch (_) {
      food = Food(id: '', name: 'Unknown', imageUrl: '', brand: '', calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, salt: 0);
    }
    return FoodLogEntry(
      id: m['id'] ?? '',
      food: food,
      grams: (m['grams'] as num?)?.toDouble() ?? 100,
      timestamp: timestamp,
    );
  }
}
