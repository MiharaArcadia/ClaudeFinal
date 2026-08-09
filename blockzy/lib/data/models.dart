/// Serialisable persistence models. Plain data classes with JSON round-trips.
///
/// A single [PlayerData] aggregate is the save root; it carries a [saveVersion]
/// so future updates can migrate old saves without data loss.
library;

/// User-tunable settings.
class Settings {
  Settings({
    this.musicVolume = 0.7,
    this.soundVolume = 0.9,
    this.hapticsEnabled = true,
    this.highPerformanceMode = true,
    this.batterySaver = false,
    this.reducedMotion = false,
    this.colorBlindShapes = true,
    this.largeText = false,
    this.locale = 'en',
  });

  double musicVolume;
  double soundVolume;
  bool hapticsEnabled;
  bool highPerformanceMode;
  bool batterySaver;
  bool reducedMotion;
  bool colorBlindShapes;
  bool largeText;
  String locale;

  Map<String, dynamic> toJson() => {
        'musicVolume': musicVolume,
        'soundVolume': soundVolume,
        'hapticsEnabled': hapticsEnabled,
        'highPerformanceMode': highPerformanceMode,
        'batterySaver': batterySaver,
        'reducedMotion': reducedMotion,
        'colorBlindShapes': colorBlindShapes,
        'largeText': largeText,
        'locale': locale,
      };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
        musicVolume: (j['musicVolume'] as num?)?.toDouble() ?? 0.7,
        soundVolume: (j['soundVolume'] as num?)?.toDouble() ?? 0.9,
        hapticsEnabled: j['hapticsEnabled'] as bool? ?? true,
        highPerformanceMode: j['highPerformanceMode'] as bool? ?? true,
        batterySaver: j['batterySaver'] as bool? ?? false,
        reducedMotion: j['reducedMotion'] as bool? ?? false,
        colorBlindShapes: j['colorBlindShapes'] as bool? ?? true,
        largeText: j['largeText'] as bool? ?? false,
        locale: j['locale'] as String? ?? 'en',
      );
}

/// Lifetime statistics shown on the Statistics screen and fed to achievements.
class Stats {
  Stats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.highestCombo = 0,
    this.highestScore = 0,
    this.totalCandiesCleared = 0,
    this.adventureLevelsCompleted = 0,
    this.challengeDaysCompleted = 0,
    this.perfectLevels = 0,
    this.ultraBlastsEarned = 0,
    this.ultraBlastsUsed = 0,
    this.dayStreak = 0,
    this.lastPlayedYmd = 0,
  });

  int gamesPlayed;
  int gamesWon;
  int highestCombo;
  int highestScore;
  int totalCandiesCleared;
  int adventureLevelsCompleted;
  int challengeDaysCompleted;
  int perfectLevels;
  int ultraBlastsEarned;
  int ultraBlastsUsed;
  int dayStreak;

  /// Last calendar day the player was active (YYYYMMDD), for streak logic.
  int lastPlayedYmd;

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'highestCombo': highestCombo,
        'highestScore': highestScore,
        'totalCandiesCleared': totalCandiesCleared,
        'adventureLevelsCompleted': adventureLevelsCompleted,
        'challengeDaysCompleted': challengeDaysCompleted,
        'perfectLevels': perfectLevels,
        'ultraBlastsEarned': ultraBlastsEarned,
        'ultraBlastsUsed': ultraBlastsUsed,
        'dayStreak': dayStreak,
        'lastPlayedYmd': lastPlayedYmd,
      };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        gamesPlayed: j['gamesPlayed'] as int? ?? 0,
        gamesWon: j['gamesWon'] as int? ?? 0,
        highestCombo: j['highestCombo'] as int? ?? 0,
        highestScore: j['highestScore'] as int? ?? 0,
        totalCandiesCleared: j['totalCandiesCleared'] as int? ?? 0,
        adventureLevelsCompleted: j['adventureLevelsCompleted'] as int? ?? 0,
        challengeDaysCompleted: j['challengeDaysCompleted'] as int? ?? 0,
        perfectLevels: j['perfectLevels'] as int? ?? 0,
        ultraBlastsEarned: j['ultraBlastsEarned'] as int? ?? 0,
        ultraBlastsUsed: j['ultraBlastsUsed'] as int? ?? 0,
        dayStreak: j['dayStreak'] as int? ?? 0,
        lastPlayedYmd: j['lastPlayedYmd'] as int? ?? 0,
      );
}

