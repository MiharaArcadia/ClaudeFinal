/// Top-level meta-state controller (a [ChangeNotifier] used via Provider).
///
/// Owns the persisted [PlayerData] and exposes intent methods for the rest of
/// the app: applying game results, awarding XP/coins, levelling up, unlocking
/// cosmetics, managing the Ultra Blast bank and Stone Swap remap, and tracking
/// daily streaks. All mutations persist through the [SaveRepository].
library;

import 'package:flutter/foundation.dart';

import '../core/rng.dart';
import '../domain/candy.dart';
import '../domain/progression/achievements.dart';
import '../domain/progression/level_rewards.dart';
import '../domain/progression/xp_system.dart';
import '../domain/stone_swap.dart';
import '../domain/ultra_blast.dart';
import '../data/models.dart';
import '../data/save_repository.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

/// Describes what happened when XP was awarded (drives the level-up screen).
class LevelUpEvent {
  LevelUpEvent(this.newLevels, this.rewards);
  final List<int> newLevels;
  final List<LevelReward> rewards;
  bool get any => newLevels.isNotEmpty;
}

class PlayerController extends ChangeNotifier {
  PlayerController({
    required this.repository,
    required this.audio,
    required this.haptics,
  });

  final SaveRepository repository;
  final AudioService audio;
  final HapticService haptics;

  late PlayerData _data;
  bool _ready = false;

  bool get ready => _ready;
  Settings get settings => _data.settings;
  Stats get stats => _data.stats;
  Progress get progress => _data.progress;
  bool get tutorialSeen => _data.tutorialSeen;

  LevelState get levelState => XpSystem.resolve(_data.progress.totalXp);

