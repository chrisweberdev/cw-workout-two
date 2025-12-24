import 'package:hive/hive.dart';

part 'body_scan.g.dart';

@HiveType(typeId: 14)
class BodyScan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  double? bodyFatPercent;

  @HiveField(4)
  double? muscleMassKg;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  Map<String, double>? muscleBreakdown;

  BodyScan({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.notes,
    this.muscleBreakdown,
  });

  double? get leanMassKg {
    if (bodyFatPercent == null) return null;
    return weightKg * (1 - bodyFatPercent! / 100);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weightKg': weightKg,
    'bodyFatPercent': bodyFatPercent,
    'muscleMassKg': muscleMassKg,
    'notes': notes,
    'muscleBreakdown': muscleBreakdown,
  };

  factory BodyScan.fromJson(Map<String, dynamic> json) => BodyScan(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    weightKg: (json['weightKg'] as num).toDouble(),
    bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
    muscleMassKg: (json['muscleMassKg'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    muscleBreakdown: (json['muscleBreakdown'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, (v as num).toDouble())),
  );
}
