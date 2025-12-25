import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/repository.dart';
import '../models/enums.dart';

class AnalyticsScreen extends StatefulWidget {
  final Repository repository;

  const AnalyticsScreen({super.key, required this.repository});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedWeeks = 4; // Last 4 weeks by default

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (weeks) => setState(() => _selectedWeeks = weeks),
            itemBuilder: (context) => [
              PopupMenuItem(value: 2, child: Text('Last 2 weeks${_selectedWeeks == 2 ? ' ✓' : ''}')),
              PopupMenuItem(value: 4, child: Text('Last 4 weeks${_selectedWeeks == 4 ? ' ✓' : ''}')),
              PopupMenuItem(value: 8, child: Text('Last 8 weeks${_selectedWeeks == 8 ? ' ✓' : ''}')),
              PopupMenuItem(value: 12, child: Text('Last 12 weeks${_selectedWeeks == 12 ? ' ✓' : ''}')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Workout frequency card
          _buildWorkoutFrequencyCard(theme),
          const SizedBox(height: 16),

          // Volume trend card
          _buildVolumeTrendCard(theme),
          const SizedBox(height: 16),

          // Running distance card
          _buildRunningDistanceCard(theme),
          const SizedBox(height: 16),

          // RPE trend card
          _buildRpeTrendCard(theme),
          const SizedBox(height: 16),

          // Summary stats
          _buildSummaryCard(theme),
        ],
      ),
    );
  }

  Widget _buildWorkoutFrequencyCard(ThemeData theme) {
    final weeklyData = _getWeeklyWorkoutCounts();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Frequency',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Workouts per week by type',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: weeklyData.isEmpty
                  ? _buildEmptyChart(theme)
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxWorkouts(weeklyData) + 1,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < weeklyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'W${weeklyData.length - index}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value == value.roundToDouble()) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: theme.textTheme.bodySmall,
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                        ),
                        barGroups: weeklyData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data['strength']!.toDouble(),
                                color: theme.colorScheme.primary,
                                width: 8,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                              BarChartRodData(
                                toY: data['running']!.toDouble(),
                                color: theme.colorScheme.secondary,
                                width: 8,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                              BarChartRodData(
                                toY: data['hiit']!.toDouble(),
                                color: theme.colorScheme.tertiary,
                                width: 8,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(theme, theme.colorScheme.primary, 'Strength'),
                const SizedBox(width: 16),
                _buildLegendItem(theme, theme.colorScheme.secondary, 'Running'),
                const SizedBox(width: 16),
                _buildLegendItem(theme, theme.colorScheme.tertiary, 'HIIT'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeTrendCard(ThemeData theme) {
    final volumeData = _getWeeklyVolume();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Strength Volume',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total kg lifted per week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: volumeData.isEmpty || volumeData.every((v) => v == 0)
                  ? _buildEmptyChart(theme)
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < volumeData.length && index >= 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'W${volumeData.length - index}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${(value / 1000).toStringAsFixed(1)}k',
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: volumeData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withOpacity(0.1),
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

  Widget _buildRunningDistanceCard(ThemeData theme) {
    final distanceData = _getWeeklyRunningDistance();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running Distance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kilometers per week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: distanceData.isEmpty || distanceData.every((v) => v == 0)
                  ? _buildEmptyChart(theme)
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < distanceData.length && index >= 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'W${distanceData.length - index}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toStringAsFixed(0)} km',
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: distanceData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: theme.colorScheme.secondary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.secondary.withOpacity(0.1),
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

  Widget _buildRpeTrendCard(ThemeData theme) {
    final rpeData = _getWeeklyAverageRpe();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average RPE',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Weekly average perceived exertion',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: rpeData.isEmpty || rpeData.every((v) => v == 0)
                  ? _buildEmptyChart(theme)
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 10,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < rpeData.length && index >= 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'W${rpeData.length - index}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 2,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: rpeData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
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

  Widget _buildSummaryCard(ThemeData theme) {
    final stats = _getTotalStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last $_selectedWeeks weeks',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatTile(theme, '${stats['totalWorkouts']}', 'Workouts', Icons.fitness_center)),
                Expanded(child: _buildStatTile(theme, '${(stats['totalVolume']! / 1000).toStringAsFixed(1)}k', 'kg Lifted', Icons.monitor_weight)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatTile(theme, '${stats['totalDistance']!.toStringAsFixed(1)}', 'km Run', Icons.directions_run)),
                Expanded(child: _buildStatTile(theme, '${stats['avgRpe']!.toStringAsFixed(1)}', 'Avg RPE', Icons.speed)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(ThemeData theme, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
          Text(
            'No data yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  // Data calculation methods
  List<Map<String, int>> _getWeeklyWorkoutCounts() {
    final now = DateTime.now();
    final result = <Map<String, int>>[];

    for (int week = _selectedWeeks - 1; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final workouts = widget.repository.getAllWorkouts().where((w) =>
          w.isCompleted &&
          w.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          w.date.isBefore(weekEnd));

      int strength = 0, running = 0, hiit = 0;
      for (final w in workouts) {
        switch (w.type) {
          case WorkoutType.strength:
            strength++;
            break;
          case WorkoutType.running:
            running++;
            break;
          case WorkoutType.hiit:
            hiit++;
            break;
        }
      }

      result.add({'strength': strength, 'running': running, 'hiit': hiit});
    }

    return result;
  }

  double _getMaxWorkouts(List<Map<String, int>> data) {
    double max = 0;
    for (final week in data) {
      for (final count in week.values) {
        if (count > max) max = count.toDouble();
      }
    }
    return max;
  }

  List<double> _getWeeklyVolume() {
    final now = DateTime.now();
    final result = <double>[];

    for (int week = _selectedWeeks - 1; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final sessions = widget.repository.getAllStrengthSessions().where((s) =>
          s.isCompleted &&
          s.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          s.date.isBefore(weekEnd));

      final volume = sessions.fold(0.0, (sum, s) => sum + s.totalVolume);
      result.add(volume);
    }

    return result;
  }

  List<double> _getWeeklyRunningDistance() {
    final now = DateTime.now();
    final result = <double>[];

    for (int week = _selectedWeeks - 1; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final sessions = widget.repository.getAllRunningSessions().where((s) =>
          s.isCompleted &&
          s.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          s.date.isBefore(weekEnd));

      final distance = sessions.fold(0.0, (sum, s) => sum + (s.distanceKm ?? 0));
      result.add(distance);
    }

    return result;
  }

  List<double> _getWeeklyAverageRpe() {
    final now = DateTime.now();
    final result = <double>[];

    for (int week = _selectedWeeks - 1; week >= 0; week--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final workouts = widget.repository.getAllWorkouts().where((w) =>
          w.isCompleted &&
          w.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          w.date.isBefore(weekEnd)).toList();

      if (workouts.isEmpty) {
        result.add(0);
      } else {
        final avgRpe = workouts.fold<double>(0.0, (sum, w) => sum + w.rpe) / workouts.length;
        result.add(avgRpe);
      }
    }

    return result;
  }

  Map<String, double> _getTotalStats() {
    final now = DateTime.now();
    final periodStart = now.subtract(Duration(days: _selectedWeeks * 7));

    final allWorkouts = widget.repository.getAllWorkouts().where((w) =>
        w.isCompleted && w.date.isAfter(periodStart)).toList();

    final strengthSessions = widget.repository.getAllStrengthSessions().where((s) =>
        s.isCompleted && s.date.isAfter(periodStart)).toList();

    final runningSessions = widget.repository.getAllRunningSessions().where((s) =>
        s.isCompleted && s.date.isAfter(periodStart)).toList();

    final totalVolume = strengthSessions.fold(0.0, (sum, s) => sum + s.totalVolume);
    final totalDistance = runningSessions.fold(0.0, (sum, s) => sum + (s.distanceKm ?? 0));
    final avgRpe = allWorkouts.isEmpty
        ? 0.0
        : allWorkouts.fold<double>(0.0, (sum, w) => sum + w.rpe) / allWorkouts.length;

    return {
      'totalWorkouts': allWorkouts.length.toDouble(),
      'totalVolume': totalVolume,
      'totalDistance': totalDistance,
      'avgRpe': avgRpe,
    };
  }
}
