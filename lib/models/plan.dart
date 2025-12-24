import 'package:hive/hive.dart';

part 'plan.g.dart';

@HiveType(typeId: 5)
class PlanExercise extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  int numSets;

  @HiveField(2)
  int repetitions;

  @HiveField(3)
  double weightKg;

  PlanExercise({
    required this.exerciseId,
    required this.numSets,
    required this.repetitions,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'numSets': numSets,
    'repetitions': repetitions,
    'weightKg': weightKg,
  };

  factory PlanExercise.fromJson(Map<String, dynamic> json) => PlanExercise(
    exerciseId: json['exerciseId'] as String,
    numSets: json['numSets'] as int,
    repetitions: json['repetitions'] as int,
    weightKg: (json['weightKg'] as num).toDouble(),
  );
}

@HiveType(typeId: 6)
class Plan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<PlanExercise> planExercises;

  @HiveField(3)
  bool isMain;

  Plan({
    required this.id,
    required this.name,
    required this.planExercises,
    this.isMain = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'planExercises': planExercises.map((e) => e.toJson()).toList(),
    'isMain': isMain,
  };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] as String,
    name: json['name'] as String,
    planExercises: (json['planExercises'] as List)
        .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    isMain: json['isMain'] as bool? ?? false,
  );
}
