/// Lightweight, allocation-conscious effects system: candy-explosion particles,
/// floating score numbers, and screen shake. Driven by a single ticker from the
/// game screen so everything updates in one 60 FPS pass.
///
/// Effect intensity scales with the [PerformanceProfile] so battery-saver mode
/// keeps frames smooth on low-end devices.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Controls how much juice to spend, protecting the 60 FPS budget.
class PerformanceProfile {
  const PerformanceProfile({
    required this.particleScale,
    required this.shakeScale,
    required this.enableGlow,
  });

  final double particleScale; // 0..1 multiplier on particle counts
  final double shakeScale; // 0..1 multiplier on shake magnitude
  final bool enableGlow;

  static const PerformanceProfile high =
      PerformanceProfile(particleScale: 1, shakeScale: 1, enableGlow: true);
  static const PerformanceProfile balanced = PerformanceProfile(
    particleScale: 0.6,
    shakeScale: 0.8,
    enableGlow: true,
  );
  static const PerformanceProfile battery = PerformanceProfile(
    particleScale: 0.25,
    shakeScale: 0.4,
    enableGlow: false,
  );
}

/// A single candy-explosion particle.
class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
  }) : age = 0;

  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life; // seconds
  double age;

  bool get dead => age >= life;
  double get t => (age / life).clamp(0, 1);

  void update(double dt) {
    age += dt;
    // Gravity + drag for a satisfying pop-and-fall.
    velocity = Offset(velocity.dx * 0.92, velocity.dy * 0.92 + 900 * dt);
    position += velocity * dt;
  }
}

/// A rising, fading score number.
class FloatingScore {
  FloatingScore({
    required this.position,
    required this.text,
    required this.color,
    this.life = 0.9,
  }) : age = 0;

  Offset position;
  final String text;
  final Color color;
  final double life;
  double age;

  bool get dead => age >= life;
  double get t => (age / life).clamp(0, 1);

  void update(double dt) {
    age += dt;
    position = Offset(position.dx, position.dy - 60 * dt);
  }
}

/// Owns all live effects and the screen-shake state.
class EffectsController {
  EffectsController({this.profile = PerformanceProfile.high});

  PerformanceProfile profile;

  final List<Particle> particles = [];
  final List<FloatingScore> floats = [];
  final math.Random _rng = math.Random();

  double _shake = 0; // current shake magnitude in px
  double _shakeDecay = 0;

  bool get isEmpty => particles.isEmpty && floats.isEmpty && _shake <= 0.01;

  /// Current screen-shake translation offset for this frame.
  Offset get shakeOffset {
    if (_shake <= 0.01) return Offset.zero;
    final a = _rng.nextDouble() * math.pi * 2;
    return Offset(math.cos(a), math.sin(a)) * _shake;
  }

  /// Emits a burst of candy particles at [center] in [color].
  void explode(Offset center, Color color, {int count = 14}) {
    final n = (count * profile.particleScale).round().clamp(1, count);
    for (var i = 0; i < n; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 120 + _rng.nextDouble() * 260;
      particles.add(
        Particle(
          position: center,
          velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
          color: color,
          size: 3 + _rng.nextDouble() * 5,
          life: 0.5 + _rng.nextDouble() * 0.5,
        ),
      );
    }
  }

  /// Adds a floating score number at [position].
  void addFloatingScore(Offset position, int amount, Color color) {
    floats.add(
      FloatingScore(position: position, text: '+$amount', color: color),
    );
  }

  /// Triggers screen shake with [magnitude] px (scaled by the profile).
  void shake(double magnitude) {
    final m = magnitude * profile.shakeScale;
    if (m > _shake) {
      _shake = m;
      _shakeDecay = m / 0.35; // fully decays in ~0.35s
    }
  }

  /// Advances all effects by [dt] seconds. Returns true if anything is alive.
  bool update(double dt) {
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.dead);

    for (final f in floats) {
      f.update(dt);
    }
    floats.removeWhere((f) => f.dead);

    if (_shake > 0) {
      _shake = math.max(0, _shake - _shakeDecay * dt);
    }
    return !isEmpty;
  }

  void clear() {
    particles.clear();
    floats.clear();
    _shake = 0;
  }
}

/// Paints the live particles + floating scores. Cheap: simple circles + text.
class EffectsPainter extends CustomPainter {
  EffectsPainter(this.controller, this.repaint) : super(repaint: repaint);

  final EffectsController controller;
  final Listenable repaint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in controller.particles) {
      final fade = (1 - p.t).clamp(0, 1).toDouble();
      paint.color = p.color.withValues(alpha: fade);
      canvas.drawCircle(p.position, p.size * (1 - p.t * 0.4), paint);
    }
    for (final f in controller.floats) {
      final fade = (1 - f.t).clamp(0, 1).toDouble();
      final tp = TextPainter(
        text: TextSpan(
          text: f.text,
          style: TextStyle(
            color: f.color.withValues(alpha: fade),
            fontSize: 22 + (1 - fade) * 6,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(blurRadius: 6, color: Colors.black54),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, f.position - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant EffectsPainter oldDelegate) => true;
}
