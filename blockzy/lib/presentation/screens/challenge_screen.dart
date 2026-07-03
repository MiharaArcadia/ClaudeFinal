/// Challenge Mode host — a daily-seeded run. Completing score tiers grants
/// Ultra Blasts (capped by the bank at 2 per rolling 24h).
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../../domain/modes/challenge_engine.dart';
import '../effects/effects.dart';
import '../game/game_controller.dart';
import '../game/game_screen.dart';
import '../player_controller.dart';
import '../../services/asset_loader.dart';
import '../widgets/common.dart';
import 'game_over_sheet.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late GameController _controller;
  late ChallengeEngine _challenge;
  bool _handled = false;
  bool _started = false;

  void _build() {
    final player = context.read<PlayerController>();
    _challenge = ChallengeEngine(
      day: DateTime.now(),
      remap: player.candyRemap,
    );
    _controller = GameController(
      mode: GameMode.challenge,
      engine: _challenge.engine,
      audio: player.audio,
      haptics: player.haptics,
      effects: EffectsController(profile: _profile(player)),
    );
    _handled = false;
    _started = true;
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
    final engine = _challenge.engine;
    final earnedBlasts = _challenge.ultraBlastsEarned();
    final granted = await player.earnUltraBlasts(earnedBlasts);

    final xp = 150 + engine.score ~/ 20; // challenge grants more XP
    final levelUp = await player.recordGameResult(
      won: engine.score > 0,
      score: engine.score,
      bestCombo: engine.bestCombo,
      candiesCleared: engine.candiesCleared,
      xp: xp,
      challengeCompleted: engine.score >= 3000,
    );
    if (!mounted) return;

    if (granted > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Earned $granted Ultra Blast(s)!')),
      );
    }
    await showGameOverSheet(
      context,
      score: engine.score,
      bestCombo: engine.bestCombo,
      xpEarned: xp,
      levelUp: levelUp,
      won: engine.score >= 3000,
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
    if (!_started) {
      // Intro card before starting the day's run.
      return ScreenScaffold(
        title: 'Daily Challenge',
        child: Center(
          child: Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    size: 64, color: BlockzyColors.accentGold),
                const SizedBox(height: BlockzySpacing.md),
                Text(
                  "Today's challenge",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'A fresh board every day. Reach 3,000 and 8,000 points to '
                  'earn up to 2 Ultra Blasts (per 24h).',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: BlockzySpacing.lg),
                GradientButton(
                  label: 'Start',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => setState(_build),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
