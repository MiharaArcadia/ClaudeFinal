# Blockzy — Google Play Release Checklist & Codebase Review

## 1. Release checklist

### App identity & build
- [ ] `applicationId` = `com.blockzy.game` (set in `android/app/build.gradle`).
- [ ] Bump `version` in `pubspec.yaml` (`x.y.z+build`) — build number must
      increase on every upload.
- [ ] Provide a release keystore and `android/key.properties`
      (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`). The build falls
      back to debug signing only when this file is absent.
- [ ] `flutter build appbundle --release` → upload the `.aab`.
- [ ] Generate the launcher icon set into `android/app/src/main/res/mipmap-*`
      (e.g. via `flutter_launcher_icons`) — a placeholder `ic_launcher` name is
      referenced by the manifest.

### Store listing
- [ ] Title, short & full description, feature graphic, phone + tablet
      screenshots, 512×512 icon.
- [ ] Category: Games → Puzzle. Content rating questionnaire (Everyone).
- [ ] Set the app as **Paid — €0.99** in Play Console.
- [ ] **Data safety form:** the app stores data **locally only** and performs
      **no tracking / no data collection**. Declare accordingly.
- [ ] Privacy policy URL (host `docs/privacy-policy` — a simple "no data
      collected, local-only, optional PayPal donation opens externally" page).

### Technical / quality
- [ ] `flutter analyze` clean; `flutter test` green.
- [ ] Test on a low-end device with **Battery saver** on (particle/shake scaling).
- [ ] Verify safe-area/notch layout on a tall device and a tablet.
- [ ] Confirm Support → Donate opens PayPal; settings persist across restart;
      Adventure star/XP progress survives an app kill.
- [ ] ProGuard/R8 enabled (already on for release) — smoke-test the release
      build, not just debug.
- [ ] Target SDK 34 (already set) meets current Play requirements.

## 2. ⚠️ Play policy risk: external donation link

Google Play's Payments policy can flag apps that link out to an **external
donation** (e.g. PayPal) when the app contains digital content. For a **paid**
app where the donation is clearly *voluntary support for the developer* (not a
purchase of in-app value), this is commonly accepted — but it is a real
rejection risk. Mitigations, in order of safety:

1. Keep the Support copy framed purely as optional support (it already is), with
   no suggestion that donating unlocks anything in-game.
2. If flagged, gate/remove the Donate button for the Play build via a
   `FeatureFlags`-style compile flag while keeping it for the (future) iOS build.
3. Consider Play's own supported donation options if eligibility applies.

Decision is intentionally left to the developer — this is documented, not
silently shipped.

## 3. Codebase review — weak areas & suggested improvements

Honest assessment of the current foundation and where to invest next.

**Strengths**
- Game rules are 100% pure Dart and unit-tested — fast to iterate and safe to
  refactor. Rendering is cleanly separated from logic.
- One design-token source; consistent rounded/gradient/soft-shadow identity.
- Save layer is schema-versioned with a cloud-save seam already in place.

**Weak areas / next steps**
1. **Adventure balancing is generated, not hand-tuned.** Levels are correct and
   beatable but their *feel* (fun difficulty spikes, mechanic teaching) deserves
   a manual pass with playtesting. The generator in `level_catalog.dart` is the
   right place to add explicit per-level overrides.
2. **No real assets yet.** Procedural candies and silent-safe audio are
   placeholders; drop real art/SFX into `assets/` (auto-picked up).
3. **In-progress run isn't yet serialised.** Stats/progression persist, but a
   half-finished board is lost on kill. Add a `GameEngine` snapshot to
   `PlayerData` (the models are ready for a `saveVersion` bump).
4. **Achievement unlock toasts** are computed but not yet surfaced live during
   play — wire a listener off `PlayerController` to show a celebration when a new
   id appears.
5. **Localization** currently ships English strings inline; extract to ARB and
   add the German translation (repo owner is German) via `flutter_localizations`.
6. **Performance:** wrap the board and effects layers in `RepaintBoundary` and
   profile with the DevTools timeline on a low-end device to confirm the 60 FPS
   budget under heavy combos.
7. **Widget/integration tests:** the domain is covered; add a golden test for
   the board painter and an integration test driving a full placement.

## 4. Optional (developer's call)
- Opt-in daily-challenge reminder notification.
- Opt-in crash reporting (Crashlytics) — keep it opt-in to preserve the
  "no data collected" stance, or omit entirely.
- In-app review prompt after a big win.
