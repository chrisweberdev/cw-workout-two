import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 20)
enum WorkoutType {
  @HiveField(0)
  strength,
  @HiveField(1)
  running,
  @HiveField(2)
  hiit,
}

extension WorkoutTypeExtension on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.strength:
        return 'Strength';
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.hiit:
        return 'HYROX HIIT';
    }
  }

  String get icon {
    switch (this) {
      case WorkoutType.strength:
        return '🏋️';
      case WorkoutType.running:
        return '🏃';
      case WorkoutType.hiit:
        return '⚡';
    }
  }
}

@HiveType(typeId: 21)
enum RunType {
  @HiveField(0)
  easy,
  @HiveField(1)
  hard,
  @HiveField(2)
  long,
  @HiveField(3)
  recovery,
  @HiveField(4)
  interval,
}

extension RunTypeExtension on RunType {
  String get displayName {
    switch (this) {
      case RunType.easy:
        return 'Easy Run';
      case RunType.hard:
        return 'Hard Run';
      case RunType.long:
        return 'Long Run';
      case RunType.recovery:
        return 'Recovery';
      case RunType.interval:
        return 'Intervals';
    }
  }

  IconData get icon {
    switch (this) {
      case RunType.easy:
        return Icons.directions_walk;
      case RunType.hard:
        return Icons.flash_on;
      case RunType.long:
        return Icons.route;
      case RunType.recovery:
        return Icons.self_improvement;
      case RunType.interval:
        return Icons.timer;
    }
  }

  int get targetRpeMin {
    switch (this) {
      case RunType.easy:
      case RunType.recovery:
        return 4;
      case RunType.long:
        return 5;
      case RunType.hard:
      case RunType.interval:
        return 7;
    }
  }

  int get targetRpeMax {
    switch (this) {
      case RunType.easy:
      case RunType.recovery:
        return 5;
      case RunType.long:
        return 5;
      case RunType.hard:
      case RunType.interval:
        return 8;
    }
  }
}

@HiveType(typeId: 22)
enum SuggestionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  accepted,
  @HiveField(2)
  declined,
}

@HiveType(typeId: 23)
enum ExerciseCategoryGroup {
  @HiveField(0)
  largeMuscleGroup,
  @HiveField(1)
  smallMuscleGroup,
}

extension ExerciseCategoryGroupExtension on ExerciseCategoryGroup {
  String get displayName {
    switch (this) {
      case ExerciseCategoryGroup.largeMuscleGroup:
        return 'Large Muscle Groups';
      case ExerciseCategoryGroup.smallMuscleGroup:
        return 'Small Muscle Groups';
    }
  }
}