/// Everything progression-related: XP, coins, cosmetics, adventure stars.
class Progress {
  Progress({
    this.totalXp = 0,
    this.coins = 0,
    Set<String>? unlockedCosmetics,
    Map<int, int>? adventureStars,
    this.equippedSkin = 'default',
    this.equippedBackground = 'default',
    this.equippedFrame = 'default',
    this.equippedEffect = 'default',
    this.ultraBlastStored = 0,
    this.ultraBlastEarnedToday = 0,
    this.ultraBlastWindowStartMs = 0,
    Map<String, String>? candyRemap,
  })  : unlockedCosmetics = unlockedCosmetics ?? {'default'},
        adventureStars = adventureStars ?? {},
        candyRemap = candyRemap ?? {};

  int totalXp;
  int coins;
  Set<String> unlockedCosmetics;

  /// Level number -> best star count (0..3).
  Map<int, int> adventureStars;

  String equippedSkin;
  String equippedBackground;
  String equippedFrame;
  String equippedEffect;

  int ultraBlastStored;
  int ultraBlastEarnedToday;
  int ultraBlastWindowStartMs;

  /// Persisted Stone Swap remap: CandyType.name -> CandyType.name.
  Map<String, String> candyRemap;

  int get highestAdventureLevel =>
      adventureStars.keys.isEmpty ? 0 : adventureStars.keys.reduce((a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'coins': coins,
        'unlockedCosmetics': unlockedCosmetics.toList(),
        'adventureStars':
            adventureStars.map((k, v) => MapEntry(k.toString(), v)),
        'equippedSkin': equippedSkin,
        'equippedBackground': equippedBackground,
        'equippedFrame': equippedFrame,
        'equippedEffect': equippedEffect,
        'ultraBlastStored': ultraBlastStored,
        'ultraBlastEarnedToday': ultraBlastEarnedToday,
        'ultraBlastWindowStartMs': ultraBlastWindowStartMs,
        'candyRemap': candyRemap,
      };

  factory Progress.fromJson(Map<String, dynamic> j) => Progress(
        totalXp: j['totalXp'] as int? ?? 0,
        coins: j['coins'] as int? ?? 0,
        unlockedCosmetics: ((j['unlockedCosmetics'] as List?) ?? ['default'])
            .map((e) => e as String)
            .toSet(),
        adventureStars: ((j['adventureStars'] as Map?) ?? {}).map(
          (k, v) => MapEntry(int.parse(k as String), v as int),
        ),
        equippedSkin: j['equippedSkin'] as String? ?? 'default',
        equippedBackground: j['equippedBackground'] as String? ?? 'default',
        equippedFrame: j['equippedFrame'] as String? ?? 'default',
        equippedEffect: j['equippedEffect'] as String? ?? 'default',
        ultraBlastStored: j['ultraBlastStored'] as int? ?? 0,
        ultraBlastEarnedToday: j['ultraBlastEarnedToday'] as int? ?? 0,
        ultraBlastWindowStartMs: j['ultraBlastWindowStartMs'] as int? ?? 0,
        candyRemap: ((j['candyRemap'] as Map?) ?? {})
            .map((k, v) => MapEntry(k as String, v as String)),
      );
}

/// The save-root aggregate.
class PlayerData {
  PlayerData({
    this.saveVersion = currentSaveVersion,
    Settings? settings,
    Stats? stats,
    Progress? progress,
    this.tutorialSeen = false,
  })  : settings = settings ?? Settings(),
        stats = stats ?? Stats(),
        progress = progress ?? Progress();

  /// Bump when the on-disk schema changes; [SaveRepository] migrates on load.
  static const int currentSaveVersion = 1;

  int saveVersion;
  Settings settings;
  Stats stats;
  Progress progress;
  bool tutorialSeen;

  Map<String, dynamic> toJson() => {
        'saveVersion': saveVersion,
        'settings': settings.toJson(),
        'stats': stats.toJson(),
        'progress': progress.toJson(),
        'tutorialSeen': tutorialSeen,
      };

  factory PlayerData.fromJson(Map<String, dynamic> j) => PlayerData(
        saveVersion: j['saveVersion'] as int? ?? 1,
        settings:
            Settings.fromJson((j['settings'] as Map?)?.cast() ?? const {}),
        stats: Stats.fromJson((j['stats'] as Map?)?.cast() ?? const {}),
        progress:
            Progress.fromJson((j['progress'] as Map?)?.cast() ?? const {}),
        tutorialSeen: j['tutorialSeen'] as bool? ?? false,
      );
}
