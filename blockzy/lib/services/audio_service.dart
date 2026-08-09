/// Audio playback for SFX and music, with a graceful fallback: if an audio
/// asset file is missing (e.g. before the real sounds are dropped in), calls
/// silently no-op instead of crashing.
///
/// Real audio drops into `assets/audio/`; the keys below map to file names.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Logical sound effects. The [file] is looked up under `assets/audio/`.
enum Sfx {
  uiClick('ui_click.wav'),
  candyPop('candy_pop.wav'),
  lineClear('line_clear.wav'),
  combo('combo.wav'),
  victory('victory.wav'),
  failure('failure.wav'),
  levelUp('level_up.wav'),
  ultraBlast('ultra_blast.wav'),
  coin('coin.wav');

  const Sfx(this.file);
  final String file;
}

class AudioService {
  AudioService();

  final AudioPlayer _music = AudioPlayer(playerId: 'blockzy_music');
  // A small pool avoids cutting off overlapping SFX (e.g. rapid pops).
  final List<AudioPlayer> _sfxPool =
      List.generate(4, (i) => AudioPlayer(playerId: 'blockzy_sfx_$i'));
  int _poolCursor = 0;

  double _musicVolume = 0.7;
  double _soundVolume = 0.9;
  bool _musicMissing = false;

  void applyVolumes({required double music, required double sound}) {
    _musicVolume = music.clamp(0, 1);
    _soundVolume = sound.clamp(0, 1);
    _music.setVolume(_musicVolume);
  }

  /// Plays a one-shot sound effect. No-ops on any failure (missing file, etc.).
  Future<void> play(Sfx sfx) async {
    if (_soundVolume <= 0) return;
    final player = _sfxPool[_poolCursor];
    _poolCursor = (_poolCursor + 1) % _sfxPool.length;
    try {
      await player.stop();
      await player.setVolume(_soundVolume);
      await player.play(AssetSource('audio/${sfx.file}'));
    } catch (e) {
      // Asset likely absent — stay silent, log once in debug.
      if (kDebugMode) debugPrint('[audio] sfx ${sfx.file} skipped: $e');
    }
  }

  /// Starts the ambient background loop if available.
  Future<void> startMusic({String file = 'ambient_loop.mp3'}) async {
    if (_musicMissing || _musicVolume <= 0) return;
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(_musicVolume);
      await _music.play(AssetSource('audio/$file'));
    } catch (e) {
      _musicMissing = true; // don't keep retrying a missing file
      if (kDebugMode) debugPrint('[audio] music $file skipped: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _music.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (_musicMissing || _musicVolume <= 0) return;
    try {
      await _music.resume();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _music.dispose();
    for (final p in _sfxPool) {
      await p.dispose();
    }
  }
}
