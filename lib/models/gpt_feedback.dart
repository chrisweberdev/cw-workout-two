import 'package:hive/hive.dart';
import 'enums.dart';

part 'gpt_feedback.g.dart';

@HiveType(typeId: 15)
class ProgressionSuggestion extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  double currentWeight;

  @HiveField(2)
  double suggestedWeight;

  @HiveField(3)
  int? currentReps;

  @HiveField(4)
  int? suggestedReps;

  @HiveField(5)
  String rationale;

  @HiveField(6)
  SuggestionStatus status;

  ProgressionSuggestion({
    required this.exerciseId,
    required this.currentWeight,
    required this.suggestedWeight,
    this.currentReps,
    this.suggestedReps,
    required this.rationale,
    this.status = SuggestionStatus.pending,
  });

  double get weightDifference => suggestedWeight - currentWeight;
  double get percentageIncrease => (weightDifference / currentWeight) * 100;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'currentWeight': currentWeight,
    'suggestedWeight': suggestedWeight,
    'currentReps': currentReps,
    'suggestedReps': suggestedReps,
    'rationale': rationale,
    'status': status.name,
  };

  factory ProgressionSuggestion.fromJson(Map<String, dynamic> json) =>
      ProgressionSuggestion(
        exerciseId: json['exerciseId'] as String,
        currentWeight: (json['currentWeight'] as num).toDouble(),
        suggestedWeight: (json['suggestedWeight'] as num).toDouble(),
        currentReps: json['currentReps'] as int?,
        suggestedReps: json['suggestedReps'] as int?,
        rationale: json['rationale'] as String,
        status: SuggestionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SuggestionStatus.pending,
        ),
      );
}

@HiveType(typeId: 16)
class GptFeedback extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sessionId;

  @HiveField(2)
  WorkoutType sessionType;

  @HiveField(3)
  DateTime receivedAt;

  @HiveField(4)
  String feedbackText;

  @HiveField(5)
  List<ProgressionSuggestion>? suggestions;

  @HiveField(6)
  bool allSuggestionsProcessed;

  GptFeedback({
    required this.id,
    required this.sessionId,
    required this.sessionType,
    required this.receivedAt,
    required this.feedbackText,
    this.suggestions,
    this.allSuggestionsProcessed = false,
  });

  int get pendingSuggestionsCount =>
      suggestions
          ?.where((s) => s.status == SuggestionStatus.pending)
          .length ?? 0;

  int get acceptedSuggestionsCount =>
      suggestions
          ?.where((s) => s.status == SuggestionStatus.accepted)
          .length ?? 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'sessionType': sessionType.name,
    'receivedAt': receivedAt.toIso8601String(),
    'feedbackText': feedbackText,
    'suggestions': suggestions?.map((s) => s.toJson()).toList(),
    'allSuggestionsProcessed': allSuggestionsProcessed,
  };

  factory GptFeedback.fromJson(Map<String, dynamic> json) => GptFeedback(
    id: json['id'] as String,
    sessionId: json['sessionId'] as String,
    sessionType: WorkoutType.values.firstWhere(
      (e) => e.name == json['sessionType'],
      orElse: () => WorkoutType.strength,
    ),
    receivedAt: DateTime.parse(json['receivedAt'] as String),
    feedbackText: json['feedbackText'] as String,
    suggestions: (json['suggestions'] as List?)
        ?.map((s) => ProgressionSuggestion.fromJson(s as Map<String, dynamic>))
        .toList(),
    allSuggestionsProcessed: json['allSuggestionsProcessed'] as bool? ?? false,
  );
}
