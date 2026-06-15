class NutrientGap {
  final String key;
  final String name;
  final double current;
  final double target;
  final String unit;
  final List<String> foodSuggestions;

  const NutrientGap({
    required this.key,
    required this.name,
    required this.current,
    required this.target,
    required this.unit,
    required this.foodSuggestions,
  });

  double get percentage => (current / target).clamp(0.0, 1.0);
  double get gap => (target - current).clamp(0.0, double.infinity);
  bool get isMet => current >= target;
}

// Recommended daily values
class RDA {
  static const protein = 50.0;    // g
  static const carbs = 260.0;     // g
  static const fat = 65.0;        // g
  static const fiber = 25.0;      // g
  static const sugar = 50.0;      // g max
  static const salt = 6.0;        // g max

  static const Map<String, List<String>> suggestions = {
    'protein': ['Hähnchenbrust', 'Eier', 'Lachs', 'Linsen', 'Tofu', 'Quark'],
    'carbs': ['Haferflocken', 'Vollkornbrot', 'Süßkartoffeln', 'Quinoa', 'Reis'],
    'fat': ['Avocado', 'Nüsse', 'Olivenöl', 'Lachs', 'Mandeln'],
    'fiber': ['Äpfel', 'Brokkoli', 'Linsen', 'Vollkornbrot', 'Chiasamen', 'Haferflocken'],
  };
}