  /// Loads persisted data and applies audio/haptic settings.
  Future<void> init() async {
    _data = await repository.load();
    audio.applyVolumes(
      music: settings.musicVolume,
      sound: settings.soundVolume,
    );
    haptics.setEnabled(enabled: settings.hapticsEnabled);
    _ready = true;
    _touchDailyStreak();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() => repository.save(_data);

  // --- Settings -------------------------------------------------------------

  Future<void> updateSettings(void Function(Settings s) mutate) async {
    mutate(_data.settings);
    audio.applyVolumes(
      music: settings.musicVolume,
      sound: settings.soundVolume,
    );
    haptics.setEnabled(enabled: settings.hapticsEnabled);
    notifyListeners();
    await _persist();
  }

  Future<void> markTutorialSeen() async {
    _data.tutorialSeen = true;
    notifyListeners();
    await _persist();
  }

  // --- XP / level-ups -------------------------------------------------------

  /// Awards [xp], returns a [LevelUpEvent] describing any levels gained and the
  /// rewards granted (coins always, plus milestone cosmetics).
  Future<LevelUpEvent> awardXp(int xp) async {
    final before = levelState.level;
    _data.progress.totalXp += xp;
    final after = levelState.level;

    final gainedLevels = <int>[];
    final rewards = <LevelReward>[];
    const table = LevelRewards();
    for (var l = before + 1; l <= after; l++) {
      gainedLevels.add(l);
      final levelRewards = table.forLevel(l);
      rewards.addAll(levelRewards);
      for (final r in levelRewards) {
        _applyReward(r);
      }
    }
    if (gainedLevels.isNotEmpty) {
      await haptics.fire(Haptic.success);
      await audio.play(Sfx.levelUp);
    }
    notifyListeners();
    await _persist();
    return LevelUpEvent(gainedLevels, rewards);
  }

  void _applyReward(LevelReward r) {
    switch (r.kind) {
      case RewardKind.coins:
        _data.progress.coins += r.amount;
      case RewardKind.candySkin:
      case RewardKind.background:
      case RewardKind.frame:
      case RewardKind.effect:
        final id = r.cosmeticId;
        if (id != null) _data.progress.unlockedCosmetics.add(id);
    }
  }

  // --- Cosmetics / shop -----------------------------------------------------

  bool isUnlocked(String cosmeticId) =>
      _data.progress.unlockedCosmetics.contains(cosmeticId);

  /// Attempts to buy a cosmetic for [cost] coins. Returns true on success.
  Future<bool> buyCosmetic(String cosmeticId, int cost) async {
    if (isUnlocked(cosmeticId)) return true;
    if (_data.progress.coins < cost) return false;
    _data.progress.coins -= cost;
    _data.progress.unlockedCosmetics.add(cosmeticId);
    await audio.play(Sfx.coin);
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> equip({
    String? skin,
    String? background,
    String? frame,
    String? effect,
  }) async {
    if (skin != null && isUnlocked(skin)) _data.progress.equippedSkin = skin;
    if (background != null && isUnlocked(background)) {
      _data.progress.equippedBackground = background;
    }
    if (frame != null && isUnlocked(frame)) {
      _data.progress.equippedFrame = frame;
    }
    if (effect != null && isUnlocked(effect)) {
      _data.progress.equippedEffect = effect;
    }
    notifyListeners();
    await _persist();
  }

  // --- Ultra Blast bank -----------------------------------------------------

  UltraBlastBank get ultraBank => UltraBlastBank(
        stored: _data.progress.ultraBlastStored,
        earnedToday: _data.progress.ultraBlastEarnedToday,
        windowStartEpochMs: _data.progress.ultraBlastWindowStartMs,
      );

  void _writeBank(UltraBlastBank bank) {
    _data.progress
      ..ultraBlastStored = bank.stored
      ..ultraBlastEarnedToday = bank.earnedToday
      ..ultraBlastWindowStartMs = bank.windowStartEpochMs;
  }

  /// Earns up to [count] Ultra Blasts (capped at 2/24h). Returns granted count.
  Future<int> earnUltraBlasts(int count) async {
    final bank = ultraBank;
    final granted = bank.earn(count, DateTime.now().millisecondsSinceEpoch);
    _writeBank(bank);
    _data.stats.ultraBlastsEarned += granted;
    notifyListeners();
    await _persist();
    return granted;
  }

  /// Spends one stored Ultra Blast. Returns true if one was available.
  Future<bool> spendUltraBlast() async {
    final bank = ultraBank;
    if (!bank.spend()) return false;
    _writeBank(bank);
    _data.stats.ultraBlastsUsed += 1;
    await audio.play(Sfx.ultraBlast);
    await haptics.fire(Haptic.heavy);
    notifyListeners();
    await _persist();
    return true;
  }

  // --- Stone Swap -----------------------------------------------------------

  CandyRemap get candyRemap {
    final map = <CandyType, CandyType>{};
    _data.progress.candyRemap.forEach((from, to) {
      map[_candyByName(from)] = _candyByName(to);
    });
    return CandyRemap(map);
  }

  Future<void> applyStoneSwap(CandyType from, CandyType to) async {
    _data.progress.candyRemap[from.name] = to.name;
    notifyListeners();
    await _persist();
  }

  CandyType _candyByName(String name) =>
      CandyType.values.firstWhere((c) => c.name == name);

  // --- Game results / stats -------------------------------------------------

  /// Records the outcome of any finished game. Updates stats, awards XP, and
  /// returns the [LevelUpEvent] so the caller can show the celebration.
  Future<LevelUpEvent> recordGameResult({
    required bool won,
    required int score,
    required int bestCombo,
    required int candiesCleared,
    required int xp,
    bool perfectLevel = false,
    bool adventureCompleted = false,
    bool challengeCompleted = false,
  }) async {
    final s = _data.stats;
    s.gamesPlayed += 1;
    if (won) s.gamesWon += 1;
    if (bestCombo > s.highestCombo) s.highestCombo = bestCombo;
    if (score > s.highestScore) s.highestScore = score;
    s.totalCandiesCleared += candiesCleared;
    if (perfectLevel) s.perfectLevels += 1;
    if (adventureCompleted) s.adventureLevelsCompleted += 1;
    if (challengeCompleted) s.challengeDaysCompleted += 1;

    notifyListeners();
    await _persist();
    return awardXp(xp);
  }

  /// Records the best star result for an Adventure level.
  Future<void> recordAdventureStars(int level, int stars) async {
    final current = _data.progress.adventureStars[level] ?? 0;
    if (stars > current) {
      _data.progress.adventureStars[level] = stars;
      notifyListeners();
      await _persist();
    }
  }

  int adventureStars(int level) => _data.progress.adventureStars[level] ?? 0;

  bool isAdventureLevelUnlocked(int level) =>
      level <= 1 || _data.progress.adventureStars.containsKey(level - 1);

  // --- Achievements ---------------------------------------------------------

  AchievementStats get achievementStats => AchievementStats(
        gamesWon: stats.gamesWon,
        highestCombo: stats.highestCombo,
        highestScore: stats.highestScore,
        totalCandiesCleared: stats.totalCandiesCleared,
        adventureLevelsCompleted: stats.adventureLevelsCompleted,
        challengeDaysCompleted: stats.challengeDaysCompleted,
        playerLevel: levelState.level,
        perfectLevels: stats.perfectLevels,
        dayStreak: stats.dayStreak,
      );

  Set<String> get unlockedAchievements =>
      Achievements.unlockedIds(achievementStats);

  // --- Daily streak ---------------------------------------------------------

  /// Updates the consecutive-day streak on each app open.
  void _touchDailyStreak() {
    final today = dailySeed(DateTime.now());
    final last = _data.stats.lastPlayedYmd;
    if (last == today) return;
    final yesterday = dailySeed(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    if (last == yesterday) {
      _data.stats.dayStreak += 1;
    } else if (last != 0) {
      _data.stats.dayStreak = 1;
    } else {
      _data.stats.dayStreak = 1;
    }
    _data.stats.lastPlayedYmd = today;
  }
}
