class AppSettings {
  final int delaySeconds;
  final int dailyLimit; // 0 = no limit
  final int simSlot; // 0 = SIM1, 1 = SIM2
  final bool isDarkMode;
  final String language; // 'ar' or 'en'

  const AppSettings({
    this.delaySeconds = 2,
    this.dailyLimit = 0,
    this.simSlot = 0,
    this.isDarkMode = true,
    this.language = 'ar',
  });

  AppSettings copyWith({
    int? delaySeconds,
    int? dailyLimit,
    int? simSlot,
    bool? isDarkMode,
    String? language,
  }) {
    return AppSettings(
      delaySeconds: delaySeconds ?? this.delaySeconds,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      simSlot: simSlot ?? this.simSlot,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() => {
        'delaySeconds': delaySeconds,
        'dailyLimit': dailyLimit,
        'simSlot': simSlot,
        'isDarkMode': isDarkMode,
        'language': language,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) => AppSettings(
        delaySeconds: (map['delaySeconds'] as int?) ?? 2,
        dailyLimit: (map['dailyLimit'] as int?) ?? 0,
        simSlot: (map['simSlot'] as int?) ?? 0,
        isDarkMode: (map['isDarkMode'] as bool?) ?? true,
        language: (map['language'] as String?) ?? 'ar',
      );
}
