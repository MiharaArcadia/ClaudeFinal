class UserProfile {
  final String uid;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String goal; // 'lose' | 'maintain' | 'gain'
  final String language; // 'de' | 'en'
  final String themeMode; // 'system' | 'light' | 'dark'
  int dailyCalorieGoal;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.language,
    this.themeMode = 'system',
    required this.dailyCalorieGoal,
  });

  static int calculateTDEE({
    required double weight,
    required double height,
    required int age,
    required String goal,
  }) {
    // Mifflin-St Jeor (male default, can extend later)
    final bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    final tdee = (bmr * 1.55).round(); // moderately active
    return switch (goal) {
      'lose' => tdee - 500,
      'gain' => tdee + 300,
      _ => tdee,
    };
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
        'language': language,
        'themeMode': themeMode,
        'dailyCalorieGoal': dailyCalorieGoal,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        age: (m['age'] as num?)?.toInt() ?? 25,
        weight: (m['weight'] as num?)?.toDouble() ?? 70,
        height: (m['height'] as num?)?.toDouble() ?? 175,
        goal: m['goal'] ?? 'maintain',
        language: m['language'] ?? 'de',
        themeMode: m['themeMode'] ?? 'system',
        dailyCalorieGoal: (m['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
      );

  UserProfile copyWith({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? goal,
    String? language,
    String? themeMode,
    int? dailyCalorieGoal,
  }) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        age: age ?? this.age,
        weight: weight ?? this.weight,
        height: height ?? this.height,
        goal: goal ?? this.goal,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      );
}
