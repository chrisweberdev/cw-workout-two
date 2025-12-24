import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/hiit_session.dart';

class HiitLogScreen extends StatefulWidget {
  final Repository repository;

  const HiitLogScreen({super.key, required this.repository});

  @override
  State<HiitLogScreen> createState() => _HiitLogScreenState();
}

class _HiitLogScreenState extends State<HiitLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _questionsController = TextEditingController();

  List<String> _stations = [];
  final _stationController = TextEditingController();
  int _rpe = 8;
  String? _screenshotBase64;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  // Common HYROX stations for quick add
  static const List<String> _hyroxStations = [
    'SkiErg (1000m)',
    'Sled Push (50m)',
    'Sled Pull (50m)',
    'Burpee Broad Jumps (80m)',
    'RowErg (1000m)',
    'Farmers Carry (200m)',
    'Sandbag Lunges (100m)',
    'Wall Balls (100 reps)',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _questionsController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log HYROX HIIT'),
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

            // Screenshot section
            _buildScreenshotSection(theme),
            const SizedBox(height: 16),

            // Workout description
            _buildDescriptionSection(theme),
            const SizedBox(height: 16),

            // Stations section
            _buildStationsSection(theme),
            const SizedBox(height: 16),

            // Duration section
            _buildDurationSection(theme),
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
          isToday ? 'Today (Sunday HIIT)' : _formatDate(_selectedDate),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: TextButton(
          onPressed: _selectDate,
          child: const Text('Change'),
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
                  'Workout Screenshot',
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
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
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
                        'Upload gym workout screenshot',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Workout Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'e.g., "4 rounds: SkiErg, Wall Balls, Burpees"',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Stations/Exercises',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick add HYROX stations
            Text(
              'Quick add HYROX stations:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hyroxStations.map((station) {
                final isAdded = _stations.contains(station);
                return ActionChip(
                  avatar: Icon(
                    isAdded ? Icons.check : Icons.add,
                    size: 16,
                    color: isAdded ? Colors.green : null,
                  ),
                  label: Text(
                    station.split(' (')[0], // Show short name
                    style: TextStyle(
                      decoration: isAdded ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onPressed: () {
                    if (!isAdded) {
                      setState(() => _stations.add(station));
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Custom station input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stationController,
                    decoration: const InputDecoration(
                      hintText: 'Add custom station...',
                    ),
                    onSubmitted: (_) => _addCustomStation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addCustomStation,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Added stations list
            if (_stations.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Today\'s workout (${_stations.length} stations):',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _stations.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _stations.removeAt(oldIndex);
                    _stations.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final station = _stations[index];
                  return ListTile(
                    key: ValueKey('$station-$index'),
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    title: Text(station),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, size: 20),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          onPressed: () {
                            setState(() => _stations.removeAt(index));
                          },
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Duration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      suffixText: 'min',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Quick duration buttons
                Wrap(
                  spacing: 8,
                  children: [30, 45, 60].map((mins) {
                    return ActionChip(
                      label: Text('${mins}m'),
                      onPressed: () {
                        setState(() {
                          _durationController.text = mins.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
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
                  'HIIT Target: RPE 7-9',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (_rpe >= 7 && _rpe <= 9)
                        ? Colors.green
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getRpeDescription(_rpe),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
        color: color.withValues(alpha: 0.2),
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
                hintText: 'How did it feel? What was hardest?',
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
                hintText: 'Should I focus on any weak stations?',
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
      onPressed: _isSaving ? null : _saveSession,
      icon: _isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isSaving ? 'Saving...' : 'Save HIIT Session'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
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

  void _addCustomStation() {
    final text = _stationController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _stations.add(text);
        _stationController.clear();
      });
    }
  }

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);

    try {
      final duration = int.tryParse(_durationController.text);

      final session = HiitSession(
        id: const Uuid().v4(),
        date: _selectedDate,
        workoutDescription: _descriptionController.text.trim(),
        durationMinutes: duration,
        stations: _stations.isNotEmpty ? _stations : null,
        rpe: _rpe,
        notes: _notesController.text.trim(),
        userQuestions: _questionsController.text.trim(),
        screenshotBase64: _screenshotBase64,
        isCompleted: true,
      );

      await widget.repository.saveHiitSession(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HIIT session saved!'),
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
