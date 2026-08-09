# Audio assets (optional, hot-swappable)

Drop sound files here; `AudioService` looks them up by name and silently no-ops
if a file is missing (so the game never crashes without audio):

    ui_click.wav     candy_pop.wav    line_clear.wav   combo.wav
    victory.wav      failure.wav      level_up.wav     ultra_blast.wav
    coin.wav         ambient_loop.mp3

Short, punchy SFX (< 0.5s) feel best. Keep the ambient loop subtle.
