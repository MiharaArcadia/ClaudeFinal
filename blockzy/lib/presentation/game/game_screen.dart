/// The interactive gameplay screen shared by all three modes.
///
/// Owns the 60 FPS ticker, lays out the board and computes its geometry, renders
/// the board + live effects (with screen-shake), draws the draggable tray, and
/// wires drag-to-place and Ultra Blast targeting. Win/lose is surfaced via the
/// provided callbacks so each mode decides what happens next.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../domain/candy.dart';
import '../../domain/levels/level_def.dart';
import '../../domain/piece.dart';
import '../effects/effects.dart';
import 'board_painter.dart';
import 'candy_painter.dart';
import 'game_controller.dart';

/// Live map of loaded candy art (ui.Image or null → procedural).
typedef CandyImages = Map<CandyType, ui.Image?>;

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.controller,
    required this.images,
    required this.onExit,
    this.onFinished,
    this.ultraBlastAvailable = 0,
    this.onUseUltraBlast,
    this.title,
  });

  final GameController controller;
  final CandyImages images;

  /// Called when the user leaves via the back/pause exit.
  final VoidCallback onExit;

  /// Called once when the game ends (win or lose). Argument = won.
  final void Function(bool won)? onFinished;

  /// How many Ultra Blasts the player has stored (enables the button).
  final int ultraBlastAvailable;

  /// Invoked when an Ultra Blast is actually consumed on [row].
  final void Function(int row)? onUseUltraBlast;

  final String? title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  final GlobalKey _boardKey = GlobalKey();

  // Drag state.
  int? _dragIndex;
  List<Cell> _previewCells = const [];
  bool _previewValid = false;
  int? _ultraRow;

  bool _finishedNotified = false;

  GameController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    c.tick(dt.clamp(0, 0.05));
    _maybeNotifyFinished();
  }

  void _maybeNotifyFinished() {
    if (_finishedNotified) return;
    if (c.isOver) {
      _finishedNotified = true;
      // Defer to end of frame so callbacks can navigate safely.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onFinished?.call(c.adventure?.objectiveMet ?? false);
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // --- Board geometry helpers ----------------------------------------------

  double _boardSizePx(BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    return maxW.clamp(0, 520).toDouble();
  }

  Offset? _boardLocal(Offset global) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.globalToLocal(global);
  }

  // --- Drag handling --------------------------------------------------------

  void _onTrayDragStart(int index) {
    setState(() {
      _dragIndex = index;
      _previewCells = const [];
      _previewValid = false;
    });
  }

  void _onTrayDragUpdate(Offset globalPos, double cellPx, int boardSize) {
    final index = _dragIndex;
    if (index == null) return;
    final local = _boardLocal(globalPos);
    if (local == null) return;
    final piece = c.tray[index];

    // Position the piece above the finger, horizontally centred on it.
    final fingerCol = (local.dx / cellPx).floor();
    final fingerRow = (local.dy / cellPx).floor();
    final anchorCol = fingerCol - piece.shape.width ~/ 2;
    final anchorRow = fingerRow - piece.shape.height; // lift above finger

    final cells = piece.shape.cells
        .map((rel) => Cell(anchorCol + rel.col, anchorRow + rel.row))
        .toList();
    final valid = c.canPlaceAnchor(index, anchorCol, anchorRow);

    setState(() {
      _previewCells = cells;
      _previewValid = valid;
    });
  }

  void _onTrayDragEnd() {
    final index = _dragIndex;
    if (index != null && _previewValid && _previewCells.isNotEmpty) {
      // Shapes are top-left normalised, so the min col/row of the preview cells
      // is exactly the placement anchor the engine expects.
      final minCol =
          _previewCells.map((e) => e.col).reduce((a, b) => a < b ? a : b);
      final minRow =
          _previewCells.map((e) => e.row).reduce((a, b) => a < b ? a : b);
      c.placePiece(index, minCol, minRow);
    }
    setState(() {
      _dragIndex = null;
      _previewCells = const [];
      _previewValid = false;
    });
  }

  // --- Ultra Blast targeting ------------------------------------------------

  void _onBoardTapForUltra(Offset globalPos, double cellPx, int boardSize) {
    if (!c.ultraTargeting) return;
    final local = _boardLocal(globalPos);
    if (local == null) return;
    final row = (local.dy / cellPx).floor();
    if (row < 0 || row >= boardSize) return;
    widget.onUseUltraBlast?.call(row);
    setState(() => _ultraRow = null);
  }

  void _onUltraHover(Offset globalPos, double cellPx, int boardSize) {
    if (!c.ultraTargeting) return;
    final local = _boardLocal(globalPos);
    if (local == null) return;
    final row = (local.dy / cellPx).floor();
    setState(() => _ultraRow = (row >= 0 && row < boardSize) ? row : null);
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = c.engine.board.size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: BlockzyGradients.backgroundGlow,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _Hud(controller: c, onExit: widget.onExit),
              const Spacer(),
              LayoutBuilder(
                builder: (context, constraints) {
                  final boardPx = _boardSizePx(constraints);
                  final cellPx = boardPx / boardSize;
                  // Effects paint inside the board's own coordinate space, so
                  // the geometry origin is zero and only the cell size matters.
                  c.setGeometry(
                    BoardGeometry(origin: Offset.zero, cellSize: cellPx),
                  );
                  return _buildBoard(boardPx, cellPx, boardSize);
                },
              ),
              const SizedBox(height: BlockzySpacing.lg),
              _Tray(
                controller: c,
                images: widget.images,
                draggingIndex: _dragIndex,
                onDragStart: _onTrayDragStart,
                onDragUpdate: (pos) {
                  final boardPx = _lastBoardPx;
                  _onTrayDragUpdate(pos, boardPx / boardSize, boardSize);
                },
                onDragEnd: _onTrayDragEnd,
              ),
              const SizedBox(height: BlockzySpacing.md),
              _UltraBlastBar(
                available: widget.ultraBlastAvailable,
                targeting: c.ultraTargeting,
                onToggle: () {
                  if (c.ultraTargeting) {
                    c.cancelUltraTargeting();
                  } else if (widget.ultraBlastAvailable > 0) {
                    c.enterUltraTargeting();
                  }
                  setState(() => _ultraRow = null);
                },
              ),
              const SizedBox(height: BlockzySpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  double _lastBoardPx = 480;

  Widget _buildBoard(double boardPx, double cellPx, int boardSize) {
    _lastBoardPx = boardPx;
    return AnimatedBuilder(
      animation: c.repaint,
      builder: (context, _) {
        final shake = c.effects.shakeOffset;
        return Transform.translate(
          offset: shake,
          child: Listener(
            onPointerHover: (e) =>
                _onUltraHover(e.position, cellPx, boardSize),
            onPointerMove: (e) =>
                _onUltraHover(e.position, cellPx, boardSize),
            child: GestureDetector(
              onTapUp: (d) =>
                  _onBoardTapForUltra(d.globalPosition, cellPx, boardSize),
              child: Container(
                key: _boardKey,
                width: boardPx,
                height: boardPx,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BlockzyColors.bgPanel,
                  borderRadius: BorderRadius.circular(BlockzyRadii.lg),
                  boxShadow: BlockzyShadows.soft,
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(boardPx, boardPx),
                      painter: BoardPainter(
                        board: c.engine.board,
                        images: widget.images,
                        repaint: c.repaint,
                        previewCells: _previewCells,
                        previewCandy: _dragIndex == null
                            ? null
                            : c.tray[_dragIndex!].candy,
                        previewValid: _previewValid,
                        ultraTargetRow: c.ultraTargeting ? _ultraRow : null,
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: EffectsPainter(c.effects, c.repaint),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- HUD --------------------------------------------------------------------

class _Hud extends StatelessWidget {
  const _Hud({required this.controller, required this.onExit});
  final GameController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final adv = controller.adventure;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BlockzySpacing.md, vertical: BlockzySpacing.sm),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Row(
          children: [
            IconButton(
              onPressed: onExit,
              icon: const Icon(Icons.pause_rounded),
              tooltip: 'Pause',
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${controller.score}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: BlockzyColors.accentGold,
                        ),
                  ),
                  if (adv != null)
                    _ObjectiveChip(adventure: adv)
                  else
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveChip extends StatelessWidget {
  const _ObjectiveChip({required this.adventure});
  final dynamic adventure; // AdventureEngine

  @override
  Widget build(BuildContext context) {
    final LevelDef level = adventure.level as LevelDef;
    final progress = adventure.objectiveProgress as int;
    final target = level.objective.target;
    final movesLeft = adventure.movesRemaining as int;
    return Column(
      children: [
        Text(
          _label(level.objective),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 2),
        Text(
          '$progress / $target   •   moves $movesLeft',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: BlockzyColors.textSecondary,
              ),
        ),
      ],
    );
  }

  String _label(Objective o) {
    switch (o.kind) {
      case ObjectiveKind.score:
        return 'Reach the target score';
      case ObjectiveKind.collectCandy:
        return 'Collect ${o.candyType?.name ?? 'candy'}';
      case ObjectiveKind.clearLines:
        return 'Clear lines';
      case ObjectiveKind.clearObstacles:
        return 'Clear the obstacles';
    }
  }
}

// --- Tray -------------------------------------------------------------------

class _Tray extends StatelessWidget {
  const _Tray({
    required this.controller,
    required this.images,
    required this.draggingIndex,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final GameController controller;
  final CandyImages images;
  final int? draggingIndex;
  final void Function(int index) onDragStart;
  final void Function(Offset globalPos) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final tray = controller.tray;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            if (i >= tray.length) {
              return const SizedBox(width: 92, height: 92);
            }
            final piece = tray[i];
            final active = draggingIndex == i;
            return GestureDetector(
              onPanStart: (_) => onDragStart(i),
              onPanUpdate: (d) => onDragUpdate(d.globalPosition),
              onPanEnd: (_) => onDragEnd(),
              child: Opacity(
                opacity: active ? 0.35 : 1,
                child: _PieceThumb(piece: piece, images: images),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PieceThumb extends StatelessWidget {
  const _PieceThumb({required this.piece, required this.images});
  final Piece piece;
  final CandyImages images;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BlockzyColors.bgPanelSoft,
        borderRadius: BorderRadius.circular(BlockzyRadii.md),
        boxShadow: BlockzyShadows.soft,
      ),
      child: CustomPaint(
        painter: _PiecePainter(piece: piece, images: images),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter({required this.piece, required this.images});
  final Piece piece;
  final CandyImages images;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = piece.shape.width;
    final rows = piece.shape.height;
    final cell = (size.width / (cols > rows ? cols : rows));
    final offX = (size.width - cols * cell) / 2;
    final offY = (size.height - rows * cell) / 2;
    for (final c in piece.shape.cells) {
      final rect = Rect.fromLTWH(
        offX + c.col * cell,
        offY + c.row * cell,
        cell,
        cell,
      );
      CandyPainter.paint(canvas, rect, piece.candy, image: images[piece.candy]);
    }
  }

  @override
  bool shouldRepaint(covariant _PiecePainter oldDelegate) =>
      oldDelegate.piece != piece;
}

// --- Ultra Blast bar --------------------------------------------------------

class _UltraBlastBar extends StatelessWidget {
  const _UltraBlastBar({
    required this.available,
    required this.targeting,
    required this.onToggle,
  });

  final int available;
  final bool targeting;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: BlockzyMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: targeting
              ? BlockzyGradients.candyPink
              : BlockzyGradients.primary,
          borderRadius: BorderRadius.circular(BlockzyRadii.pill),
          boxShadow: available > 0
              ? BlockzyShadows.glow(BlockzyColors.secondary)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              targeting ? 'Tap a row to blast!' : 'Ultra Blast  ×$available',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
