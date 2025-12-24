import 'package:hive/hive.dart';
import 'enums.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  ExerciseCategoryGroup? group;

  Category({
    required this.id,
    required this.name,
    this.group,
  }) {
    group ??= ExerciseCategoryGroup.largeMuscleGroup;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'group': group?.name,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    group: json['group'] != null
        ? ExerciseCategoryGroup.values.firstWhere((e) => e.name == json['group'])
        : null,
  );
}
