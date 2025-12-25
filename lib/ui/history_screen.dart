import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models/enums.dart';
import '../models/strength_session.dart';
import '../models/running_session.dart';
import '../models/hiit_session.dart';

class HistoryScreen extends StatefulWidget {
  final Repository repository;

  const HistoryScreen({super.key, required this.repository});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  WorkoutType? _filterType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workouts = _getFilteredWorkouts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
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
                  FilterChip(
                    label: const Text('Strength'),
                    selected: _filterType == WorkoutType.strength,
                    onSelected: (_) => setState(() => _filterType = WorkoutType.strength),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Running'),
                    selected: _filterType == WorkoutType.running,
                    onSelected: (_) => setState(() => _filterType = WorkoutType.running),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('HIIT'),
                    selected: _filterType == WorkoutType.hiit,
                    onSelected: (_) => setState(() => _filterType = WorkoutType.hiit),
                  ),
                ],
              ),
            ),
          ),
          // Workout list
          Expanded(
            child: workouts.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return _buildWorkoutCard(theme, workout);
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
            Icons.fitness_center_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a workout to see it here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(ThemeData theme, dynamic workout) {
    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;
    final bool hasFeedback;

    if (workout is StrengthSession) {
      icon = Icons.fitness_center;
      color = theme.colorScheme.primary;
      title = 'Strength Training';
      subtitle = '${workout.totalSets} sets • ${workout.totalVolume.toStringAsFixed(0)} kg volume';
      hasFeedback = workout.gptFeedbackId != null;
    } else if (workout is RunningSession) {
      icon = Icons.directions_run;
      color = theme.colorScheme.secondary;
      title = workout.runType.displayName;
      subtitle = workout.distanceKm != null
          ? '${workout.distanceKm!.toStringAsFixed(1)} km • ${workout.durationFormatted}'
          : workout.durationFormatted;
      hasFeedback = workout.gptFeedbackId != null;
    } else if (workout is HiitSession) {
      icon = Icons.flash_on;
      color = theme.colorScheme.tertiary;
      title = 'HYROX HIIT';
      subtitle = workout.durationFormatted;
      hasFeedback = workout.gptFeedbackId != null;
    } else {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatDate(workout.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (hasFeedback) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.smart_toy,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI Feedback',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildRpeBadge(theme, workout.rpe),
        onTap: () {
          // TODO: Navigate to workout detail
        },
      ),
    );
  }

  Widget _buildRpeBadge(ThemeData theme, int rpe) {
    final Color color;
    if (rpe <= 5) {
      color = Colors.green;
    } else if (rpe <= 7) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'RPE $rpe',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<dynamic> _getFilteredWorkouts() {
    if (_filterType == null) {
      return widget.repository.getAllWorkouts()
          .where((w) => w.isCompleted)
          .toList();
    }

    switch (_filterType!) {
      case WorkoutType.strength:
        return widget.repository.getAllStrengthSessions()
            .where((s) => s.isCompleted)
            .toList();
      case WorkoutType.running:
        return widget.repository.getAllRunningSessions()
            .where((s) => s.isCompleted)
            .toList();
      case WorkoutType.hiit:
        return widget.repository.getAllHiitSessions()
            .where((s) => s.isCompleted)
            .toList();
    }
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
}
