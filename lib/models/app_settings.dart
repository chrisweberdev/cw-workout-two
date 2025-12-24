import 'package:hive/hive.dart';
import 'enums.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 17)
class AppSettings extends HiveObject {
  @HiveField(0)
  String? githubToken;

  @HiveField(1)
  String? githubRepoOwner;

  @HiveField(2)
  String? githubRepoName;

  @HiveField(3)
  bool isDarkMode;

  @HiveField(4)
  DateTime? lastSyncTime;

  @HiveField(5)
  String? customGptUrl;

  /// Weekly schedule: List of 7 items (Mon=0 to Sun=6)
  /// Each value is WorkoutType index (0=strength, 1=running, 2=hiit) or null for rest
  @HiveField(6)
  List<int?>? weeklySchedule;

  AppSettings({
    this.githubToken,
    this.githubRepoOwner,
    this.githubRepoName,
    this.isDarkMode = true,
    this.lastSyncTime,
    this.customGptUrl,
    this.weeklySchedule,
  });

  /// Get the planned workout type for a weekday (1=Monday to 7=Sunday)
  WorkoutType? getPlannedWorkout(int weekday) {
    if (weeklySchedule == null || weeklySchedule!.length != 7) return null;
    final index = weekday - 1; // Convert to 0-based
    final typeIndex = weeklySchedule![index];
    if (typeIndex == null) return null;
    return WorkoutType.values[typeIndex];
  }

  /// Set the planned workout type for a weekday (1=Monday to 7=Sunday)
  void setPlannedWorkout(int weekday, WorkoutType? type) {
    weeklySchedule ??= List.filled(7, null);
    weeklySchedule![weekday - 1] = type?.index;
  }

  /// Check if a schedule is configured
  bool get hasWeeklySchedule =>
      weeklySchedule != null &&
      weeklySchedule!.length == 7 &&
      weeklySchedule!.any((t) => t != null);

  bool get isGithubConfigured =>
      githubToken != null &&
      githubToken!.isNotEmpty &&
      githubRepoOwner != null &&
      githubRepoOwner!.isNotEmpty &&
      githubRepoName != null &&
      githubRepoName!.isNotEmpty;

  String get repoFullName => '$githubRepoOwner/$githubRepoName';

  Map<String, dynamic> toJson() => {
    'githubRepoOwner': githubRepoOwner,
    'githubRepoName': githubRepoName,
    'isDarkMode': isDarkMode,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
    'customGptUrl': customGptUrl,
    'weeklySchedule': weeklySchedule,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    githubRepoOwner: json['githubRepoOwner'] as String?,
    githubRepoName: json['githubRepoName'] as String?,
    isDarkMode: json['isDarkMode'] as bool? ?? true,
    lastSyncTime: json['lastSyncTime'] != null
        ? DateTime.parse(json['lastSyncTime'] as String)
        : null,
    customGptUrl: json['customGptUrl'] as String?,
    weeklySchedule: (json['weeklySchedule'] as List<dynamic>?)
        ?.map((e) => e as int?)
        .toList(),
  );
}
