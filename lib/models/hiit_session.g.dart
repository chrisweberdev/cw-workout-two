// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiit_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiitSessionAdapter extends TypeAdapter<HiitSession> {
  @override
  final int typeId = 13;

  @override
  HiitSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiitSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      workoutDescription: fields[2] as String?,
      durationMinutes: fields[3] as int?,
      stations: (fields[4] as List?)?.cast<String>(),
      rpe: fields[5] as int,
      notes: fields[6] as String?,
      userQuestions: fields[7] as String?,
      screenshotBase64: fields[8] as String?,
      gptFeedbackId: fields[9] as String?,
      isCompleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiitSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.workoutDescription)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.stations)
      ..writeByte(5)
      ..write(obj.rpe)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.userQuestions)
      ..writeByte(8)
      ..write(obj.screenshotBase64)
      ..writeByte(9)
      ..write(obj.gptFeedbackId)
      ..writeByte(10)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiitSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
