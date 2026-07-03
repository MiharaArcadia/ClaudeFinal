/// First-run tutorial — a short, skippable, friendly intro to the mechanics.
/// Backs the brief's "avoid frustration" goal.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.touch_app_rounded,
      title: 'Drag the candies',
      body: 'Drag a candy piece from the tray onto the board. '
          'Pieces do not rotate — just find where they fit.',
    ),
    (
      icon: Icons.view_week_rounded,
      title: 'Fill a line',
      body: 'Complete any full row or column to clear it and score. '
          'Clear several at once for big combos!',
    ),
    (
      icon: Icons.flash_on_rounded,
      title: 'Ultra Blast',
      body: 'Earn Ultra Blasts in Challenge Mode and unleash them to '
          'instantly clear a whole row when you are stuck.',
    ),
    (
      icon: Icons.emoji_events_rounded,
      title: 'Grow & collect',
      body: 'Earn XP, level up, unlock candy skins and backgrounds, and '
          'conquer 99 Adventure levels. Have fun!',
    ),
  ];

  Future<void> _finish() async {
    await context.read<PlayerController>().markTutorialSeen();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: BlockzyGradients.backgroundGlow),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.all(BlockzySpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p.icon, size: 96, color: BlockzyColors.primary),
                          const SizedBox(height: BlockzySpacing.xl),
                          Text(
                            p.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: BlockzySpacing.md),
                          Text(
                            p.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: BlockzyMotion.fast,
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? BlockzyColors.primary
                          : BlockzyColors.textSecondary,
                      borderRadius: BorderRadius.circular(BlockzyRadii.pill),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(BlockzySpacing.lg),
                child: GradientButton(
                  label: last ? "Let's play!" : 'Next',
                  onTap: () {
                    if (last) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: BlockzyMotion.base,
                        curve: BlockzyMotion.emphasized,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
