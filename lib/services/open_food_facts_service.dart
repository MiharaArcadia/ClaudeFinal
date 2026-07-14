import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carby/data/common_foods.dart';
import 'package:carby/models/food_model.dart';

class OpenFoodFactsService {
  static const _base = 'https://world.openfoodfacts.org';
  static const _fields =
      'product_name,nutriments,image_url,serving_size,brands,_id,nova_group,categories_tags';

  // Words that indicate a processed / compound product (DE + EN).
  static const _processedKeywords = [
    'chips', 'sticks', 'snack', 'riegel', 'sauce', 'soße', 'frikassee',
    'gewürz', 'würz', 'pulver', 'getrocknet', 'mix', 'fertig', 'paste',
    'aufstrich', 'konserve', 'creme', 'crème', 'gebacken', 'paniert',
    'nuggets', 'wurst', 'aufschnitt', 'dip', 'dressing', 'marinade',
    'geräuchert', 'smoked', 'fried', 'roasted', 'seasoned', 'flavour',
    'flavor',
  ];

  // Substrings that indicate a composed dish rather than a raw ingredient.
  static const _compositionMarkers = [' mit ', ' and ', ' & ', '+'];

  static const _rawCategoryTags = [
    'en:vegetables', 'en:fruits', 'en:fresh-', 'en:meats', 'en:fresh-meat',
    'en:eggs',
  ];

  static const _processedCategoryTags = [
    'en:snacks', 'en:chips', 'en:prepared-meals', 'en:desserts',
    'en:sweet-snacks',
  ];

  Future<List<Food>> searchFood(String query, {String lang = 'de'}) async {
    // 1) Curated German DB first — always clean, instant, works offline.
    final local = CommonFoods.search(query);
    // 2) API for the long tail / specific brands.
    final api = await _fetch(query);

    final seen = local.map((f) => _norm(f.name)).toSet();
    final merged = <Food>[
      ...local,
      ...api.where((f) => !seen.contains(_norm(f.name))),
    ];
    return merged;
  }

  static String _norm(String s) => s.toLowerCase().trim();

  Future<List<Food>> _fetch(String query) async {
    final uri = Uri.parse('$_base/cgi/search.pl').replace(queryParameters: {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'fields': _fields,
      'page_size': '50',
      'sort_by': 'unique_scans_n', // best-known products first
      'lc': 'de', // bias toward German product data
    });

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (data['products'] as List?) ?? [];

      // Rank on the raw JSON (needs nova_group / categories_tags), then map.
      final ranked = products
          .whereType<Map<String, dynamic>>()
          .where((p) =>
              (p['product_name']?.toString() ?? '').trim().isNotEmpty)
          .toList()
        ..sort((a, b) =>
            _scoreProduct(b, query).compareTo(_scoreProduct(a, query)));

      return ranked.map((p) => Food.fromOpenFoodFacts(p)).toList();
    } catch (_) {
      return [];
    }
  }

  static int? _toInt(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  // Split on any non-alphanumeric char so hyphen/compound names ("Coca-Cola",
  // "TK-Pizza") break into real words.
  static List<String> _words(String s) =>
      s.split(RegExp(r'[^a-z0-9äöüß]+')).where((w) => w.isNotEmpty).toList();

  /// Higher score = closer to the pure/raw product the user likely wants.
  int _scoreProduct(Map<String, dynamic> product, String query) {
    final name = (product['product_name']?.toString() ?? '').toLowerCase();
    final q = query.toLowerCase().trim();
    var score = 0;

    // --- Name match ---
    final nameWords = _words(name);
    if (name == q) {
      score += 100;
    } else {
      if (nameWords.contains(q)) score += 40;
      if (name.startsWith(q)) score += 25;
      if (name.contains(q)) score += 10;
      // Multi-word query (e.g. "energy drink", "rote bete"): all query words present.
      final queryWords = _words(q);
      if (queryWords.length > 1 &&
          queryWords.every((w) => nameWords.contains(w))) {
        score += 30;
      }
    }
    final wordCount = nameWords.length;
    score += (6 - wordCount).clamp(0, 6) * 4; // fewer words = purer
    if (name.length <= 15) score += 8;

    // --- Processing level (NOVA) — strongest signal ---
    // OFF sometimes returns nova_group as a String ("1"); parse both.
    final nova = _toInt(product['nova_group']);
    score += switch (nova) {
      1 => 35,
      2 => 10,
      3 => -10,
      4 => -30,
      _ => 0,
    };

    // --- Processed / compound name penalties ---
    for (final kw in _processedKeywords) {
      if (name.contains(kw)) score -= 25;
    }
    for (final marker in _compositionMarkers) {
      if (name.contains(marker)) score -= 15;
    }

    // --- Category signals ---
    final tags = ((product['categories_tags'] as List?) ?? [])
        .map((t) => t.toString().toLowerCase())
        .toList();
    if (tags.any((t) => _rawCategoryTags.any((r) => t.startsWith(r)))) {
      score += 20;
    }
    if (tags.any((t) => _processedCategoryTags.contains(t))) {
      score -= 20;
    }

    // --- Data-quality tie-breakers ---
    if ((product['image_url']?.toString() ?? '').isNotEmpty) score += 3;
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};
    if (((nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 0) > 0) {
      score += 3;
    }
    if ((product['brands']?.toString() ?? '').trim().isNotEmpty) score -= 5;

    return score;
  }

  Future<Food?> lookupBarcode(String barcode) async {
    final uri = Uri.parse('$_base/api/v0/product/$barcode.json')
        .replace(queryParameters: {'fields': _fields});
    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      final food = Food.fromOpenFoodFacts(product);
      if (food.name.isEmpty) return null;
      return food;
    } catch (_) {
      return null;
    }
  }

  double getDefaultPortionWeight(String foodName) {
    final name = foodName.toLowerCase();
    final portions = {
      'apfel': 182.0, 'apple': 182.0,
      'banane': 120.0, 'banana': 120.0,
      'orange': 130.0,
      'ei': 60.0, 'egg': 60.0,
      'brot': 30.0, 'bread': 30.0,
      'toast': 25.0,
      'hähnchen': 150.0, 'chicken': 150.0,
      'lachs': 150.0, 'salmon': 150.0,
      'kartoffel': 150.0, 'potato': 150.0,
      'tomate': 100.0, 'tomato': 100.0,
      'gurke': 200.0, 'cucumber': 200.0,
      'avocado': 150.0,
      'mandel': 28.0, 'almond': 28.0,
      'joghurt': 150.0, 'yogurt': 150.0,
      'milch': 240.0, 'milk': 240.0,
      'käse': 30.0, 'cheese': 30.0,
      'butter': 10.0,
      'reis': 180.0, 'rice': 180.0,
      'pasta': 220.0,
      'haferflocken': 80.0, 'oats': 80.0,
    };

    for (final entry in portions.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return 100.0;
  }
}
