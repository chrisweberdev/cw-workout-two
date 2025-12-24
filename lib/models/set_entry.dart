import 'package:hive/hive.dart';

part 'set_entry.g.dart';

@HiveType(typeId: 3)
class SetEntry extends HiveObject {
  @HiveField(0)
  int repetitions;

  @HiveField(1)
  double weightKg;

  @HiveField(2)
  int? plannedRepetitions;

  SetEntry({
    required this.repetitions,
    required this.weightKg,
    this.plannedRepetitions,
  });

  bool get exceededPlan =>
      plannedRepetitions != null && repetitions > plannedRepetitions!;
  int get extraReps =>
      plannedRepetitions != null ? repetitions - plannedRepetitions! : 0;

  double get volume => repetitions * weightKg;

  Map<String, dynamic> toJson() => {
    'repetitions': repetitions,
    'weightKg': weightKg,
    'plannedRepetitions': plannedRepetitions,
  };

  factory SetEntry.fromJson(Map<String, dynamic> json) => SetEntry(
    repetitions: json['repetitions'] as int,
    weightKg: (json['weightKg'] as num).toDouble(),
    plannedRepetitions: json['plannedRepetitions'] as int?,
  );
}
