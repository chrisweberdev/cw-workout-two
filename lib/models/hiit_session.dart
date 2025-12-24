import 'package:hive/hive.dart';
import 'enums.dart';

part 'hiit_session.g.dart';

@HiveType(typeId: 13)
class HiitSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String? workoutDescription;

  @HiveField(3)
  int? durationMinutes;

  @HiveField(4)
  List<String>? stations;

  @HiveField(5)
  int rpe;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  String? userQuestions;

  @HiveField(8)
  String? screenshotBase64;

  @HiveField(9)
  String? gptFeedbackId;

  @HiveField(10)
  bool isCompleted;

  HiitSession({
    required this.id,
    required this.date,
    this.workoutDescription,
    this.durationMinutes,
    this.stations,
    this.rpe = 8,
    this.notes,
    this.userQuestions,
    this.screenshotBase64,
    this.gptFeedbackId,
    this.isCompleted = false,
  });

  WorkoutType get type => WorkoutType.hiit;

  String get durationFormatted {
    if (durationMinutes == null) return '--:--';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'hiit',
    'date': date.toIso8601String(),
    'workoutDescription': workoutDescription,
    'durationMinutes': durationMinutes,
    'stations': stations,
    'rpe': rpe,
    'notes': notes,
    'userQuestions': userQuestions,
    'screenshotBase64': screenshotBase64,
    'isCompleted': isCompleted,
  };

  factory HiitSession.fromJson(Map<String, dynamic> json) => HiitSession(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    workoutDescription: json['workoutDescription'] as String?,
    durationMinutes: json['durationMinutes'] as int?,
    stations: (json['stations'] as List?)?.cast<String>(),
    rpe: json['rpe'] as int? ?? 8,
    notes: json['notes'] as String?,
    userQuestions: json['userQuestions'] as String?,
    screenshotBase64: json['screenshotBase64'] as String?,
    gptFeedbackId: json['gptFeedbackId'] as String?,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
