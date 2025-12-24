// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 20;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.strength;
      case 1:
        return WorkoutType.running;
      case 2:
        return WorkoutType.hiit;
      default:
        return WorkoutType.strength;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.strength:
        writer.writeByte(0);
        break;
      case WorkoutType.running:
        writer.writeByte(1);
        break;
      case WorkoutType.hiit:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RunTypeAdapter extends TypeAdapter<RunType> {
  @override
  final int typeId = 21;

  @override
  RunType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RunType.easy;
      case 1:
        return RunType.hard;
      case 2:
        return RunType.long;
      case 3:
        return RunType.recovery;
      case 4:
        return RunType.interval;
      default:
        return RunType.easy;
    }
  }

  @override
  void write(BinaryWriter writer, RunType obj) {
    switch (obj) {
      case RunType.easy:
        writer.writeByte(0);
        break;
      case RunType.hard:
        writer.writeByte(1);
        break;
      case RunType.long:
        writer.writeByte(2);
        break;
      case RunType.recovery:
        writer.writeByte(3);
        break;
      case RunType.interval:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuggestionStatusAdapter extends TypeAdapter<SuggestionStatus> {
  @override
  final int typeId = 22;

  @override
  SuggestionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SuggestionStatus.pending;
      case 1:
        return SuggestionStatus.accepted;
      case 2:
        return SuggestionStatus.declined;
      default:
        return SuggestionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SuggestionStatus obj) {
    switch (obj) {
      case SuggestionStatus.pending:
        writer.writeByte(0);
        break;
      case SuggestionStatus.accepted:
        writer.writeByte(1);
        break;
      case SuggestionStatus.declined:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseCategoryGroupAdapter extends TypeAdapter<ExerciseCategoryGroup> {
  @override
  final int typeId = 23;

  @override
  ExerciseCategoryGroup read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseCategoryGroup.largeMuscleGroup;
      case 1:
        return ExerciseCategoryGroup.smallMuscleGroup;
      default:
        return ExerciseCategoryGroup.largeMuscleGroup;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseCategoryGroup obj) {
    switch (obj) {
      case ExerciseCategoryGroup.largeMuscleGroup:
        writer.writeByte(0);
        break;
      case ExerciseCategoryGroup.smallMuscleGroup:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCategoryGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
