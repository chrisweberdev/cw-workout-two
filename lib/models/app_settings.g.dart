// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 17;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      githubToken: fields[0] as String?,
      githubRepoOwner: fields[1] as String?,
      githubRepoName: fields[2] as String?,
      isDarkMode: fields[3] as bool,
      lastSyncTime: fields[4] as DateTime?,
      customGptUrl: fields[5] as String?,
      weeklySchedule: (fields[6] as List?)?.cast<int?>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.githubToken)
      ..writeByte(1)
      ..write(obj.githubRepoOwner)
      ..writeByte(2)
      ..write(obj.githubRepoName)
      ..writeByte(3)
      ..write(obj.isDarkMode)
      ..writeByte(4)
      ..write(obj.lastSyncTime)
      ..writeByte(5)
      ..write(obj.customGptUrl)
      ..writeByte(6)
      ..write(obj.weeklySchedule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
