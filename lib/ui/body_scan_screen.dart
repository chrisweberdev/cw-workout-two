import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/body_scan.dart';

class BodyScanScreen extends StatefulWidget {
  final Repository repository;

  const BodyScanScreen({super.key, required this.repository});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _showAdvanced = false;

  // Muscle breakdown controllers
  final Map<String, TextEditingController> _muscleControllers = {};
  static const List<String> _muscleGroups = [
    'Arms',
    'Chest',
    'Back',
    'Core',
    'Legs',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with last scan values if available
    final lastScan = widget.repository.getLatestBodyScan();
    if (lastScan != null) {
      _weightController.text = lastScan.weightKg.toStringAsFixed(1);
      if (lastScan.bodyFatPercent != null) {
        _bodyFatController.text = lastScan.bodyFatPercent!.toStringAsFixed(1);
      }
      if (lastScan.muscleMassKg != null) {
        _muscleMassController.text = lastScan.muscleMassKg!.toStringAsFixed(1);
      }
    }

    // Initialize muscle controllers
    for (final group in _muscleGroups) {
      _muscleControllers[group] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _notesController.dispose();
    for (final controller in _muscleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previousScans = widget.repository.getAllBodyScans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Scan'),
        actions: [
          if (previousScans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistory(context),
              tooltip: 'View history',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date selector
            _buildDateCard(theme),
            const SizedBox(height: 16),

            // Main metrics
            _buildMainMetricsCard(theme),
            const SizedBox(height: 16),

            // Body composition
            _buildCompositionCard(theme),
            const SizedBox(height: 16),

            // Advanced: Muscle breakdown
            _buildMuscleBreakdownCard(theme),
            const SizedBox(height: 16),

            // Notes
            _buildNotesCard(theme),
            const SizedBox(height: 16),

            // Comparison with previous
            if (previousScans.isNotEmpty) ...[
              _buildComparisonCard(theme, previousScans.first),
              const SizedBox(height: 16),
            ],

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
          isToday ? 'Today' : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: theme.textTheme.titleMedium,
        ),
        trailing: TextButton(
          onPressed: _selectDate,
          child: const Text('Change'),
        ),
      ),
    );
  }

  Widget _buildMainMetricsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Weight',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
                prefixIcon: Icon(Icons.scale),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Body Composition',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Optional - from InBody or similar scanner',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bodyFatController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Body Fat',
                      suffixText: '%',
                      prefixIcon: Icon(Icons.water_drop),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _muscleMassController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Muscle Mass',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculatedMetrics(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedMetrics(ThemeData theme) {
    final weight = double.tryParse(_weightController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);

    if (weight == null || bodyFat == null) {
      return const SizedBox.shrink();
    }

    final leanMass = weight * (1 - bodyFat / 100);
    final fatMass = weight * (bodyFat / 100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricChip(theme, 'Lean Mass', '${leanMass.toStringAsFixed(1)} kg'),
          _buildMetricChip(theme, 'Fat Mass', '${fatMass.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }

  Widget _buildMetricChip(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleBreakdownCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Muscle Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showAdvanced ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
            if (_showAdvanced) ...[
              const SizedBox(height: 8),
              Text(
                'Optional - detailed muscle mass by region',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_muscleGroups.length, (index) {
                final group = _muscleGroups[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _muscleControllers[group],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: group,
                      suffixText: 'kg',
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(ThemeData theme) {
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
                hintText: 'Hydration level, time of day, etc.',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(ThemeData theme, BodyScan lastScan) {
    final currentWeight = double.tryParse(_weightController.text);
    final currentBodyFat = double.tryParse(_bodyFatController.text);
    final currentMuscle = double.tryParse(_muscleMassController.text);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'vs Last Scan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(lastScan.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (currentWeight != null)
                  _buildChangeIndicator(
                    theme,
                    'Weight',
                    currentWeight - lastScan.weightKg,
                    'kg',
                    lowerIsBetter: true,
                  ),
                if (currentBodyFat != null && lastScan.bodyFatPercent != null)
                  _buildChangeIndicator(
                    theme,
                    'Body Fat',
                    currentBodyFat - lastScan.bodyFatPercent!,
                    '%',
                    lowerIsBetter: true,
                  ),
                if (currentMuscle != null && lastScan.muscleMassKg != null)
                  _buildChangeIndicator(
                    theme,
                    'Muscle',
                    currentMuscle - lastScan.muscleMassKg!,
                    'kg',
                    lowerIsBetter: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(
    ThemeData theme,
    String label,
    double change,
    String unit, {
    required bool lowerIsBetter,
  }) {
    final isPositive = change > 0;
    final isGood = lowerIsBetter ? !isPositive : isPositive;
    final color = change == 0 ? Colors.grey : (isGood ? Colors.green : Colors.red);
    final icon = change == 0
        ? Icons.remove
        : (isPositive ? Icons.arrow_upward : Icons.arrow_downward);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            Text(
              '${change.abs().toStringAsFixed(1)} $unit',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return FilledButton.icon(
      onPressed: _isSaving ? null : _saveScan,
      icon: _isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isSaving ? 'Saving...' : 'Save Body Scan'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showHistory(BuildContext context) {
    final scans = widget.repository.getAllBodyScans();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Body Scan History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final scan = scans[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${scan.weightKg.toInt()}'),
                    ),
                    title: Text('${scan.weightKg.toStringAsFixed(1)} kg'),
                    subtitle: Text(
                      scan.bodyFatPercent != null
                          ? '${scan.bodyFatPercent!.toStringAsFixed(1)}% body fat'
                          : 'No body composition data',
                    ),
                    trailing: Text(
                      _formatDate(scan.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveScan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final weight = double.parse(_weightController.text);
      final bodyFat = double.tryParse(_bodyFatController.text);
      final muscleMass = double.tryParse(_muscleMassController.text);

      // Build muscle breakdown if any values entered
      Map<String, double>? muscleBreakdown;
      if (_showAdvanced) {
        muscleBreakdown = {};
        for (final group in _muscleGroups) {
          final value = double.tryParse(_muscleControllers[group]!.text);
          if (value != null) {
            muscleBreakdown[group] = value;
          }
        }
        if (muscleBreakdown.isEmpty) {
          muscleBreakdown = null;
        }
      }

      final scan = BodyScan(
        id: const Uuid().v4(),
        date: _selectedDate,
        weightKg: weight,
        bodyFatPercent: bodyFat,
        muscleMassKg: muscleMass,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        muscleBreakdown: muscleBreakdown,
      );

      await widget.repository.saveBodyScan(scan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Body scan saved!'),
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
