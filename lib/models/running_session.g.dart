// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunningSessionAdapter extends TypeAdapter<RunningSession> {
  @override
  final int typeId = 12;

  @override
  RunningSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunningSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      runType: fields[2] as RunType,
      distanceKm: fields[3] as double?,
      durationMinutes: fields[4] as int?,
      paceMinPerKm: fields[5] as double?,
      rpe: fields[6] as int,
      notes: fields[7] as String?,
      userQuestions: fields[8] as String?,
      screenshotBase64: fields[9] as String?,
      runnaWorkoutText: fields[10] as String?,
      gptFeedbackId: fields[11] as String?,
      isCompleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RunningSession obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.runType)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.paceMinPerKm)
      ..writeByte(6)
      ..write(obj.rpe)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.userQuestions)
      ..writeByte(9)
      ..write(obj.screenshotBase64)
      ..writeByte(10)
      ..write(obj.runnaWorkoutText)
      ..writeByte(11)
      ..write(obj.gptFeedbackId)
      ..writeByte(12)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunningSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
