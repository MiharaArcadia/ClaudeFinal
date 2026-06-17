"""Generates the Carby pixel-art icon: a crab holding a banana and fries."""
from PIL import Image

SCALE = 16
GRID = 32

TRANSPARENT = (0, 0, 0, 0)
SHELL = (255, 107, 53, 255)       # --orange
SHELL_DARK = (214, 80, 30, 255)
EYE_WHITE = (255, 255, 255, 255)
EYE_BLACK = (20, 20, 20, 255)
CLAW = (233, 30, 99, 255)         # --pink
CLAW_DARK = (180, 20, 75, 255)
LEG = (214, 80, 30, 255)
BANANA = (255, 224, 102, 255)
BOX_RED = (217, 39, 39, 255)
BOX_RED_DARK = (170, 25, 25, 255)
BOX_WHITE = (250, 245, 235, 255)
FRY = (255, 196, 90, 255)
FRY_DARK = (224, 160, 60, 255)

def grid():
    return [[TRANSPARENT for _ in range(GRID)] for _ in range(GRID)]

def set_px(g, x, y, color):
    if 0 <= x < GRID and 0 <= y < GRID:
        g[y][x] = color

def rect(g, x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            set_px(g, x, y, color)

def main():
    g = grid()

    # ── Crab shell (body) ──────────────────────────────────────────
    rect(g, 12, 17, 24, 26, SHELL)
    rect(g, 12, 17, 24, 18, SHELL_DARK)          # top rim shading
    rect(g, 10, 19, 11, 26, SHELL_DARK)          # left side shadow
    rect(g, 25, 19, 26, 26, SHELL_DARK)          # right side shadow
    rect(g, 12, 19, 24, 26, SHELL)
    rect(g, 12, 17, 24, 17, SHELL_DARK)

    # eyes
    rect(g, 14, 20, 16, 22, EYE_WHITE)
    rect(g, 19, 20, 21, 22, EYE_WHITE)
    set_px(g, 15, 21, EYE_BLACK)
    set_px(g, 16, 21, EYE_BLACK)
    set_px(g, 20, 21, EYE_BLACK)
    set_px(g, 21, 21, EYE_BLACK)

    # legs (little zig-zags under the shell)
    for lx in (9, 12, 24, 27):
        rect(g, lx, 27, lx + 1, 28, LEG)
    for lx in (7, 29):
        rect(g, lx, 28, lx + 1, 29, LEG)

    # ── Left claw + arm → banana ───────────────────────────────────
    # forearm line rising from shoulder (top-left of shell) up to claw
    arm = [(11, 17), (10, 16), (9, 15), (8, 14), (8, 13), (7, 12), (7, 11)]
    for (x, y) in arm:
        rect(g, x, y, x + 1, y + 1, CLAW_DARK)
    # claw pincer
    rect(g, 4, 7, 9, 11, CLAW)
    rect(g, 4, 7, 9, 8, CLAW_DARK)
    rect(g, 3, 9, 5, 10, CLAW_DARK)
    rect(g, 8, 9, 10, 10, CLAW_DARK)

    # banana, diagonal curved shape
    banana_cells = [
        (2, 1), (3, 1), (3, 2), (4, 2), (4, 3), (5, 3), (5, 4), (6, 4),
        (6, 5), (7, 5), (7, 6), (8, 6), (8, 7), (9, 7), (9, 8), (10, 8),
        (4, 1), (5, 2), (6, 3), (7, 4), (8, 5), (9, 6), (10, 7), (11, 8),
    ]
    for (x, y) in banana_cells:
        set_px(g, x, y, BANANA)
    # banana tips
    set_px(g, 2, 1, FRY_DARK)
    set_px(g, 10, 8, FRY_DARK)
    set_px(g, 11, 8, FRY_DARK)

    # ── Right claw + arm → fries box ────────────────────────────────
    arm2 = [(25, 17), (26, 16), (26, 15), (27, 14), (27, 13), (27, 12), (27, 11)]
    for (x, y) in arm2:
        rect(g, x, y, x + 1, y + 1, CLAW_DARK)
    rect(g, 23, 7, 28, 11, CLAW)
    rect(g, 23, 7, 28, 8, CLAW_DARK)
    rect(g, 22, 9, 24, 10, CLAW_DARK)
    rect(g, 27, 9, 29, 10, CLAW_DARK)

    # fries box (trapezoid red carton)
    rect(g, 21, 9, 30, 14, BOX_RED)
    rect(g, 21, 9, 30, 9, BOX_RED_DARK)            # rim
    rect(g, 22, 14, 29, 14, BOX_RED_DARK)           # base shadow
    rect(g, 23, 10, 23, 13, BOX_WHITE)              # white stripe accents
    rect(g, 28, 10, 28, 13, BOX_WHITE)

    # fries sticking out the top
    fries = [
        (22, 4, 22, 8), (24, 2, 24, 8), (26, 3, 26, 8),
        (28, 1, 28, 8), (29, 5, 29, 8),
    ]
    for (x0, y0, x1, y1) in fries:
        rect(g, x0, y0, x1, y1, FRY)
        set_px(g, x0, y0, FRY_DARK)

    img = Image.new('RGBA', (GRID, GRID), TRANSPARENT)
    for y in range(GRID):
        for x in range(GRID):
            img.putpixel((x, y), g[y][x])

    big = img.resize((GRID * SCALE, GRID * SCALE), Image.NEAREST)
    big.save('/home/user/ClaudeFinal/electron/assets/icon.png')

    sizes = [16, 24, 32, 48, 64, 128, 256]
    icon_imgs = [img.resize((s, s), Image.NEAREST) for s in sizes]
    icon_imgs[-1].save(
        '/home/user/ClaudeFinal/electron/assets/icon.ico',
        format='ICO',
        sizes=[(s, s) for s in sizes],
    )
    print('Generated icon.png and icon.ico')

if __name__ == '__main__':
    main()
