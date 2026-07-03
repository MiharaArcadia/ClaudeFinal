# Candy assets (auto-discovered)

Put the real candy art in **this folder** — `blockzy/assets/candies/` — as image
files (`.png`, `.webp`, `.jpg`). They are bundled and auto-mapped to the seven
candy types. Recommended: square, transparent background, ~256×256 or 512×512.

> ⚠️ Location matters. Flutter only bundles assets **inside** the Flutter project
> (`blockzy/`). Files placed at the repository root's `assets/` (e.g.
> `X:\Programming\Blockzy\assets\candies`) are **not** picked up — copy them into
> `X:\Programming\Blockzy\blockzy\assets\candies\` and commit them so both local
> and CI builds include them.

## Naming — any of these work

`CandyAssetLoader` (lib/services/asset_loader.dart) reads the asset manifest and
matches whatever it finds, in three passes:

1. **Exact** (recommended, zero ambiguity):
   ```
   candy_strawberry.png  candy_lemon.png     candy_blueberry.png
   candy_lime.png        candy_grape.png     candy_orange.png
   candy_mint.png
   ```
2. **Colour keyword** — e.g. `red`, `yellow`, `blue`, `green`, `purple`,
   `orange`, `teal` (case-insensitive, substring match).
3. **Sorted-order fallback** — numbered files like `1.png … 7.png` are assigned
   to the candy types in order.

Type → colour/keyword reference:

| Candy       | Colour | Keywords               |
|-------------|--------|------------------------|
| strawberry  | red    | strawberry, red, berry |
| lemon       | yellow | lemon, yellow          |
| blueberry   | blue   | blueberry, blue        |
| lime        | green  | lime, green            |
| grape       | purple | grape, purple, violet  |
| orange      | orange | orange                 |
| mint        | teal   | mint, teal, cyan       |

Any candy **without** a matching file is drawn as a procedural candy (distinct
colour AND shape), so the game is always fully playable and colour-blind-friendly.
Copying finished art here requires **zero code changes**.
