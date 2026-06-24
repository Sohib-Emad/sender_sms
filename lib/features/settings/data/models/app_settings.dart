import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final int delaySeconds;
  final int dailyLimit; // 0 = no limit
  final int simSlot; // 0 = SIM1, 1 = SIM2
  final String language; // 'ar' or 'en'

  const AppSettings({
    this.delaySeconds = 2,
    this.dailyLimit = 0,
    this.simSlot = 0,
    this.language = 'ar',
  });

  AppSettings copyWith({
    int? delaySeconds,
    int? dailyLimit,
    int? simSlot,
    String? language,
  }) =>
      AppSettings(
        delaySeconds: delaySeconds ?? this.delaySeconds,
        dailyLimit: dailyLimit ?? this.dailyLimit,
        simSlot: simSlot ?? this.simSlot,
        language: language ?? this.language,
      );

  Map<String, dynamic> toMap() => {
        'delaySeconds': delaySeconds,
        'dailyLimit': dailyLimit,
        'simSlot': simSlot,
        'language': language,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) => AppSettings(
        delaySeconds: (map['delaySeconds'] as int?) ?? 2,
        dailyLimit: (map['dailyLimit'] as int?) ?? 0,
        simSlot: (map['simSlot'] as int?) ?? 0,
        language: (map['language'] as String?) ?? 'ar',
      );

  @override
  List<Object?> get props => [delaySeconds, dailyLimit, simSlot, language];
}
