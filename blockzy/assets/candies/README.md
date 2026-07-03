# Candy assets (auto-swap)

Drop the real candy art here as PNGs named after each candy type:

    candy_strawberry.png   candy_lemon.png    candy_blueberry.png
    candy_lime.png         candy_grape.png    candy_orange.png
    candy_mint.png

Recommended: square, transparent background, ~256×256 or 512×512.

## How it works

On startup `CandyAssetLoader` (lib/services/asset_loader.dart) tries to decode
each file. If present, it is drawn on the board and in the tray. If absent, the
game paints a **procedural candy** with a distinct colour AND shape per type, so
the game is fully playable right now and colour-blind-friendly.

Copying the finished art from `X:\Programming\Blockzy\assets` into this folder
requires **zero code changes** — the loader picks it up automatically. If you add
new files, keep them listed under `assets/candies/` in `pubspec.yaml` (a folder
entry already covers this).
