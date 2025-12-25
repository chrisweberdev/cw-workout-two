import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/repository.dart';
import '../theme/theme_manager.dart';
import '../models/strength_session.dart';
import '../models/running_session.dart';
import '../models/hiit_session.dart';
import '../models/body_scan.dart';
import '../models/enums.dart';

class SettingsScreen extends StatefulWidget {
  final Repository repository;

  const SettingsScreen({super.key, required this.repository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _tokenController;
  late TextEditingController _ownerController;
  late TextEditingController _repoController;
  late TextEditingController _gptUrlController;
  bool _showToken = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.repository.getSettings();
    _tokenController = TextEditingController(text: settings.githubToken ?? '');
    _ownerController = TextEditingController(text: settings.githubRepoOwner ?? '');
    _repoController = TextEditingController(text: settings.githubRepoName ?? '');
    _gptUrlController = TextEditingController(text: settings.customGptUrl ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    _gptUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final settings = widget.repository.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GitHub Configuration Section
          _buildSectionHeader(theme, 'GitHub Sync', Icons.cloud_sync),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection status
                  Row(
                    children: [
                      Icon(
                        settings.isGithubConfigured
                            ? Icons.check_circle
                            : Icons.warning,
                        color: settings.isGithubConfigured
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        settings.isGithubConfigured
                            ? 'Connected to ${settings.repoFullName}'
                            : 'Not configured',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (settings.lastSyncTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last sync: ${_formatDateTime(settings.lastSyncTime!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Repository owner
                  TextField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      labelText: 'Repository Owner',
                      hintText: 'your-github-username',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Repository name
                  TextField(
                    controller: _repoController,
                    decoration: const InputDecoration(
                      labelText: 'Repository Name',
                      hintText: 'cw-workout-data',
                      prefixIcon: Icon(Icons.folder),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Personal Access Token
                  TextField(
                    controller: _tokenController,
                    obscureText: !_showToken,
                    decoration: InputDecoration(
                      labelText: 'Personal Access Token',
                      hintText: 'ghp_xxxxxxxxxxxx',
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(_showToken ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showToken = !_showToken),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a fine-grained PAT with Contents read/write permission for this repo only.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save button
                  FilledButton.icon(
                    onPressed: _saveGitHubSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save GitHub Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Custom GPT Section
          _buildSectionHeader(theme, 'Custom GPT', Icons.smart_toy),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _gptUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Custom GPT URL (optional)',
                      hintText: 'https://chat.openai.com/g/...',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Link to your ChatGPT Custom GPT for quick access after syncing.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saveGptSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save GPT Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(theme, 'Appearance', Icons.palette),
          Card(
            child: ListTile(
              leading: Icon(
                themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeManager.isDarkMode,
                onChanged: (value) {
                  themeManager.toggleTheme();
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Schedule Section
          _buildSectionHeader(theme, 'Weekly Schedule', Icons.calendar_month),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your planned workout type for each day of the week.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildWeekScheduleRows(theme, settings),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader(theme, 'Data', Icons.storage),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export all workout data to JSON'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Data'),
                  subtitle: const Text('Import workout data from JSON'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _importData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(theme, 'About', Icons.info),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CW Hybrid Training',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hybrid training tracker with GPT coaching for HYROX athletes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekScheduleRows(ThemeData theme, dynamic settings) {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return List.generate(7, (index) {
      final weekday = index + 1; // 1=Monday to 7=Sunday
      final plannedType = settings.getPlannedWorkout(weekday);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                dayNames[index],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SegmentedButton<WorkoutType?>(
                segments: [
                  ButtonSegment<WorkoutType?>(
                    value: null,
                    label: const Text('Rest'),
                    icon: const Icon(Icons.hotel, size: 16),
                  ),
                  ButtonSegment<WorkoutType?>(
                    value: WorkoutType.strength,
                    label: const Text('Strength'),
                    icon: const Icon(Icons.fitness_center, size: 16),
                  ),
                  ButtonSegment<WorkoutType?>(
                    value: WorkoutType.running,
                    label: const Text('Run'),
                    icon: const Icon(Icons.directions_run, size: 16),
                  ),
                  ButtonSegment<WorkoutType?>(
                    value: WorkoutType.hiit,
                    label: const Text('HIIT'),
                    icon: const Icon(Icons.flash_on, size: 16),
                  ),
                ],
                selected: {plannedType},
                onSelectionChanged: (selection) {
                  _updateSchedule(weekday, selection.first);
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _updateSchedule(int weekday, WorkoutType? type) async {
    final settings = widget.repository.getSettings();
    settings.setPlannedWorkout(weekday, type);
    await widget.repository.saveSettings(settings);
    setState(() {});
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _saveGitHubSettings() async {
    final settings = widget.repository.getSettings();
    settings.githubToken = _tokenController.text.trim();
    settings.githubRepoOwner = _ownerController.text.trim();
    settings.githubRepoName = _repoController.text.trim();

    await widget.repository.saveSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.isGithubConfigured
                ? 'GitHub settings saved!'
                : 'Please fill in all fields',
          ),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _saveGptSettings() async {
    final settings = widget.repository.getSettings();
    settings.customGptUrl = _gptUrlController.text.trim();

    await widget.repository.saveSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPT settings saved!')),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      // Gather all data
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'strengthSessions': widget.repository.getAllStrengthSessions()
            .map((s) => s.toJson())
            .toList(),
        'runningSessions': widget.repository.getAllRunningSessions()
            .map((s) => s.toJson())
            .toList(),
        'hiitSessions': widget.repository.getAllHiitSessions()
            .map((s) => s.toJson())
            .toList(),
        'bodyScans': widget.repository.getAllBodyScans()
            .map((s) => s.toJson())
            .toList(),
        'plans': widget.repository.getAllPlans()
            .map((p) => p.toJson())
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Show export options
      await showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy to Clipboard'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: jsonString));
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data copied to clipboard!')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share as File'),
                onTap: () async {
                  Navigator.pop(context);
                  await Share.share(
                    jsonString,
                    subject: 'CW Workout Data Export',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.preview),
                title: const Text('Preview Data'),
                onTap: () {
                  Navigator.pop(context);
                  _showExportPreview(exportData);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showExportPreview(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPreviewRow(theme, 'Strength Sessions', (data['strengthSessions'] as List).length),
              _buildPreviewRow(theme, 'Running Sessions', (data['runningSessions'] as List).length),
              _buildPreviewRow(theme, 'HIIT Sessions', (data['hiitSessions'] as List).length),
              _buildPreviewRow(theme, 'Body Scans', (data['bodyScans'] as List).length),
              _buildPreviewRow(theme, 'Workout Plans', (data['plans'] as List).length),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(ThemeData theme, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    // Show import options
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_open),
              title: const Text('Import from File'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('Import from Clipboard'),
              onTap: () => Navigator.pop(context, 'clipboard'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    String? jsonString;

    if (source == 'file') {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result != null && result.files.single.bytes != null) {
          jsonString = utf8.decode(result.files.single.bytes!);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading file: $e')),
          );
        }
        return;
      }
    } else if (source == 'clipboard') {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      jsonString = clipboardData?.text;
    }

    if (jsonString == null || jsonString.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to import')),
        );
      }
      return;
    }

    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      await _processImport(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid JSON format: $e')),
        );
      }
    }
  }

  Future<void> _processImport(Map<String, dynamic> data) async {
    final theme = Theme.of(context);

    // Count items to import
    final strengthCount = (data['strengthSessions'] as List?)?.length ?? 0;
    final runningCount = (data['runningSessions'] as List?)?.length ?? 0;
    final hiitCount = (data['hiitSessions'] as List?)?.length ?? 0;
    final bodyScansCount = (data['bodyScans'] as List?)?.length ?? 0;
    final plansCount = (data['plans'] as List?)?.length ?? 0;

    final totalCount = strengthCount + runningCount + hiitCount + bodyScansCount + plansCount;

    if (totalCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid data found in import')),
        );
      }
      return;
    }

    // Confirm import
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will import:'),
            const SizedBox(height: 12),
            if (strengthCount > 0) Text('• $strengthCount strength sessions'),
            if (runningCount > 0) Text('• $runningCount running sessions'),
            if (hiitCount > 0) Text('• $hiitCount HIIT sessions'),
            if (bodyScansCount > 0) Text('• $bodyScansCount body scans'),
            if (plansCount > 0) Text('• $plansCount workout plans'),
            const SizedBox(height: 12),
            Text(
              'Existing data will be preserved. Duplicate IDs will be skipped.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Perform import
    int imported = 0;

    try {
      // Import strength sessions
      if (data['strengthSessions'] != null) {
        for (final item in data['strengthSessions']) {
          try {
            final session = StrengthSession.fromJson(item);
            if (widget.repository.getStrengthSessionById(session.id) == null) {
              await widget.repository.saveStrengthSession(session);
              imported++;
            }
          } catch (e) {
            // Skip invalid items
          }
        }
      }

      // Import running sessions
      if (data['runningSessions'] != null) {
        for (final item in data['runningSessions']) {
          try {
            final session = RunningSession.fromJson(item);
            if (widget.repository.getRunningSessionById(session.id) == null) {
              await widget.repository.saveRunningSession(session);
              imported++;
            }
          } catch (e) {
            // Skip invalid items
          }
        }
      }

      // Import HIIT sessions
      if (data['hiitSessions'] != null) {
        for (final item in data['hiitSessions']) {
          try {
            final session = HiitSession.fromJson(item);
            if (widget.repository.getHiitSessionById(session.id) == null) {
              await widget.repository.saveHiitSession(session);
              imported++;
            }
          } catch (e) {
            // Skip invalid items
          }
        }
      }

      // Import body scans
      if (data['bodyScans'] != null) {
        for (final item in data['bodyScans']) {
          try {
            final scan = BodyScan.fromJson(item);
            if (widget.repository.getBodyScanById(scan.id) == null) {
              await widget.repository.saveBodyScan(scan);
              imported++;
            }
          } catch (e) {
            // Skip invalid items
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported $imported items!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import error: $e')),
        );
      }
    }
  }
}
