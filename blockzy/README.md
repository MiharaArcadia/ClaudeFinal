# Blockzy 🍬

A colorful, juicy block-and-candy puzzle game for Android (iOS-ready).

Drag candy pieces onto an 8×8 board, complete rows and columns to clear them,
chain combos, and chase high scores across three modes — all wrapped in
particle explosions, screen shake, floating scores and satisfying haptics.

- **Price:** €0.99 · **No ads · No subscriptions · No energy · No pay-to-win.**
- Optional voluntary donations on the Support page.

## Tech stack

- **Flutter (Dart 3.6+)** — Android-first, iOS-ready with minimal changes.
- **Clean architecture**, modular and documented:
  - `lib/domain/**` — pure-Dart game engine (no Flutter), fully unit-tested.
  - `lib/data/**` — serialisable models + `SaveRepository` (schema-versioned,
    cloud-save hook), local by default.
  - `lib/services/**` — audio (graceful no-file fallback), haptics, candy asset
    auto-loader.
  - `lib/presentation/**` — theme, state (`PlayerController`), effects, painters,
    the shared `GameScreen`, and all menu screens.
- **60 FPS** rendering via `CustomPainter` + a single `Ticker`-driven effects
  pass; a performance profile scales juice for battery-saver / low-end devices.

## Modes

- **Classic** — endless, rising difficulty, high score.
- **Adventure** — 99 handcrafted levels (objectives, move limits, 3-star rating,
  XP, Stone Swap reward after each level).
- **Challenge** — a daily-seeded run starting ≈ Adventure 20, slightly harder
  each day, granting up to 2 **Ultra Blasts** per 24h.

## Systems

XP & levels (max 100), coins, cosmetics + Shop, achievements, statistics, daily
streak, Ultra Blast bank, Stone Swap candy remap, cloud-save-ready persistence.
See [`docs/XP_DESIGN.md`](docs/XP_DESIGN.md) for the progression math and the
reasoning behind it.

## Running

```bash
cd blockzy
flutter pub get
flutter run                 # debug on a connected device/emulator
flutter test                # runs the pure-Dart domain test suite
flutter build apk --release # release build (see PLAY_STORE_RELEASE.md)
```

> The domain layer has no Flutter dependency, so `flutter test` exercises all
> the core rules (board clears, combos, game-over, XP curve, level generation,
> Ultra Blast cap, Stone Swap) without a device.

## Assets

Real candy art / audio are dropped into `assets/candies/` and `assets/audio/`.
Until then the game renders **procedural candies** and stays silent-safe — see
[`assets/candies/README.md`](assets/candies/README.md). Nothing in code changes
when the real assets arrive.
