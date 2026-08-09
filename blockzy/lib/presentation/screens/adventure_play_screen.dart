/// Adventure level host — runs one [LevelDef], shows the reward + Stone Swap on
/// win, records stars/XP, and advances to the next level.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/levels/level_catalog.dart';
import '../../domain/modes/adventure_engine.dart';
import '../effects/effects.dart';
import '../game/game_controller.dart';
import '../game/game_screen.dart';
import '../player_controller.dart';
import '../../services/asset_loader.dart';
import 'game_over_sheet.dart';
import 'stone_swap_sheet.dart';

class AdventurePlayScreen extends StatefulWidget {
  const AdventurePlayScreen({super.key, required this.levelNumber});
  final int levelNumber;

  @override
  State<AdventurePlayScreen> createState() => _AdventurePlayScreenState();
}

class _AdventurePlayScreenState extends State<AdventurePlayScreen> {
  late GameController _controller;
  late AdventureEngine _adventure;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _build(widget.levelNumber);
  }

  void _build(int number) {
    final player = context.read<PlayerController>();
    final level = LevelCatalog.byNumber(number)!;
    _adventure = AdventureEngine(level, remap: player.candyRemap);
    _controller = GameController(
      mode: GameMode.adventure,
      engine: _adventure.engine,
      audio: player.audio,
      haptics: player.haptics,
      effects: EffectsController(profile: _profile(player)),
      adventure: _adventure,
    );
    _handled = false;
  }

  PerformanceProfile _profile(PlayerController p) {
    if (p.settings.batterySaver) return PerformanceProfile.battery;
    if (!p.settings.highPerformanceMode) return PerformanceProfile.balanced;
    return PerformanceProfile.high;
  }

  Future<void> _onFinished(bool won) async {
    if (_handled) return;
    _handled = true;
    final player = context.read<PlayerController>();
    final result = _adventure.evaluate();

    if (result.won) {
      await player.recordAdventureStars(widget.levelNumber, result.stars);
      final levelUp = await player.recordGameResult(
        won: true,
        score: result.score,
        bestCombo: _adventure.engine.bestCombo,
        candiesCleared: _adventure.engine.candiesCleared,
        xp: result.xpEarned,
        perfectLevel: result.stars == 3,
        adventureCompleted: true,
      );
      if (!mounted) return;

      // Stone Swap reward before the summary.
      final swap = await showStoneSwapSheet(context);
      if (swap != null) {
        await player.applyStoneSwap(swap.from, swap.to);
      }
      if (!mounted) return;

      final hasNext = widget.levelNumber < LevelCatalog.levelCount;
      await showGameOverSheet(
        context,
        won: true,
        stars: result.stars,
        score: result.score,
        bestCombo: _adventure.engine.bestCombo,
        xpEarned: result.xpEarned,
        levelUp: levelUp,
        onNext: hasNext
            ? () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AdventurePlayScreen(
                      levelNumber: widget.levelNumber + 1,
                    ),
                  ),
                );
              }
            : null,
        onRetry: () {
          Navigator.of(context).pop();
          setState(() => _build(widget.levelNumber));
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    } else {
      // Failure: no stars, minimal record; offer retry.
      await player.recordGameResult(
        won: false,
        score: result.score,
        bestCombo: _adventure.engine.bestCombo,
        candiesCleared: _adventure.engine.candiesCleared,
        xp: 0,
      );
      if (!mounted) return;
      await showGameOverSheet(
        context,
        won: false,
        stars: 0,
        score: result.score,
        bestCombo: _adventure.engine.bestCombo,
        xpEarned: 0,
        levelUp: LevelUpEvent(const [], const []),
        onRetry: () {
          Navigator.of(context).pop();
          setState(() => _build(widget.levelNumber));
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets = context.read<CandyAssetLoader>();
    final player = context.watch<PlayerController>();
    return GameScreen(
      controller: _controller,
      images: assets.images,
      ultraBlastAvailable: player.progress.ultraBlastStored,
      onUseUltraBlast: (row) async {
        if (await player.spendUltraBlast()) {
          _controller.ultraBlastRow(row);
        }
      },
      onExit: () => Navigator.of(context).pop(),
      onFinished: _onFinished,
    );
  }
}
