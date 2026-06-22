import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carby/models/food_model.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Food> _favorites = [];

  List<Food> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String foodId) => _favorites.any((f) => f.id == foodId);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('favorites') ?? [];
    _favorites = raw.map((s) {
      try {
        return Food.fromMap(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Food>().toList();
    notifyListeners();
  }

  Future<void> addFavorite(Food food) async {
    if (isFavorite(food.id)) return;
    _favorites = [..._favorites, food];
    notifyListeners();
    await _persist();
  }

  Future<void> removeFavorite(String foodId) async {
    _favorites = _favorites.where((f) => f.id != foodId).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      _favorites.map((f) => jsonEncode(f.toMap())).toList(),
    );
  }
}
