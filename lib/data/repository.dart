import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/strength_session.dart';
import '../models/running_session.dart';
import '../models/hiit_session.dart';
import '../models/body_scan.dart';
import '../models/gpt_feedback.dart';
import '../models/app_settings.dart';
import '../services/github_service.dart';

class Repository {
  late Box<Category> _categoriesBox;
  late Box<Exercise> _exercisesBox;
  late Box<Plan> _plansBox;
  late Box<StrengthSession> _strengthSessionsBox;
  late Box<RunningSession> _runningSessionsBox;
  late Box<HiitSession> _hiitSessionsBox;
  late Box<BodyScan> _bodyScansBox;
  late Box<GptFeedback> _gptFeedbackBox;
  late Box<AppSettings> _settingsBox;

  GitHubService? _githubService;

  Future<void> initialize() async {
    _categoriesBox = await Hive.openBox<Category>('categories');
    _exercisesBox = await Hive.openBox<Exercise>('exercises');
    _plansBox = await Hive.openBox<Plan>('plans');
    _strengthSessionsBox = await Hive.openBox<StrengthSession>('strength_sessions');
    _runningSessionsBox = await Hive.openBox<RunningSession>('running_sessions');
    _hiitSessionsBox = await Hive.openBox<HiitSession>('hiit_sessions');
    _bodyScansBox = await Hive.openBox<BodyScan>('body_scans');
    _gptFeedbackBox = await Hive.openBox<GptFeedback>('gpt_feedback');
    _settingsBox = await Hive.openBox<AppSettings>('settings');

    // Initialize GitHub service from settings
    _initializeGitHubService();
  }

  void _initializeGitHubService() {
    final settings = getSettings();
    if (settings.isGithubConfigured) {
      _githubService = GitHubService(
        token: settings.githubToken,
        owner: settings.githubRepoOwner,
        repo: settings.githubRepoName,
      );
    }
  }

  // ============ Settings ============

  AppSettings getSettings() {
    return _settingsBox.get('settings') ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
    _initializeGitHubService();
  }

  bool get isGithubConfigured => _githubService?.isConfigured ?? false;

  // ============ Categories ============

  List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  Category? getCategoryById(String id) {
    return _categoriesBox.get(id);
  }

  Future<void> saveCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  // ============ Exercises ============

  List<Exercise> getAllExercises() {
    return _exercisesBox.values.toList();
  }

  List<Exercise> getExercisesByCategory(String categoryId) {
    return _exercisesBox.values
        .where((e) => e.categoryId == categoryId)
        .toList();
  }

  Exercise? getExerciseById(String id) {
    return _exercisesBox.get(id);
  }

