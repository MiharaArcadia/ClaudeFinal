/// Stone Swap reward — after completing an Adventure level, the player may
/// replace one candy type with another. A beautiful tile picker.
library;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/candy.dart';
import '../game/candy_painter.dart';
import '../widgets/common.dart';

/// Shows the Stone Swap picker. Returns (from, to) or null if skipped.
Future<({CandyType from, CandyType to})?> showStoneSwapSheet(
  BuildContext context,
) {
  return showModalBottomSheet<({CandyType from, CandyType to})?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _StoneSwapSheet(),
  );
}

class _StoneSwapSheet extends StatefulWidget {
  const _StoneSwapSheet();

  @override
  State<_StoneSwapSheet> createState() => _StoneSwapSheetState();
}

class _StoneSwapSheetState extends State<_StoneSwapSheet> {
  CandyType? _from;
  CandyType? _to;

  @override
  Widget build(BuildContext context) {
    final ready = _from != null && _to != null && _from != _to;
    return Container(
      margin: const EdgeInsets.all(BlockzySpacing.md),
      padding: const EdgeInsets.all(BlockzySpacing.lg),
      decoration: BoxDecoration(
        color: BlockzyColors.bgPanel,
        borderRadius: BorderRadius.circular(BlockzyRadii.xl),
        boxShadow: BlockzyShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stone Swap reward',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            _from == null
                ? 'Choose a candy to replace'
                : 'Now choose its replacement',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: BlockzySpacing.md),
          _CandyGrid(
            selected: _from == null ? null : _to,
            highlight: _from,
            onPick: (type) => setState(() {
              if (_from == null) {
                _from = type;
              } else {
                _to = type;
              }
            }),
          ),
          const SizedBox(height: BlockzySpacing.lg),
          GradientButton(
            label: 'Apply swap',
            enabled: ready,
            onTap: () => Navigator.of(context).pop((from: _from!, to: _to!)),
          ),
          const SizedBox(height: BlockzySpacing.sm),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _CandyGrid extends StatelessWidget {
  const _CandyGrid({
    required this.onPick,
    this.selected,
    this.highlight,
  });

  final void Function(CandyType) onPick;
  final CandyType? selected;
  final CandyType? highlight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: CandyType.values.map((type) {
        final isHighlight = type == highlight;
        return GestureDetector(
          onTap: () => onPick(type),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BlockzyRadii.md),
              border: Border.all(
                color: isHighlight
                    ? BlockzyColors.accentGold
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: CustomPaint(painter: _SingleCandyPainter(type)),
          ),
        );
      }).toList(),
    );
  }
}

class _SingleCandyPainter extends CustomPainter {
  _SingleCandyPainter(this.type);
  final CandyType type;

  @override
  void paint(Canvas canvas, Size size) {
    CandyPainter.paint(
      canvas,
      Offset.zero & size,
      type,
    );
  }

  @override
  bool shouldRepaint(covariant _SingleCandyPainter oldDelegate) =>
      oldDelegate.type != type;
}
