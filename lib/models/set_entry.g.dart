// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetEntryAdapter extends TypeAdapter<SetEntry> {
  @override
  final int typeId = 3;

  @override
  SetEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetEntry(
      repetitions: fields[0] as int,
      weightKg: fields[1] as double,
      plannedRepetitions: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SetEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.repetitions)
      ..writeByte(1)
      ..write(obj.weightKg)
      ..writeByte(2)
      ..write(obj.plannedRepetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
