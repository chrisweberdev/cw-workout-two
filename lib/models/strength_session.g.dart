// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseRecordAdapter extends TypeAdapter<ExerciseRecord> {
  @override
  final int typeId = 10;

  @override
  ExerciseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseRecord(
      exerciseId: fields[0] as String,
      sets: (fields[1] as List).cast<SetEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StrengthSessionAdapter extends TypeAdapter<StrengthSession> {
  @override
  final int typeId = 11;

  @override
  StrengthSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StrengthSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      planId: fields[2] as String?,
      exercises: (fields[3] as List).cast<ExerciseRecord>(),
      rpe: fields[4] as int,
      notes: fields[5] as String?,
      userQuestions: fields[6] as String?,
      durationMinutes: fields[7] as int?,
      isCompleted: fields[8] as bool,
      gptFeedbackId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StrengthSession obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.planId)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.rpe)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.userQuestions)
      ..writeByte(7)
      ..write(obj.durationMinutes)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.gptFeedbackId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
