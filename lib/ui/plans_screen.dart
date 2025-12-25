import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/plan.dart';
import '../models/exercise.dart';
import 'strength_workout_screen.dart';

class PlansScreen extends StatefulWidget {
  final Repository repository;

  const PlansScreen({super.key, required this.repository});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plans = widget.repository.getAllPlans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
      ),
      body: plans.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _buildPlanCard(theme, plan);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewPlan,
        icon: const Icon(Icons.add),
        label: const Text('New Plan'),
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
            'No workout plans yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a plan to start tracking your workouts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _createNewPlan,
            icon: const Icon(Icons.add),
            label: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(ThemeData theme, Plan plan) {
    final exercises = widget.repository.getAllExercises();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _startWorkout(plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (plan.isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Main',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'main',
                        child: Row(
                          children: [
                            Icon(
                              plan.isMain ? Icons.star : Icons.star_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(plan.isMain ? 'Unset as Main' : 'Set as Main'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'main':
                          _toggleMainPlan(plan);
                          break;
                        case 'edit':
                          _editPlan(plan);
                          break;
                        case 'delete':
                          _deletePlan(plan);
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${plan.planExercises.length} exercises',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: plan.planExercises.take(4).map((pe) {
                  final exercise = exercises.firstWhere(
                    (e) => e.id == pe.exerciseId,
                    orElse: () => Exercise(id: '', name: 'Unknown', categoryId: ''),
                  );
                  return Chip(
                    label: Text(
                      exercise.name,
                      style: theme.textTheme.bodySmall,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              if (plan.planExercises.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${plan.planExercises.length - 4} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _startWorkout(plan),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkout(Plan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrengthWorkoutScreen(
          repository: widget.repository,
          plan: plan,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _createNewPlan() async {
    final nameController = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Plan'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Plan Name',
            hintText: 'e.g., Wednesday Strength',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final plan = Plan(
        id: const Uuid().v4(),
        name: name,
        planExercises: [],
        isMain: widget.repository.getAllPlans().isEmpty,
      );
      await widget.repository.savePlan(plan);
      if (mounted) {
        setState(() {});
        _editPlan(plan);
      }
    }
  }

  void _editPlan(Plan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanEditorScreen(
          repository: widget.repository,
          plan: plan,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _toggleMainPlan(Plan plan) async {
    if (plan.isMain) {
      plan.isMain = false;
      await widget.repository.savePlan(plan);
    } else {
      await widget.repository.setMainPlan(plan.id);
    }
    setState(() {});
  }

  Future<void> _deletePlan(Plan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.repository.deletePlan(plan.id);
      setState(() {});
    }
  }
}

class PlanEditorScreen extends StatefulWidget {
  final Repository repository;
  final Plan plan;

  const PlanEditorScreen({
    super.key,
    required this.repository,
    required this.plan,
  });

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = widget.repository.getAllExercises();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Plan Name',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercises',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.plan.planExercises.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No exercises yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.plan.planExercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = widget.plan.planExercises.removeAt(oldIndex);
                  widget.plan.planExercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final pe = widget.plan.planExercises[index];
                final exercise = exercises.firstWhere(
                  (e) => e.id == pe.exerciseId,
                  orElse: () => Exercise(id: '', name: 'Unknown', categoryId: ''),
                );

                return Card(
                  key: ValueKey(pe.exerciseId),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${pe.numSets} sets × ${pe.repetitions} reps @ ${pe.weightKg}kg',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editExercise(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeExercise(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _addExercise() async {
    final exercises = widget.repository.getAllExercises();
    final categories = widget.repository.getAllCategories();

    final result = await showModalBottomSheet<PlanExercise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => ExercisePickerSheet(
          exercises: exercises,
          categories: categories,
          scrollController: scrollController,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        widget.plan.planExercises.add(result);
      });
    }
  }

  Future<void> _editExercise(int index) async {
    final pe = widget.plan.planExercises[index];
    final setsController = TextEditingController(text: pe.numSets.toString());
    final repsController = TextEditingController(text: pe.repetitions.toString());
    final weightController = TextEditingController(text: pe.weightKg.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sets'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                pe.numSets = int.tryParse(setsController.text) ?? pe.numSets;
                pe.repetitions = int.tryParse(repsController.text) ?? pe.repetitions;
                pe.weightKg = double.tryParse(weightController.text) ?? pe.weightKg;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      widget.plan.planExercises.removeAt(index);
    });
  }

  Future<void> _savePlan() async {
    widget.plan.name = _nameController.text.trim();
    await widget.repository.savePlan(widget.plan);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class ExercisePickerSheet extends StatefulWidget {
  final List<Exercise> exercises;
  final List categories;
  final ScrollController scrollController;

  const ExercisePickerSheet({
    super.key,
    required this.exercises,
    required this.categories,
    required this.scrollController,
  });

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  String? selectedCategoryId;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredExercises = widget.exercises.where((e) {
      final matchesCategory = selectedCategoryId == null || e.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          e.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
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
                'Add Exercise',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: selectedCategoryId == null,
                      onSelected: (_) => setState(() => selectedCategoryId = null),
                    ),
                    const SizedBox(width: 8),
                    ...widget.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: selectedCategoryId == cat.id,
                        onSelected: (_) => setState(() => selectedCategoryId = cat.id),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              return ListTile(
                leading: Icon(
                  exercise.isBodyweight ? Icons.accessibility_new : Icons.fitness_center,
                ),
                title: Text(exercise.name),
                onTap: () => _selectExercise(exercise),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectExercise(Exercise exercise) async {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController(text: exercise.isBodyweight ? '0' : '20');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sets'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
            if (!exercise.isBodyweight) ...[
              const SizedBox(height: 8),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(
        context,
        PlanExercise(
          exerciseId: exercise.id,
          numSets: int.tryParse(setsController.text) ?? 3,
          repetitions: int.tryParse(repsController.text) ?? 10,
          weightKg: double.tryParse(weightController.text) ?? 0,
        ),
      );
    }
  }
}
