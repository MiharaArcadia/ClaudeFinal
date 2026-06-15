class Food {
  final String id;
  final String name;
  final String imageUrl;
  final String brand;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double salt;
  final double? defaultPortionGrams;

  const Food({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.salt,
    this.defaultPortionGrams,
  });

  factory Food.fromOpenFoodFacts(Map<String, dynamic> json) {
    final n = (json['nutriments'] as Map<String, dynamic>?) ?? {};
    double _d(String key) {
      final v = n[key];
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Food(
      id: json['_id']?.toString() ?? '',
      name: json['product_name']?.toString() ?? 'Unbekannt',
      imageUrl: json['image_url']?.toString() ?? '',
      brand: json['brands']?.toString() ?? '',
      calories: _d('energy-kcal_100g'),
      protein: _d('proteins_100g'),
      carbs: _d('carbohydrates_100g'),
      fat: _d('fat_100g'),
      fiber: _d('fiber_100g'),
      sugar: _d('sugars_100g'),
      salt: _d('salt_100g'),
      defaultPortionGrams: _parseServing(json['serving_size']?.toString()),
    );
  }

  static double? _parseServing(String? s) {
    if (s == null || s.isEmpty) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(s);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  double nutrientPer(String key, double grams) {
    final per100 = switch (key) {
      'calories' => calories,
      'protein' => protein,
      'carbs' => carbs,
      'fat' => fat,
      'fiber' => fiber,
      'sugar' => sugar,
      'salt' => salt,
      _ => 0.0,
    };
    return per100 * grams / 100;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'brand': brand,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'salt': salt,
        'defaultPortionGrams': defaultPortionGrams,
      };

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        imageUrl: m['imageUrl'] ?? '',
        brand: m['brand'] ?? '',
        calories: (m['calories'] as num?)?.toDouble() ?? 0,
        protein: (m['protein'] as num?)?.toDouble() ?? 0,
        carbs: (m['carbs'] as num?)?.toDouble() ?? 0,
        fat: (m['fat'] as num?)?.toDouble() ?? 0,
        fiber: (m['fiber'] as num?)?.toDouble() ?? 0,
        sugar: (m['sugar'] as num?)?.toDouble() ?? 0,
        salt: (m['salt'] as num?)?.toDouble() ?? 0,
        defaultPortionGrams: (m['defaultPortionGrams'] as num?)?.toDouble(),
      );
}
