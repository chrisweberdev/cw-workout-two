import 'package:hive/hive.dart';
import 'enums.dart';
import 'set_entry.dart';

part 'strength_session.g.dart';

@HiveType(typeId: 10)
class ExerciseRecord extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  List<SetEntry> sets;

  ExerciseRecord({
    required this.exerciseId,
    required this.sets,
  });

  double get totalVolume =>
      sets.fold(0.0, (sum, set) => sum + set.volume);

  int get totalReps =>
      sets.fold(0, (sum, set) => sum + set.repetitions);

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
    exerciseId: json['exerciseId'] as String,
    sets: (json['sets'] as List)
        .map((s) => SetEntry.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

@HiveType(typeId: 11)
class StrengthSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String? planId;

  @HiveField(3)
  List<ExerciseRecord> exercises;

  @HiveField(4)
  int rpe;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  String? userQuestions;

  @HiveField(7)
  int? durationMinutes;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  String? gptFeedbackId;

  StrengthSession({
    required this.id,
    required this.date,
    this.planId,
    required this.exercises,
    this.rpe = 7,
    this.notes,
    this.userQuestions,
    this.durationMinutes,
    this.isCompleted = false,
    this.gptFeedbackId,
  });

  WorkoutType get type => WorkoutType.strength;

  double get totalVolume =>
      exercises.fold(0.0, (sum, ex) => sum + ex.totalVolume);

  int get totalSets =>
      exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get totalReps =>
      exercises.fold(0, (sum, ex) => sum + ex.totalReps);

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'strength',
    'date': date.toIso8601String(),
    'planId': planId,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'rpe': rpe,
    'notes': notes,
    'userQuestions': userQuestions,
    'durationMinutes': durationMinutes,
    'isCompleted': isCompleted,
    'totalVolume': totalVolume,
    'totalSets': totalSets,
    'totalReps': totalReps,
  };

  factory StrengthSession.fromJson(Map<String, dynamic> json) => StrengthSession(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    planId: json['planId'] as String?,
    exercises: (json['exercises'] as List)
        .map((e) => ExerciseRecord.fromJson(e as Map<String, dynamic>))
        .toList(),
    rpe: json['rpe'] as int? ?? 7,
    notes: json['notes'] as String?,
    userQuestions: json['userQuestions'] as String?,
    durationMinutes: json['durationMinutes'] as int?,
    isCompleted: json['isCompleted'] as bool? ?? false,
    gptFeedbackId: json['gptFeedbackId'] as String?,
  );
}
