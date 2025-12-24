import 'package:hive/hive.dart';
import 'enums.dart';

part 'running_session.g.dart';

@HiveType(typeId: 12)
class RunningSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  RunType runType;

  @HiveField(3)
  double? distanceKm;

  @HiveField(4)
  int? durationMinutes;

  @HiveField(5)
  double? paceMinPerKm;

  @HiveField(6)
  int rpe;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? userQuestions;

  @HiveField(9)
  String? screenshotBase64;

  @HiveField(10)
  String? runnaWorkoutText;

  @HiveField(11)
  String? gptFeedbackId;

  @HiveField(12)
  bool isCompleted;

  RunningSession({
    required this.id,
    required this.date,
    required this.runType,
    this.distanceKm,
    this.durationMinutes,
    this.paceMinPerKm,
    this.rpe = 5,
    this.notes,
    this.userQuestions,
    this.screenshotBase64,
    this.runnaWorkoutText,
    this.gptFeedbackId,
    this.isCompleted = false,
  });

  WorkoutType get type => WorkoutType.running;

  String get paceFormatted {
    if (paceMinPerKm == null) return '--:--';
    final minutes = paceMinPerKm!.floor();
    final seconds = ((paceMinPerKm! - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationFormatted {
    if (durationMinutes == null) return '--:--';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  bool get isHardSession =>
      runType == RunType.hard || runType == RunType.interval;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'running',
    'date': date.toIso8601String(),
    'runType': runType.name,
    'distanceKm': distanceKm,
    'durationMinutes': durationMinutes,
    'paceMinPerKm': paceMinPerKm,
    'rpe': rpe,
    'notes': notes,
    'userQuestions': userQuestions,
    'screenshotBase64': screenshotBase64,
    'runnaWorkoutText': runnaWorkoutText,
    'isCompleted': isCompleted,
  };

  factory RunningSession.fromJson(Map<String, dynamic> json) => RunningSession(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    runType: RunType.values.firstWhere(
      (e) => e.name == json['runType'],
      orElse: () => RunType.easy,
    ),
    distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    durationMinutes: json['durationMinutes'] as int?,
    paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
    rpe: json['rpe'] as int? ?? 5,
    notes: json['notes'] as String?,
    userQuestions: json['userQuestions'] as String?,
    screenshotBase64: json['screenshotBase64'] as String?,
    runnaWorkoutText: json['runnaWorkoutText'] as String?,
    gptFeedbackId: json['gptFeedbackId'] as String?,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
