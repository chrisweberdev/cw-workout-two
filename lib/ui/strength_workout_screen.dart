import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/plan.dart';
import '../models/exercise.dart';
import '../models/strength_session.dart';
import '../models/set_entry.dart';

class StrengthWorkoutScreen extends StatefulWidget {
  final Repository repository;
  final Plan plan;

  const StrengthWorkoutScreen({
    super.key,
    required this.repository,
    required this.plan,
  });

  @override
  State<StrengthWorkoutScreen> createState() => _StrengthWorkoutScreenState();
}

class _StrengthWorkoutScreenState extends State<StrengthWorkoutScreen> {
  late StrengthSession _session;
  final Map<String, TextEditingController> _notesControllers = {};
  final TextEditingController _sessionNotesController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  int _rpe = 7;
  DateTime _startTime = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    // Check for active session
    final activeSession = widget.repository.getActiveStrengthSession();
    if (activeSession != null && activeSession.planId == widget.plan.id) {
      _session = activeSession;
      _rpe = _session.rpe;
      _sessionNotesController.text = _session.notes ?? '';
      _questionsController.text = _session.userQuestions ?? '';
    } else {
      // Create new session from plan
      final exercises = widget.plan.planExercises.map((pe) {
        final sets = List.generate(
          pe.numSets,
          (_) => SetEntry(
            repetitions: pe.repetitions,
            weightKg: pe.weightKg,
            plannedRepetitions: pe.repetitions,
          ),
        );
        return ExerciseRecord(exerciseId: pe.exerciseId, sets: sets);
      }).toList();

      _session = StrengthSession(
        id: const Uuid().v4(),
        date: DateTime.now(),
        planId: widget.plan.id,
        exercises: exercises,
        rpe: _rpe,
      );
    }
    _startTime = _session.date;
  }

  @override
  void dispose() {
    _sessionNotesController.dispose();
    _questionsController.dispose();
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = widget.repository.getAllExercises();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.plan.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              onPressed: _showDuration,
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressBar(theme),
            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _session.exercises.length + 1, // +1 for notes section
                itemBuilder: (context, index) {
                  if (index == _session.exercises.length) {
                    return _buildNotesSection(theme);
                  }
                  final record = _session.exercises[index];
                  final exercise = exercises.firstWhere(
                    (e) => e.id == record.exerciseId,
                    orElse: () => Exercise(id: '', name: 'Unknown', categoryId: ''),
                  );
                  return _buildExerciseCard(theme, record, exercise, index);
                },
              ),
            ),
            // Bottom action bar
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final totalSets = _session.exercises.fold(0, (sum, e) => sum + e.sets.length);
    final completedSets = _countCompletedSets();
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedSets / $totalSets sets completed',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    ThemeData theme,
    ExerciseRecord record,
    Exercise exercise,
    int exerciseIndex,
  ) {
    final completedSets = record.sets.where((s) => s.repetitions > 0).length;
    final allCompleted = completedSets == record.sets.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: allCompleted
                        ? Colors.green.withOpacity(0.2)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    allCompleted ? Icons.check : Icons.fitness_center,
                    color: allCompleted ? Colors.green : theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedSets / ${record.sets.length} sets',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addSet(exerciseIndex),
                  tooltip: 'Add set',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Sets
            ...record.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return _buildSetRow(theme, exerciseIndex, setIndex, set, exercise);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(
    ThemeData theme,
    int exerciseIndex,
    int setIndex,
    SetEntry set,
    Exercise exercise,
  ) {
    final isCompleted = set.repetitions > 0;
    final extraReps = set.extraReps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Weight input
          Expanded(
            child: _buildInputField(
              theme,
              label: 'kg',
              value: set.weightKg,
              onChanged: (value) {
                setState(() {
                  set.weightKg = value;
                });
                _saveSession();
              },
              isBodyweight: exercise.isBodyweight,
            ),
          ),
          const SizedBox(width: 8),
          // Reps input
          Expanded(
            child: _buildInputField(
              theme,
              label: 'reps',
              value: set.repetitions.toDouble(),
              onChanged: (value) {
                setState(() {
                  set.repetitions = value.toInt();
                });
                _saveSession();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Extra reps indicator
          if (extraReps > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+$extraReps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Delete set button
          if (_session.exercises[exerciseIndex].sets.length > 1)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _removeSet(exerciseIndex, setIndex),
              tooltip: 'Remove set',
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    ThemeData theme, {
    required String label,
    required double value,
    required Function(double) onChanged,
    bool isBodyweight = false,
  }) {
    return GestureDetector(
      onTap: () => _showNumberPicker(
        context,
        label: label,
        currentValue: value,
        onSelected: onChanged,
        isBodyweight: isBodyweight,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBodyweight && label == 'kg' ? 'BW' : value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RPE Selector
            Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Session RPE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildRpeBadge(theme, _rpe),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _rpe.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _rpe.toString(),
              onChanged: (value) {
                setState(() {
                  _rpe = value.toInt();
                });
              },
            ),
            Text(
              _getRpeDescription(_rpe),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Session notes
            Text(
              'Session Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sessionNotesController,
              decoration: const InputDecoration(
                hintText: 'How did it feel? Any issues?',
              ),
              maxLines: 2,
              onChanged: (_) => _saveSession(),
            ),
            const SizedBox(height: 16),
            // Questions for GPT
            Row(
              children: [
                Icon(Icons.smart_toy, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Questions for AI Coach',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionsController,
              decoration: const InputDecoration(
                hintText: 'Should I increase weight? Ready for more volume?',
              ),
              maxLines: 2,
              onChanged: (_) => _saveSession(),
            ),
            const SizedBox(height: 8),
            Text(
              'These questions will be included when you sync with your AI coach.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'RPE $_rpe',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Workout summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_session.totalVolume.toStringAsFixed(0)} kg volume',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_session.totalSets} sets • ${_session.totalReps} reps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Complete button
            FilledButton.icon(
              onPressed: _isSaving ? null : _completeWorkout,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Saving...' : 'Complete'),
            ),
          ],
        ),
      ),
    );
  }

  int _countCompletedSets() {
    return _session.exercises.fold(
      0,
      (sum, e) => sum + e.sets.where((s) => s.repetitions > 0).length,
    );
  }

  String _getRpeDescription(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return 'Very light - barely any effort';
      case 3:
      case 4:
        return 'Light - could do much more';
      case 5:
        return 'Moderate - comfortable effort';
      case 6:
        return 'Somewhat hard - starting to challenge';
      case 7:
        return 'Hard - challenging but sustainable';
      case 8:
        return 'Very hard - could do 2 more reps';
      case 9:
        return 'Near max - could do 1 more rep';
      case 10:
        return 'Maximum effort - nothing left';
      default:
        return '';
    }
  }

  void _addSet(int exerciseIndex) {
    final record = _session.exercises[exerciseIndex];
    final lastSet = record.sets.last;
    setState(() {
      record.sets.add(SetEntry(
        repetitions: lastSet.repetitions,
        weightKg: lastSet.weightKg,
        plannedRepetitions: lastSet.plannedRepetitions,
      ));
    });
    _saveSession();
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _session.exercises[exerciseIndex].sets.removeAt(setIndex);
    });
    _saveSession();
  }

  Future<void> _showNumberPicker(
    BuildContext context, {
    required String label,
    required double currentValue,
    required Function(double) onSelected,
    bool isBodyweight = false,
  }) async {
    final theme = Theme.of(context);
    double selectedValue = currentValue;
    final isWeight = label == 'kg';
    final increment = isWeight ? 2.5 : 1.0;
    final maxValue = isWeight ? 300.0 : 50.0;

    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isWeight ? 'Weight (kg)' : 'Repetitions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Quick select buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _getQuickSelectValues(isWeight).map((value) {
                  final isSelected = value == selectedValue;
                  return ChoiceChip(
                    label: Text(value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedValue = value);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Fine-tune controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: selectedValue > increment
                        ? () => setModalState(() => selectedValue -= increment)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    selectedValue.toStringAsFixed(selectedValue == selectedValue.roundToDouble() ? 0 : 1),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: selectedValue < maxValue
                        ? () => setModalState(() => selectedValue += increment)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    onSelected(selectedValue);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<double> _getQuickSelectValues(bool isWeight) {
    if (isWeight) {
      return [0, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80];
    } else {
      return [5, 6, 8, 10, 12, 15, 20];
    }
  }

  void _showDuration() {
    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout duration: ${minutes}m ${seconds}s'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveSession() async {
    _session.rpe = _rpe;
    _session.notes = _sessionNotesController.text.trim();
    _session.userQuestions = _questionsController.text.trim();
    _session.durationMinutes = DateTime.now().difference(_startTime).inMinutes;
    await widget.repository.saveStrengthSession(_session);
  }

  Future<void> _handleBackPress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Workout?'),
        content: const Text(
          'Your progress will be saved. You can resume this workout later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _saveSession();
      Navigator.pop(context);
    }
  }

  Future<void> _completeWorkout() async {
    setState(() => _isSaving = true);

    try {
      _session.isCompleted = true;
      _session.rpe = _rpe;
      _session.notes = _sessionNotesController.text.trim();
      _session.userQuestions = _questionsController.text.trim();
      _session.durationMinutes = DateTime.now().difference(_startTime).inMinutes;

      await widget.repository.saveStrengthSession(_session);

      // Show completion dialog
      if (mounted) {
        await _showCompletionDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showCompletionDialog() async {
    final theme = Theme.of(context);
    final settings = widget.repository.getSettings();
    final isGithubConfigured = settings.isGithubConfigured;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(theme, Icons.fitness_center, '${_session.totalSets} sets'),
            const SizedBox(height: 8),
            _buildSummaryRow(theme, Icons.repeat, '${_session.totalReps} total reps'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              theme,
              Icons.monitor_weight,
              '${_session.totalVolume.toStringAsFixed(0)} kg volume',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              theme,
              Icons.timer,
              '${_session.durationMinutes ?? 0} minutes',
            ),
            if (!isGithubConfigured) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Configure GitHub sync in Settings to get AI coaching feedback.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (isGithubConfigured)
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _syncAndOpenGpt();
              },
              icon: const Icon(Icons.cloud_sync),
              label: const Text('Sync & Get Feedback'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(text, style: theme.textTheme.bodyLarge),
      ],
    );
  }

  Future<void> _syncAndOpenGpt() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show syncing indicator
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Syncing to GitHub...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final result = await widget.repository.syncToGitHub();

      scaffoldMessenger.hideCurrentSnackBar();

      if (result.isSuccess) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Synced! Open your Custom GPT to get feedback.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // TODO: Open Custom GPT URL if configured
        final settings = widget.repository.getSettings();
        if (settings.customGptUrl != null && settings.customGptUrl!.isNotEmpty) {
          // Would use url_launcher here in production
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Open: ${settings.customGptUrl}'),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  // Copy to clipboard
                },
              ),
            ),
          );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
