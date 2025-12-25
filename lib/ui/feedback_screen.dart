import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models/gpt_feedback.dart';
import '../models/exercise.dart';
import '../models/enums.dart';

class FeedbackScreen extends StatefulWidget {
  final Repository repository;

  const FeedbackScreen({super.key, required this.repository});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  WorkoutType? _filterType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allFeedback = widget.repository.getAllGptFeedback();
    final filteredFeedback = _filterType == null
        ? allFeedback
        : allFeedback.where((f) => f.sessionType == _filterType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coaching Feedback'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterType == null,
                    onSelected: (_) => setState(() => _filterType = null),
                  ),
                  const SizedBox(width: 8),
                  ...WorkoutType.values.map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: _filterType == type,
                      onSelected: (_) => setState(() => _filterType = type),
                    ),
                  )),
                ],
              ),
            ),
          ),
          // Feedback list
          Expanded(
            child: filteredFeedback.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFeedback.length,
                    itemBuilder: (context, index) {
                      final feedback = filteredFeedback[index];
                      return _buildFeedbackCard(theme, feedback);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No AI feedback yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a workout and sync to get coaching feedback',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ThemeData theme, GptFeedback feedback) {
    final exercises = widget.repository.getAllExercises();
    final hasPendingSuggestions = feedback.pendingSuggestionsCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showFeedbackDetail(feedback),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildWorkoutTypeBadge(theme, feedback.sessionType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(feedback.receivedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (hasPendingSuggestions)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pending_actions,
                            size: 14,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${feedback.pendingSuggestionsCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Feedback preview
              Text(
                feedback.feedbackText.length > 150
                    ? '${feedback.feedbackText.substring(0, 150)}...'
                    : feedback.feedbackText,
                style: theme.textTheme.bodyMedium,
              ),
              // Suggestions preview
              if (feedback.suggestions != null && feedback.suggestions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Progression Suggestions:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...feedback.suggestions!.take(2).map((suggestion) {
                  final exercise = exercises.firstWhere(
                    (e) => e.id == suggestion.exerciseId,
                    orElse: () => Exercise(id: '', name: 'Unknown', categoryId: ''),
                  );
                  return _buildSuggestionPreview(theme, suggestion, exercise);
                }),
                if (feedback.suggestions!.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${feedback.suggestions!.length - 2} more suggestions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              // View details button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showFeedbackDetail(feedback),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutTypeBadge(ThemeData theme, WorkoutType type) {
    final Color color;
    final IconData icon;
    switch (type) {
      case WorkoutType.strength:
        color = theme.colorScheme.primary;
        icon = Icons.fitness_center;
        break;
      case WorkoutType.running:
        color = theme.colorScheme.secondary;
        icon = Icons.directions_run;
        break;
      case WorkoutType.hiit:
        color = theme.colorScheme.tertiary;
        icon = Icons.flash_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPreview(
    ThemeData theme,
    ProgressionSuggestion suggestion,
    Exercise exercise,
  ) {
    final statusColor = switch (suggestion.status) {
      SuggestionStatus.pending => Colors.orange,
      SuggestionStatus.accepted => Colors.green,
      SuggestionStatus.declined => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            suggestion.status == SuggestionStatus.pending
                ? Icons.circle_outlined
                : (suggestion.status == SuggestionStatus.accepted
                    ? Icons.check_circle
                    : Icons.cancel),
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exercise.name,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            '${suggestion.currentWeight.toStringAsFixed(0)} → ${suggestion.suggestedWeight.toStringAsFixed(0)} kg',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showFeedbackDetail(GptFeedback feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackDetailScreen(
          repository: widget.repository,
          feedback: feedback,
        ),
      ),
    ).then((_) => setState(() {}));
  }
}

class FeedbackDetailScreen extends StatefulWidget {
  final Repository repository;
  final GptFeedback feedback;

  const FeedbackDetailScreen({
    super.key,
    required this.repository,
    required this.feedback,
  });

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = widget.repository.getAllExercises();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.feedback.sessionType.displayName} Feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date and type
          Card(
            child: ListTile(
              leading: Icon(
                _getTypeIcon(widget.feedback.sessionType),
                color: theme.colorScheme.primary,
              ),
              title: Text(widget.feedback.sessionType.displayName),
              subtitle: Text(_formatDateTime(widget.feedback.receivedAt)),
            ),
          ),
          const SizedBox(height: 16),

          // Feedback text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'AI Coach Feedback',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.feedback.feedbackText,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progression suggestions
          if (widget.feedback.suggestions != null &&
              widget.feedback.suggestions!.isNotEmpty) ...[
            Text(
              'Progression Suggestions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.feedback.suggestions!.map((suggestion) {
              final exercise = exercises.firstWhere(
                (e) => e.id == suggestion.exerciseId,
                orElse: () => Exercise(id: '', name: 'Unknown', categoryId: ''),
              );
              return _buildSuggestionCard(theme, suggestion, exercise);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    ThemeData theme,
    ProgressionSuggestion suggestion,
    Exercise exercise,
  ) {
    final isPending = suggestion.status == SuggestionStatus.pending;
    final statusColor = switch (suggestion.status) {
      SuggestionStatus.pending => Colors.orange,
      SuggestionStatus.accepted => Colors.green,
      SuggestionStatus.declined => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suggestion.status.name.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weight change
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '${suggestion.currentWeight.toStringAsFixed(1)} kg',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Current',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${suggestion.suggestedWeight.toStringAsFixed(1)} kg',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Suggested',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${suggestion.weightDifference.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reps change if applicable
            if (suggestion.suggestedReps != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reps: ${suggestion.currentReps ?? '?'} → ${suggestion.suggestedReps}',
                style: theme.textTheme.bodyMedium,
              ),
            ],

            // Rationale
            const SizedBox(height: 12),
            Text(
              suggestion.rationale,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),

            // Action buttons for pending suggestions
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _declineSuggestion(suggestion),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _acceptSuggestion(suggestion),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.hiit:
        return Icons.flash_on;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _acceptSuggestion(ProgressionSuggestion suggestion) async {
    suggestion.status = SuggestionStatus.accepted;

    // Update the plan with new weight
    final plans = widget.repository.getAllPlans();
    for (final plan in plans) {
      for (final pe in plan.planExercises) {
        if (pe.exerciseId == suggestion.exerciseId) {
          pe.weightKg = suggestion.suggestedWeight;
          if (suggestion.suggestedReps != null) {
            pe.repetitions = suggestion.suggestedReps!;
          }
          await widget.repository.savePlan(plan);
          break;
        }
      }
    }

    // Check if all suggestions are processed
    _checkAllProcessed();

    await widget.repository.saveGptFeedback(widget.feedback);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suggestion accepted! Plan updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {});
    }
  }

  Future<void> _declineSuggestion(ProgressionSuggestion suggestion) async {
    suggestion.status = SuggestionStatus.declined;
    _checkAllProcessed();
    await widget.repository.saveGptFeedback(widget.feedback);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suggestion declined.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {});
    }
  }

  void _checkAllProcessed() {
    if (widget.feedback.suggestions != null) {
      widget.feedback.allSuggestionsProcessed = widget.feedback.suggestions!
          .every((s) => s.status != SuggestionStatus.pending);
    }
  }
}
