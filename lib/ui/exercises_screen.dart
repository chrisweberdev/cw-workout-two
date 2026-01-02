import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/repository.dart';
import '../models/category.dart';
import '../models/exercise.dart';

class ExercisesScreen extends StatefulWidget {
  final Repository repository;

  const ExercisesScreen({super.key, required this.repository});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String? _selectedCategoryFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.repository.getAllCategories();
    final allExercises = widget.repository.getAllExercises();

    // Apply filters
    var exercises = allExercises;
    if (_selectedCategoryFilter != null) {
      exercises = exercises.where((e) => e.categoryId == _selectedCategoryFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((e) =>
          e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _showCategoriesDialog,
            tooltip: 'Manage Categories',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (_) => setState(() => _selectedCategoryFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: _selectedCategoryFilter == cat.id,
                          onSelected: (_) => setState(() =>
                              _selectedCategoryFilter = _selectedCategoryFilter == cat.id
                                  ? null
                                  : cat.id),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Exercise list
          Expanded(
            child: exercises.isEmpty
                ? _buildEmptyState(theme, categories.isEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final category = categories.firstWhere(
                        (c) => c.id == exercise.categoryId,
                        orElse: () => Category(id: '', name: 'Uncategorized'),
                      );
                      return _buildExerciseCard(theme, exercise, category);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: categories.isEmpty
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add a category first')),
                );
                _showCategoriesDialog();
              }
            : () => _showExerciseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool noCategories) {
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
            noCategories ? 'No categories yet' : 'No exercises found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noCategories
                ? 'Add a category first to create exercises'
                : 'Tap + to add your first exercise',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          if (noCategories) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showCategoriesDialog,
              icon: const Icon(Icons.category),
              label: const Text('Add Category'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ThemeData theme, Exercise exercise, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            exercise.isBodyweight ? Icons.accessibility_new : Icons.fitness_center,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Wrap(
          spacing: 8,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (exercise.isBodyweight)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bodyweight',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
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
              case 'edit':
                _showExerciseDialog(existing: exercise);
                break;
              case 'delete':
                _confirmDeleteExercise(exercise);
                break;
            }
          },
        ),
        onTap: () => _showExerciseDialog(existing: exercise),
      ),
    );
  }

  Future<void> _showExerciseDialog({Exercise? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    List<Category> categories = widget.repository.getAllCategories();
    String? selectedCategoryId = existing?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);
    bool isBodyweight = existing?.isBodyweight ?? false;

    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a category first')),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Exercise' : 'Edit Exercise'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name',
                        hintText: 'e.g., Bench Press',
                      ),
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      items: categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedCategoryId = v),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Bodyweight Exercise'),
                      subtitle: const Text('No weight tracking needed'),
                      value: isBodyweight,
                      onChanged: (v) => setDialogState(() => isBodyweight = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty || selectedCategoryId == null) {
                      return;
                    }

                    final exercise = Exercise(
                      id: existing?.id ?? const Uuid().v4(),
                      name: name,
                      categoryId: selectedCategoryId!,
                      isBodyweight: isBodyweight,
                    );
                    await widget.repository.saveExercise(exercise);

                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteExercise(Exercise exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise?'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
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
      await widget.repository.deleteExercise(exercise.id);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _showCategoriesDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _CategoriesDialog(repository: widget.repository),
    );
    setState(() {}); // Refresh after categories change
  }
}

class _CategoriesDialog extends StatefulWidget {
  final Repository repository;

  const _CategoriesDialog({required this.repository});

  @override
  State<_CategoriesDialog> createState() => _CategoriesDialogState();
}

class _CategoriesDialogState extends State<_CategoriesDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.repository.getAllCategories();

    return AlertDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No categories yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final exerciseCount = widget.repository
                        .getExercisesByCategory(category.id)
                        .length;

                    return ListTile(
                      title: Text(category.name),
                      subtitle: Text('$exerciseCount exercises'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDeleteCategory(category, exerciseCount),
                      ),
                      onTap: () => _showEditCategoryDialog(category),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g., Chest, Back, Legs',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final category = Category(
        id: const Uuid().v4(),
        name: result,
      );
      await widget.repository.saveCategory(category);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _showEditCategoryDialog(Category category) async {
    final nameController = TextEditingController(text: category.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Category Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      category.name = result;
      await widget.repository.saveCategory(category);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _confirmDeleteCategory(Category category, int exerciseCount) async {
    if (exerciseCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot delete "${category.name}" - it has $exerciseCount exercises',
            ),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
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
      await widget.repository.deleteCategory(category.id);
      if (mounted) {
        setState(() {});
      }
    }
  }
}
