import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models/enums.dart';
import 'plans_screen.dart';
import 'running_log_screen.dart';
import 'hiit_log_screen.dart';
import 'body_scan_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Repository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CW Hybrid Training'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _openAnalytics,
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncToGitHub,
            tooltip: 'Sync to GitHub',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week Overview Calendar
              _buildWeekCalendar(theme),
              const SizedBox(height: 16),

              // Quick Stats Card
              _buildQuickStatsCard(theme),
              const SizedBox(height: 24),

              // Start Workout Section
              Text(
                'Start Workout',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildWorkoutTypeGrid(theme),
              const SizedBox(height: 24),

              // Recent GPT Feedback
              _buildRecentFeedbackCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(ThemeData theme) {
    final now = DateTime.now();
    // Start from Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getWeekRange(monday),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final day = days[index];
                final isToday = day.day == now.day &&
                    day.month == now.month &&
                    day.year == now.year;
                final workouts = _getWorkoutsForDay(day);
                final weekday = index + 1; // 1=Monday to 7=Sunday

                return _buildDayCell(
                  theme,
                  dayNames[index],
                  day.day.toString(),
                  isToday,
                  weekday,
                  workouts,
                );
              }),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(theme, theme.colorScheme.primary, 'Strength', filled: true),
                _buildLegendItem(theme, theme.colorScheme.secondary, 'Running', filled: true),
                _buildLegendItem(theme, theme.colorScheme.tertiary, 'HIIT', filled: true),
                _buildLegendItem(theme, theme.colorScheme.outline, 'Planned', filled: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    ThemeData theme,
    String dayName,
    String dayNumber,
    bool isToday,
    int weekday,
    List<WorkoutType> completedWorkouts,
  ) {
    final settings = widget.repository.getSettings();
    final plannedType = settings.getPlannedWorkout(weekday);

    // Check if the planned workout was completed
    final isPlannedCompleted = plannedType != null &&
        completedWorkouts.contains(plannedType);

    return Column(
      children: [
        Text(
          dayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isToday ? FontWeight.bold : null,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? null
                : Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
          ),
          child: Center(
            child: Text(
              dayNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : null,
                color: isToday ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Workout indicators
        SizedBox(
          height: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildWorkoutIndicators(
              theme,
              plannedType,
              completedWorkouts,
              isPlannedCompleted,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWorkoutIndicators(
    ThemeData theme,
    WorkoutType? plannedType,
    List<WorkoutType> completedWorkouts,
    bool isPlannedCompleted,
  ) {
    final indicators = <Widget>[];

    // Show planned workout indicator
    if (plannedType != null) {
      final color = _getWorkoutColor(theme, plannedType);
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isPlannedCompleted ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 1.5,
            ),
          ),
        ),
      );
    }

    // Show additional completed workouts (not matching planned)
    for (final type in completedWorkouts) {
      if (type != plannedType) {
        final color = _getWorkoutColor(theme, type);
        indicators.add(
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }
    }

    // If no indicators, show empty placeholder
    if (indicators.isEmpty) {
      indicators.add(const SizedBox(width: 8, height: 8));
    }

    return indicators.take(3).toList();
  }

  Color _getWorkoutColor(ThemeData theme, WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => theme.colorScheme.primary,
      WorkoutType.running => theme.colorScheme.secondary,
      WorkoutType.hiit => theme.colorScheme.tertiary,
    };
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label, {bool filled = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getWeekRange(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    if (monday.month == sunday.month) {
      return '${monday.day}-${sunday.day} ${_getMonthName(monday.month)}';
    } else {
      return '${monday.day} ${_getMonthName(monday.month)} - ${sunday.day} ${_getMonthName(sunday.month)}';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  List<WorkoutType> _getWorkoutsForDay(DateTime day) {
    final workouts = widget.repository.getAllWorkouts();
    final dayWorkouts = workouts.where((w) =>
        w.date.year == day.year &&
        w.date.month == day.month &&
        w.date.day == day.day &&
        w.isCompleted).toList();

    return dayWorkouts.map((w) => w.type as WorkoutType).toList();
  }

  Widget _buildQuickStatsCard(ThemeData theme) {
    final workoutsThisWeek = _getWorkoutsThisWeek();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.repository.isGithubConfigured)
                  Icon(
                    Icons.cloud_done,
                    color: theme.colorScheme.primary,
                    size: 20,
                  )
                else
                  Icon(
                    Icons.cloud_off,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  theme,
                  workoutsThisWeek.toString(),
                  'Workouts',
                  Icons.fitness_center,
                ),
                _buildStatItem(
                  theme,
                  _getStrengthSessionsThisWeek().toString(),
                  'Strength',
                  Icons.fitness_center,
                ),
                _buildStatItem(
                  theme,
                  _getRunsThisWeek().toString(),
                  'Runs',
                  Icons.directions_run,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildWorkoutTypeCard(
          theme,
          WorkoutType.strength,
          'Strength',
          Icons.fitness_center,
          theme.colorScheme.primary,
        ),
        _buildWorkoutTypeCard(
          theme,
          WorkoutType.running,
          'Running',
          Icons.directions_run,
          theme.colorScheme.secondary,
        ),
        _buildWorkoutTypeCard(
          theme,
          WorkoutType.hiit,
          'HYROX HIIT',
          Icons.flash_on,
          theme.colorScheme.tertiary,
        ),
        _buildBodyScanCard(theme),
      ],
    );
  }

  Widget _buildWorkoutTypeCard(
    ThemeData theme,
    WorkoutType type,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _startWorkout(type),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyScanCard(ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _logBodyScan,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.purple.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor_weight, size: 32, color: Colors.purple),
                const SizedBox(height: 8),
                Text(
                  'Body Scan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFeedbackCard(ThemeData theme) {
    final recentFeedback = widget.repository.getAllGptFeedback();
    final latestFeedback = recentFeedback.isNotEmpty ? recentFeedback.first : null;

    if (latestFeedback == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest AI Feedback',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      latestFeedback.sessionType.displayName,
                      style: theme.textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(latestFeedback.receivedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  latestFeedback.feedbackText.length > 200
                      ? '${latestFeedback.feedbackText.substring(0, 200)}...'
                      : latestFeedback.feedbackText,
                  style: theme.textTheme.bodyMedium,
                ),
                if (latestFeedback.pendingSuggestionsCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${latestFeedback.pendingSuggestionsCount} pending suggestions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getWorkoutsThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final workouts = widget.repository.getAllWorkouts();
    return workouts.where((w) => w.date.isAfter(startOfWeek)).length;
  }

  int _getStrengthSessionsThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final sessions = widget.repository.getAllStrengthSessions();
    return sessions.where((s) => s.date.isAfter(startOfWeek) && s.isCompleted).length;
  }

  int _getRunsThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final sessions = widget.repository.getAllRunningSessions();
    return sessions.where((s) => s.date.isAfter(startOfWeek) && s.isCompleted).length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  void _startWorkout(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlansScreen(repository: widget.repository),
          ),
        ).then((_) => setState(() {}));
        break;
      case WorkoutType.running:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunningLogScreen(repository: widget.repository),
          ),
        ).then((_) => setState(() {}));
        break;
      case WorkoutType.hiit:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HiitLogScreen(repository: widget.repository),
          ),
        ).then((_) => setState(() {}));
        break;
    }
  }

  void _logBodyScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BodyScanScreen(repository: widget.repository),
      ),
    ).then((_) => setState(() {}));
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _syncToGitHub() async {
    if (!widget.repository.isGithubConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure GitHub in Settings first'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing to GitHub...')),
    );

    final result = await widget.repository.syncToGitHub();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isSuccess ? 'Sync complete!' : 'Sync failed: ${result.error}',
          ),
        ),
      );
    }
  }
}
