// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlanExerciseAdapter extends TypeAdapter<PlanExercise> {
  @override
  final int typeId = 5;

  @override
  PlanExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanExercise(
      exerciseId: fields[0] as String,
      numSets: fields[1] as int,
      repetitions: fields[2] as int,
      weightKg: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PlanExercise obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.numSets)
      ..writeByte(2)
      ..write(obj.repetitions)
      ..writeByte(3)
      ..write(obj.weightKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlanAdapter extends TypeAdapter<Plan> {
  @override
  final int typeId = 6;

  @override
  Plan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plan(
      id: fields[0] as String,
      name: fields[1] as String,
      planExercises: (fields[2] as List).cast<PlanExercise>(),
      isMain: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Plan obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.planExercises)
      ..writeByte(3)
      ..write(obj.isMain);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