  Future<void> saveExercise(Exercise exercise) async {
    await _exercisesBox.put(exercise.id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    await _exercisesBox.delete(id);
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // ============ Plans ============

  List<Plan> getAllPlans() {
    return _plansBox.values.toList();
  }

  Plan? getPlanById(String id) {
    return _plansBox.get(id);
  }

  Plan? getMainPlan() {
    return _plansBox.values.where((p) => p.isMain).firstOrNull;
  }

  Future<void> savePlan(Plan plan) async {
    await _plansBox.put(plan.id, plan);
  }

  Future<void> setMainPlan(String planId) async {
    for (final plan in _plansBox.values) {
      if (plan.id == planId) {
        plan.isMain = true;
      } else {
        plan.isMain = false;
      }
      await plan.save();
    }
  }

  Future<void> deletePlan(String id) async {
    await _plansBox.delete(id);
  }

  // ============ Strength Sessions ============

  List<StrengthSession> getAllStrengthSessions() {
    return _strengthSessionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  StrengthSession? getStrengthSessionById(String id) {
    return _strengthSessionsBox.get(id);
  }

  StrengthSession? getActiveStrengthSession() {
    return _strengthSessionsBox.values
        .where((s) => !s.isCompleted)
        .firstOrNull;
  }

  Future<void> saveStrengthSession(StrengthSession session) async {
    await _strengthSessionsBox.put(session.id, session);
  }

  Future<void> deleteStrengthSession(String id) async {
    await _strengthSessionsBox.delete(id);
  }

  // ============ Running Sessions ============

  List<RunningSession> getAllRunningSessions() {
    return _runningSessionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  RunningSession? getRunningSessionById(String id) {
    return _runningSessionsBox.get(id);
  }

  Future<void> saveRunningSession(RunningSession session) async {
    await _runningSessionsBox.put(session.id, session);
  }

  Future<void> deleteRunningSession(String id) async {
    await _runningSessionsBox.delete(id);
  }

  // ============ HIIT Sessions ============

  List<HiitSession> getAllHiitSessions() {
    return _hiitSessionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  HiitSession? getHiitSessionById(String id) {
    return _hiitSessionsBox.get(id);
  }

  Future<void> saveHiitSession(HiitSession session) async {
    await _hiitSessionsBox.put(session.id, session);
  }

  Future<void> deleteHiitSession(String id) async {
    await _hiitSessionsBox.delete(id);
  }

  // ============ Body Scans ============

  List<BodyScan> getAllBodyScans() {
    return _bodyScansBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  BodyScan? getBodyScanById(String id) {
    return _bodyScansBox.get(id);
  }

  BodyScan? getLatestBodyScan() {
    final scans = getAllBodyScans();
    return scans.isNotEmpty ? scans.first : null;
  }

  Future<void> saveBodyScan(BodyScan scan) async {
    await _bodyScansBox.put(scan.id, scan);
  }

  Future<void> deleteBodyScan(String id) async {
    await _bodyScansBox.delete(id);
  }

  // ============ GPT Feedback ============

  List<GptFeedback> getAllGptFeedback() {
    return _gptFeedbackBox.values.toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  GptFeedback? getGptFeedbackById(String id) {
    return _gptFeedbackBox.get(id);
  }

  GptFeedback? getGptFeedbackForSession(String sessionId) {
    return _gptFeedbackBox.values
        .where((f) => f.sessionId == sessionId)
        .firstOrNull;
  }

  Future<void> saveGptFeedback(GptFeedback feedback) async {
    await _gptFeedbackBox.put(feedback.id, feedback);
  }

  // ============ All Workouts ============

  List<dynamic> getAllWorkouts() {
    final List<dynamic> workouts = [
      ...getAllStrengthSessions(),
      ...getAllRunningSessions(),
      ...getAllHiitSessions(),
    ];
    workouts.sort((a, b) => b.date.compareTo(a.date));
    return workouts;
  }

  List<dynamic> getWorkoutsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getAllWorkouts().where((w) {
      return w.date.isAfter(weekStart) && w.date.isBefore(weekEnd);
    }).toList();
  }

  // ============ GitHub Sync ============

  Future<SyncResult> syncToGitHub() async {
    if (_githubService == null || !_githubService!.isConfigured) {
      return SyncResult.error('GitHub not configured');
    }

    try {
      // Prepare workout data
      final workoutsData = {
        'lastSync': DateTime.now().toIso8601String(),
        'strengthSessions': getAllStrengthSessions()
            .where((s) => s.isCompleted)
            .map((s) => s.toJson())
            .toList(),
        'runningSessions': getAllRunningSessions()
            .where((s) => s.isCompleted)
            .map((s) => s.toJson())
            .toList(),
        'hiitSessions': getAllHiitSessions()
            .where((s) => s.isCompleted)
            .map((s) => s.toJson())
            .toList(),
      };

      // Prepare body scans data
      final bodyScansData = {
        'lastSync': DateTime.now().toIso8601String(),
        'scans': getAllBodyScans().map((s) => s.toJson()).toList(),
      };

      // Prepare plans data
      final plansData = {
        'lastSync': DateTime.now().toIso8601String(),
        'plans': getAllPlans().map((p) => p.toJson()).toList(),
      };

      // Prepare GPT feedback data
      final gptFeedbackData = {
        'lastSync': DateTime.now().toIso8601String(),
        'feedback': getAllGptFeedback().map((f) => f.toJson()).toList(),
      };

      final result = await _githubService!.syncAll(
        workouts: workoutsData,
        bodyScans: bodyScansData,
        plans: plansData,
        gptFeedback: gptFeedbackData,
      );

      if (result.isSuccess) {
        // Update last sync time
        final settings = getSettings();
        settings.lastSyncTime = DateTime.now();
        await saveSettings(settings);
      }

      return result;
    } catch (e) {
      return SyncResult.error('Sync failed: $e');
    }
  }

  // ============ Data Check ============

  bool get isDatabaseEmpty {
    return _categoriesBox.isEmpty &&
        _exercisesBox.isEmpty &&
        _plansBox.isEmpty;
  }
}
