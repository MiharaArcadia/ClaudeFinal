/// The animated home hub: title, live XP bar, the three game modes, and quick
/// access to every meta screen (achievements, profile, stats, settings, shop,
/// support, accessibility).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../player_controller.dart';
import '../widgets/common.dart';
import 'achievements_screen.dart';
import 'adventure_map_screen.dart';
import 'challenge_screen.dart';
import 'classic_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'statistics_screen.dart';
import 'support_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bg;

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    // Show the tutorial once after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeTutorial());
  }

  Future<void> _maybeTutorial() async {
    final player = context.read<PlayerController>();
    if (!player.tutorialSeen && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TutorialScreen()),
      );
    }
  }

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final level = player.levelState;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bg,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  math.sin(_bg.value * 2 * math.pi) * 0.4,
                  -0.6 + math.cos(_bg.value * 2 * math.pi) * 0.2,
                ),
                radius: 1.3,
                colors: const [BlockzyColors.bgPanelSoft, BlockzyColors.bgDeep],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(BlockzySpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: BlockzySpacing.md),
                _Title(pulse: _bg),
                const SizedBox(height: BlockzySpacing.lg),
                Panel(
                  child: XpBar(
                    level: level.level,
                    progress: level.progress,
                    isMax: level.isMax,
                  ),
                ),
                const SizedBox(height: BlockzySpacing.xl),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        label: 'Adventure',
                        icon: Icons.map_rounded,
                        onTap: () => _go(const AdventureMapScreen()),
                      ),
                      const SizedBox(height: BlockzySpacing.md),
                      GradientButton(
                        label: 'Classic',
                        icon: Icons.grid_view_rounded,
                        gradient: BlockzyGradients.candyPink,
                        onTap: () => _go(const ClassicScreen()),
                      ),
                      const SizedBox(height: BlockzySpacing.md),
                      GradientButton(
                        label: 'Challenge',
                        icon: Icons.local_fire_department_rounded,
                        gradient: BlockzyGradients.gold,
                        onTap: () => _go(const ChallengeScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BlockzySpacing.md),
                _QuickRow(
                  onCoinsTap: () => _go(const ShopScreen()),
                  coins: player.progress.coins,
                ),
                const SizedBox(height: BlockzySpacing.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    _IconChip(
                      icon: Icons.emoji_events_rounded,
                      label: 'Achievements',
                      onTap: () => _go(const AchievementsScreen()),
                    ),
                    _IconChip(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      onTap: () => _go(const ProfileScreen()),
                    ),
                    _IconChip(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      onTap: () => _go(const StatisticsScreen()),
                    ),
                    _IconChip(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () => _go(const SettingsScreen()),
                    ),
                    _IconChip(
                      icon: Icons.favorite_rounded,
                      label: 'Support',
                      onTap: () => _go(const SupportScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final scale = 1 + math.sin(pulse.value * 2 * math.pi) * 0.02;
        return Transform.scale(
          scale: scale,
          child: ShaderMask(
            shaderCallback: (rect) =>
                BlockzyGradients.candyPink.createShader(rect),
            child: const Text(
              'Blockzy',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickRow extends StatelessWidget {
  const _QuickRow({required this.coins, required this.onCoinsTap});
  final int coins;
  final VoidCallback onCoinsTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCoinsTap,
      child: Panel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded,
                color: BlockzyColors.accentGold),
            const SizedBox(width: 8),
            Text(
              '$coins',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            const Text('Shop', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: BlockzyColors.textPrimary),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
