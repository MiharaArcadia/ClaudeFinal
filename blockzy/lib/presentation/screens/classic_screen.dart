/// Classic Mode host — endless play with a high score and Ultra Blast support.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/modes/classic_engine.dart';
import '../effects/effects.dart';
import '../game/game_controller.dart';
import '../game/game_screen.dart';
import '../player_controller.dart';
import '../../services/asset_loader.dart';
import 'game_over_sheet.dart';

class ClassicScreen extends StatefulWidget {
  const ClassicScreen({super.key});

  @override
  State<ClassicScreen> createState() => _ClassicScreenState();
}

class _ClassicScreenState extends State<ClassicScreen> {
  late GameController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final player = context.read<PlayerController>();
    final classic = ClassicEngine(remap: player.candyRemap);
    _controller = GameController(
      mode: GameMode.classic,
      engine: classic.engine,
      audio: player.audio,
      haptics: player.haptics,
      effects: EffectsController(profile: _profile(player)),
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
    final engine = _controller.engine;
    final xp = 100 + engine.score ~/ 25;
    final levelUp = await player.recordGameResult(
      won: false, // endless: "won" is not meaningful; best score is the prize
      score: engine.score,
      bestCombo: engine.bestCombo,
      candiesCleared: engine.candiesCleared,
      xp: xp,
    );
    if (!mounted) return;
    await showGameOverSheet(
      context,
      score: engine.score,
      bestCombo: engine.bestCombo,
      xpEarned: xp,
      levelUp: levelUp,
      isHighScore: engine.score >= player.stats.highestScore,
      onRetry: () {
        Navigator.of(context).pop();
        setState(_build);
      },
      onHome: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
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
