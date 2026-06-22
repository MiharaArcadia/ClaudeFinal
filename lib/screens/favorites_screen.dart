import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carby/providers/favorites_provider.dart';
import 'package:carby/providers/nutrition_provider.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/food_detail_screen.dart';
import 'package:carby/theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;
    final lang = context.watch<UserProvider>().profile?.language ?? 'de';
    final uid = context.watch<UserProvider>().profile?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                lang == 'de' ? 'Meine Lebensmittel' : 'My Foods',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                lang == 'de'
                    ? '← Entfernen   Hinzufügen →'
                    : '← Remove   Add to log →',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_border,
                              color: AppColors.textSecondary, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            lang == 'de'
                                ? 'Noch keine Favoriten'
                                : 'No favorites yet',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang == 'de'
                                ? 'Tippe ★ bei einem Lebensmittel'
                                : 'Tap ★ on any food',
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favorites.length,
                      itemBuilder: (_, i) {
                        final food = favorites[i];
                        return Dismissible(
                          key: Key('fav_${food.id}'),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Swipe left→right: remove from favorites
                              context
                                  .read<FavoritesProvider>()
                                  .removeFavorite(food.id);
                              return true;
                            } else {
                              // Swipe right→left: add to diary
                              if (uid != null) {
                                final portion = food.defaultPortionGrams ?? 100;
                                await context
                                    .read<NutritionProvider>()
                                    .addEntry(uid, food, portion);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      lang == 'de'
                                          ? '${food.name} hinzugefügt!'
                                          : '${food.name} added!',
                                      style: GoogleFonts.inter(
                                          color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }
                              return false; // keep in list after adding
                            }
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(food: food),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: food.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              food.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.restaurant,
                                                      color: AppColors
                                                          .textSecondary,
                                                      size: 22),
                                            ),
                                          )
                                        : const Icon(Icons.restaurant,
                                            color: AppColors.textSecondary,
                                            size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.name,
                                          style: GoogleFonts.inter(
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (food.brand.isNotEmpty)
                                          Text(
                                            food.brand,
                                            style: GoogleFonts.inter(
                                                color: AppColors.textSecondary,
                                                fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${food.calories.toInt()}',
                                        style: GoogleFonts.inter(
                                          color: AppColors.orange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text('kcal/100g',
                                          style: GoogleFonts.inter(
                                              color: AppColors.textSecondary,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
