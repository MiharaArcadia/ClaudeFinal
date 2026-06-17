import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/food_detail_screen.dart';
import 'package:carby/services/open_food_facts_service.dart';
import 'package:carby/services/speech_service.dart';
import 'package:carby/theme/app_theme.dart';
import 'package:carby/widgets/pulsing_mic_button.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  final SpeechService _speech = SpeechService();
  final OpenFoodFactsService _foodApi = OpenFoodFactsService();
  final TextEditingController _textController = TextEditingController();

  bool _listening = false;
  bool _searching = false;
  String _recognizedText = '';
  List<Food> _results = [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  @override
  void dispose() {
    _speech.dispose();
    _textController.dispose();
    super.dispose();
  }

  String get _lang =>
      context.read<UserProvider>().profile?.language ?? 'de';

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stopListening();
      setState(() => _listening = false);
    } else {
      setState(() {
        _listening = true;
        _recognizedText = '';
        _results = [];
        _searched = false;
      });
      await _speech.startListening(
        language: _lang,
        onResult: (words) {
          setState(() => _recognizedText = words);
          _textController.text = words;
        },
        onFinalResult: (words) {
          setState(() {
            _listening = false;
            _recognizedText = words;
          });
          if (words.isNotEmpty) _search(words);
        },
      );
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _searching = true;
      _searched = false;
      _results = [];
    });

    final results = await _foodApi.searchFood(query.trim(), lang: _lang);
    setState(() {
      _results = results;
      _searching = false;
      _searched = true;
    });

    if (results.length == 1) {
      _openDetail(results.first);
    }
  }

  void _openDetail(Food food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodDetailScreen(food: food),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'de' ? 'Lebensmittel suchen' : 'Search food',
          style: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: lang == 'de'
                          ? 'Lebensmittel eingeben...'
                          : 'Enter food name...',
                      hintStyle: GoogleFonts.inter(
                          color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(width: 12),
                PulsingMicButton(
                  listening: _listening,
                  onPressed: _toggleListening,
                ),
              ],
            ),
          ),

          // Listening indicator
          if (_listening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq,
                        color: AppColors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _recognizedText.isEmpty
                            ? (lang == 'de' ? 'Höre zu...' : 'Listening...')
                            : _recognizedText,
                        style: GoogleFonts.inter(
                          color: _recognizedText.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading
          if (_searching)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.orange),
            ),

          // Results
          if (!_searching)
            Expanded(
              child: _results.isEmpty && _searched
                  ? Center(
                      child: Text(
                        lang == 'de' ? 'Keine Ergebnisse' : 'No results',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final food = _results[i];
                        return GestureDetector(
                          onTap: () => _openDetail(food),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // Food image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: food.imageUrl.isNotEmpty
                                      ? Image.network(
                                          food.imageUrl,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _foodPlaceholder(),
                                        )
                                      : _foodPlaceholder(),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(food.name,
                                          style: GoogleFonts.inter(
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      if (food.brand.isNotEmpty)
                                        Text(food.brand,
                                            style: GoogleFonts.inter(
                                                color: AppColors.textSecondary,
                                                fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
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
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _foodPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.surface,
      child: const Icon(Icons.restaurant,
          color: AppColors.textSecondary, size: 24),
    );
  }
}
