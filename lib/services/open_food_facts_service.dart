import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carby/models/food_model.dart';

class OpenFoodFactsService {
  static const _base = 'https://world.openfoodfacts.org';
  static const _fields =
      'product_name,nutriments,image_url,serving_size,brands,_id';

  Future<List<Food>> searchFood(String query, {String lang = 'de'}) async {
    final results = await _fetch(query);
    if (results.isNotEmpty) return results;
    // Retry without language filter if nothing found
    return _fallbackSearch(query);
  }

  Future<List<Food>> _fetch(String query) async {
    final uri = Uri.parse('$_base/cgi/search.pl').replace(queryParameters: {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'fields': _fields,
      'page_size': '30',
    });

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = (data['products'] as List?) ?? [];

      final results = products
          .map((p) => Food.fromOpenFoodFacts(p as Map<String, dynamic>))
          .where((f) => f.name.isNotEmpty)
          .toList();

      results.sort((a, b) =>
          _relevance(b.name, query).compareTo(_relevance(a.name, query)));
      return results;
    } catch (_) {
      return [];
    }
  }

  int _relevance(String name, String query) {
    final n = name.toLowerCase();
    final q = query.toLowerCase();
    if (n == q) return 3;
    if (n.startsWith(q)) return 2;
    if (n.contains(q)) return 1;
    return 0;
  }

  // Offline fallback with common foods
  List<Food> _fallbackSearch(String query) {
    final q = query.toLowerCase();
    return _commonFoods
        .where((f) => f.name.toLowerCase().contains(q))
        .toList();
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

  static final List<Food> _commonFoods = [
    Food(
      id: 'apple', name: 'Apfel', imageUrl: '', brand: '',
      calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4,
      sugar: 10, salt: 0.0, defaultPortionGrams: 182,
    ),
    Food(
      id: 'banana', name: 'Banane', imageUrl: '', brand: '',
      calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6,
      sugar: 12, salt: 0.0, defaultPortionGrams: 120,
    ),
    Food(
      id: 'egg', name: 'Ei', imageUrl: '', brand: '',
      calories: 155, protein: 13, carbs: 1.1, fat: 11, fiber: 0,
      sugar: 1.1, salt: 0.4, defaultPortionGrams: 60,
    ),
    Food(
      id: 'chicken', name: 'Hähnchenbrust', imageUrl: '', brand: '',
      calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0,
      sugar: 0, salt: 0.07, defaultPortionGrams: 150,
    ),
    Food(
      id: 'oats', name: 'Haferflocken', imageUrl: '', brand: '',
      calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10.6,
      sugar: 1, salt: 0.0, defaultPortionGrams: 80,
    ),
    Food(
      id: 'salmon', name: 'Lachs', imageUrl: '', brand: '',
      calories: 208, protein: 20, carbs: 0, fat: 13, fiber: 0,
      sugar: 0, salt: 0.06, defaultPortionGrams: 150,
    ),
    Food(
      id: 'bread', name: 'Vollkornbrot', imageUrl: '', brand: '',
      calories: 247, protein: 9, carbs: 44, fat: 3.4, fiber: 7,
      sugar: 4, salt: 1.1, defaultPortionGrams: 30,
    ),
    Food(
      id: 'yogurt', name: 'Joghurt', imageUrl: '', brand: '',
      calories: 59, protein: 3.5, carbs: 5, fat: 3.3, fiber: 0,
      sugar: 5, salt: 0.1, defaultPortionGrams: 150,
    ),
  ];
}
