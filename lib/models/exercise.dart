import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  bool isBodyweight;

  Exercise({
    required this.id,
    required this.name,
    required this.categoryId,
    this.isBodyweight = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'isBodyweight': isBodyweight,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    categoryId: json['categoryId'] as String,
    isBodyweight: json['isBodyweight'] as bool? ?? false,
  );
}
