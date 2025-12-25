import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/running_session.dart';
import '../models/enums.dart';

class RunningLogScreen extends StatefulWidget {
  final Repository repository;

  const RunningLogScreen({super.key, required this.repository});

  @override
  State<RunningLogScreen> createState() => _RunningLogScreenState();
}

class _RunningLogScreenState extends State<RunningLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _questionsController = TextEditingController();
  final _runnaTextController = TextEditingController();

  RunType _runType = RunType.easy;
  int _rpe = 5;
  String? _screenshotBase64;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _questionsController.dispose();
    _runnaTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Running'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Change date',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date display
            _buildDateCard(theme),
            const SizedBox(height: 16),

            // Run type selector
            _buildRunTypeSection(theme),
            const SizedBox(height: 16),

            // Screenshot section
            _buildScreenshotSection(theme),
            const SizedBox(height: 16),

            // Manual entry section
            _buildManualEntrySection(theme),
            const SizedBox(height: 16),

            // RPE section
            _buildRpeSection(theme),
            const SizedBox(height: 16),

            // Notes section
            _buildNotesSection(theme),
            const SizedBox(height: 24),

            // Save button
            _buildSaveButton(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(ThemeData theme) {
    final isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
        title: Text(
          isToday ? 'Today' : _formatDate(_selectedDate),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: TextButton(
          onPressed: _selectDate,
          child: const Text('Change'),
        ),
      ),
    );
  }

  Widget _buildRunTypeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_run, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Run Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RunType.values.map((type) {
                final isSelected = _runType == type;
                return ChoiceChip(
                  avatar: Icon(
                    type.icon,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _runType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getRunTypeDescription(_runType),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Runna Screenshot',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_screenshotBase64 != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _screenshotBase64 = null),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_screenshotBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(_screenshotBase64!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              InkWell(
                onTap: _pickScreenshot,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Runna Screenshot',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GPT will extract workout data',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Or paste Runna workout description:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _runnaTextController,
              decoration: const InputDecoration(
                hintText: 'e.g., "5km easy run, Zone 2, 6:00/km pace"',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntrySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Workout Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _distanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Distance',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      suffixText: 'min',
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculatedPace(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedPace(ThemeData theme) {
    final distance = double.tryParse(_distanceController.text);
    final duration = int.tryParse(_durationController.text);

    String paceText = '--:-- /km';
    if (distance != null && duration != null && distance > 0) {
      final pace = duration / distance;
      final minutes = pace.floor();
      final seconds = ((pace - minutes) * 60).round();
      paceText = '$minutes:${seconds.toString().padLeft(2, '0')} /km';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.speed, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Pace: ',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            paceText,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRpeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Effort (RPE)',
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
              onChanged: (value) => setState(() => _rpe = value.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getRunTypeRpeTarget(_runType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _isRpeInRange()
                        ? Colors.green
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getRpeDescription(_rpe),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
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

  Widget _buildNotesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'How did it feel? Weather, terrain, etc.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
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
                hintText: 'Am I running too fast on easy days?',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return FilledButton.icon(
      onPressed: _isSaving ? null : _saveRun,
      icon: _isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isSaving ? 'Saving...' : 'Save Run'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  String _getRunTypeDescription(RunType type) {
    switch (type) {
      case RunType.easy:
        return 'Conversational pace, Zone 2. Your bread and butter.';
      case RunType.hard:
        return 'Tempo or threshold effort. Max 1 per week.';
      case RunType.long:
        return 'Extended easy run. Build aerobic base.';
      case RunType.recovery:
        return 'Very easy, shake-out run after hard session.';
      case RunType.interval:
        return 'Speed work with rest intervals.';
    }
  }

  String _getRunTypeRpeTarget(RunType type) {
    switch (type) {
      case RunType.easy:
        return 'Target: RPE 3-5';
      case RunType.hard:
        return 'Target: RPE 7-9';
      case RunType.long:
        return 'Target: RPE 4-6';
      case RunType.recovery:
        return 'Target: RPE 2-4';
      case RunType.interval:
        return 'Target: RPE 8-10';
    }
  }

  bool _isRpeInRange() {
    switch (_runType) {
      case RunType.easy:
        return _rpe >= 3 && _rpe <= 5;
      case RunType.hard:
        return _rpe >= 7 && _rpe <= 9;
      case RunType.long:
        return _rpe >= 4 && _rpe <= 6;
      case RunType.recovery:
        return _rpe >= 2 && _rpe <= 4;
      case RunType.interval:
        return _rpe >= 8 && _rpe <= 10;
    }
  }

  String _getRpeDescription(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return 'Very light';
      case 3:
      case 4:
        return 'Light';
      case 5:
        return 'Moderate';
      case 6:
        return 'Somewhat hard';
      case 7:
        return 'Hard';
      case 8:
        return 'Very hard';
      case 9:
        return 'Near max';
      case 10:
        return 'Maximum';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _screenshotBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveRun() async {
    setState(() => _isSaving = true);

    try {
      final distance = double.tryParse(_distanceController.text);
      final duration = int.tryParse(_durationController.text);

      double? pace;
      if (distance != null && duration != null && distance > 0) {
        pace = duration / distance;
      }

      final session = RunningSession(
        id: const Uuid().v4(),
        date: _selectedDate,
        runType: _runType,
        distanceKm: distance,
        durationMinutes: duration,
        paceMinPerKm: pace,
        rpe: _rpe,
        notes: _notesController.text.trim(),
        userQuestions: _questionsController.text.trim(),
        screenshotBase64: _screenshotBase64,
        runnaWorkoutText: _runnaTextController.text.trim(),
        isCompleted: true,
      );

      await widget.repository.saveRunningSession(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Run saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
