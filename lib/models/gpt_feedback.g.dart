// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpt_feedback.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressionSuggestionAdapter extends TypeAdapter<ProgressionSuggestion> {
  @override
  final int typeId = 15;

  @override
  ProgressionSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressionSuggestion(
      exerciseId: fields[0] as String,
      currentWeight: fields[1] as double,
      suggestedWeight: fields[2] as double,
      currentReps: fields[3] as int?,
      suggestedReps: fields[4] as int?,
      rationale: fields[5] as String,
      status: fields[6] as SuggestionStatus,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressionSuggestion obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.currentWeight)
      ..writeByte(2)
      ..write(obj.suggestedWeight)
      ..writeByte(3)
      ..write(obj.currentReps)
      ..writeByte(4)
      ..write(obj.suggestedReps)
      ..writeByte(5)
      ..write(obj.rationale)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressionSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GptFeedbackAdapter extends TypeAdapter<GptFeedback> {
  @override
  final int typeId = 16;

  @override
  GptFeedback read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GptFeedback(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      sessionType: fields[2] as WorkoutType,
      receivedAt: fields[3] as DateTime,
      feedbackText: fields[4] as String,
      suggestions: (fields[5] as List?)?.cast<ProgressionSuggestion>(),
      allSuggestionsProcessed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GptFeedback obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.sessionType)
      ..writeByte(3)
      ..write(obj.receivedAt)
      ..writeByte(4)
      ..write(obj.feedbackText)
      ..writeByte(5)
      ..write(obj.suggestions)
      ..writeByte(6)
      ..write(obj.allSuggestionsProcessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GptFeedbackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
