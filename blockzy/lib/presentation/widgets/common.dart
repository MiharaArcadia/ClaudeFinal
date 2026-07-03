/// Reusable, rounded, gradient-forward UI building blocks used across screens.
/// Keeping them here avoids duplicated styling and guarantees a consistent look.
library;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

/// A large, tappable gradient button with a soft glow.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = BlockzyGradients.primary,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Gradient gradient;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(BlockzyRadii.lg),
            boxShadow: enabled
                ? BlockzyShadows.glow(BlockzyColors.primary)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded, soft-shadowed panel/card container.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(BlockzySpacing.md),
      decoration: BoxDecoration(
        color: BlockzyColors.bgPanel,
        borderRadius: BorderRadius.circular(BlockzyRadii.lg),
        boxShadow: BlockzyShadows.soft,
      ),
      child: child,
    );
  }
}

/// A three-star rating row.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 28});
  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? BlockzyColors.accentGold : BlockzyColors.textSecondary,
            size: size,
          ),
        );
      }),
    );
  }
}

/// A labelled statistic row.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: BlockzyColors.accentGold,
                ),
          ),
        ],
      ),
    );
  }
}

/// The animated player XP bar.
class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.level,
    required this.progress,
    this.isMax = false,
  });

  final int level;
  final double progress;
  final bool isMax;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              isMax ? 'MAX' : '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(BlockzyRadii.pill),
          child: Stack(
            children: [
              Container(height: 14, color: BlockzyColors.gridEmpty),
              AnimatedFractionallySizedBox(
                duration: BlockzyMotion.slow,
                curve: BlockzyMotion.emphasized,
                widthFactor: progress.clamp(0, 1),
                child: Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    gradient: BlockzyGradients.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A simple screen scaffold with a gradient background and a titled app bar.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title), actions: actions),
      body: Container(
        decoration: const BoxDecoration(
          gradient: BlockzyGradients.backgroundGlow,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(BlockzySpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
