// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_scan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyScanAdapter extends TypeAdapter<BodyScan> {
  @override
  final int typeId = 14;

  @override
  BodyScan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyScan(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double,
      bodyFatPercent: fields[3] as double?,
      muscleMassKg: fields[4] as double?,
      notes: fields[5] as String?,
      muscleBreakdown: (fields[6] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, BodyScan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.bodyFatPercent)
      ..writeByte(4)
      ..write(obj.muscleMassKg)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.muscleBreakdown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyScanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
