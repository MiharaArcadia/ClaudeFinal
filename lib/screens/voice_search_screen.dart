import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/barcode_scanner_screen.dart';
import 'package:carby/screens/food_detail_screen.dart';
import 'package:carby/services/open_food_facts_service.dart';
import 'package:carby/services/speech_service.dart';
import 'package:carby/theme/app_theme.dart';
import 'package:carby/widgets/pulsing_mic_button.dart';

class VoiceSearchScreen extends StatefulWidget {
  final String? initialSearch;
  const VoiceSearchScreen({super.key, this.initialSearch});

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

  Timer? _debounce;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _speech.initialize();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _textController.text = widget.initialSearch!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search(widget.initialSearch!);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
      final ok = await _speech.initialize();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_lang == 'de'
                ? 'Mikrofon nicht verfügbar. Bitte Berechtigung prüfen.'
                : 'Microphone unavailable. Please check permissions.'),
          ));
        }
        return;
      }
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

  // Live autocomplete: debounce keystrokes and search as the user types.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
        _searched = false;
        _searching = false;
      });
      return;
    }
    setState(() {}); // reflect the clear-button / text state in the field
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query, autoOpen: false);
    });
  }

  Future<void> _search(String query, {bool autoOpen = true}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _activeQuery = q;
    // Keep previous results visible while the new ones load (no blanking).
    setState(() {
      _searching = true;
      _searched = false;
    });

    final results = await _foodApi.searchFood(q, lang: _lang);
    // Ignore stale responses from earlier keystrokes.
    if (!mounted || _activeQuery != q) return;
    setState(() {
      _results = results;
      _searching = false;
      _searched = true;
    });

    if (autoOpen && results.length == 1) {
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
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.orange),
                              ),
                            )
                          : (_textController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: AppColors.textSecondary),
                                  onPressed: () {
                                    _debounce?.cancel();
                                    _textController.clear();
                                    setState(() {
                                      _results = [];
                                      _searched = false;
                                      _searching = false;
                                    });
                                  },
                                )
                              : null),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (q) => _search(q),
                  ),
                ),
                const SizedBox(width: 10),
                PulsingMicButton(
                  listening: _listening,
                  onPressed: _toggleListening,
                ),
                const SizedBox(width: 10),
                _BarcodeButton(lang: lang),
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

          // Results — stay visible while a live search loads (spinner is in the field)
          if (!(_searching && _results.isEmpty))
            Expanded(
              child: _results.isEmpty && _searched && !_searching
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

class _BarcodeButton extends StatelessWidget {
  final String lang;
  const _BarcodeButton({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: lang == 'de' ? 'Barcode scannen' : 'Scan barcode',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
        ),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.teal.withOpacity(0.4)),
          ),
          child: const Icon(Icons.qr_code_scanner,
              color: AppColors.teal, size: 26),
        ),
      ),
    );
  }
}
